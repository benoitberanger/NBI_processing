clear
clc

global subject_regex nbi



%% Prepare paths and regexp

% imgdir=[ pwd filesep 'img'];

% subjectdir = get_subdir_regex(imgdir,subject_regex);
% subjectdir = get_subdir_regex(imgdir);
%to see the content
% char(subjectdir)

%functional and anatomic subdir
% par.dfonc_reg='MTMST[LR]$';
% par.dfonc_reg_oposit_phase = 'MTMST[LR]_BLIP$';
% par.danat_reg='(t1mpr)|(T1w)';

%for the preprocessing : Volume selecytion
% par.anat_file_reg  = '^s.*nii'; %le nom generique du volume pour l'anat
% par.file_reg  = '^f.*nii'; %le nom generique du volume pour les fonctionel

par.display=0;
par.run=1;


%% Get files paths

to_exclude = {'Pilote01','TAMY','PIET','ROCA'};

nbi_temp = nbi.copyObject;

for ex = 1 : length(to_exclude)
    nbi_temp.getExam(to_exclude{ex}).is_incomplete = 1;
end

[ completeExams, incompleteExams ] = nbi_temp.removeIncomplete;

dfonc_TR900  = incompleteExams.getSerie('run_MTMST').toJob;
dfonc_TR1000 = completeExams.  getSerie('run_MTMST').toJob;

subjectdir_TR900  = incompleteExams.toJob;
subjectdir_TR1000 = completeExams.toJob;


%% Get files

% ffonc = get_subdir_regex_files(dfonc,'^utrf.*nii',1)
% nrRun = size(ffonc{1},1);

return

%% prepare first level

statdir_TR900=r_mkdir(subjectdir_TR900,'stat_loc')
all_locs_dir_TR900=r_mkdir(statdir_TR900,'all_locs')
do_delete(all_locs_dir_TR900,0)
all_locs_dir_TR900=r_mkdir(statdir_TR900,'all_locs')

statdir_TR1000=r_mkdir(subjectdir_TR1000,'stat_loc')
all_locs_dir_TR1000=r_mkdir(statdi_TR1000r,'all_locs')
do_delete(all_locs_dir_TR1000,0)
all_locs_dir_TR1000=r_mkdir(statdir_TR1000,'all_locs')

par.file_reg = '^sutrf.*nii';


par.TR=1; % seconds


par.delete_previous=1;

% Fetch onset .mat files
% [~, subject] = get_parent_path(subjectdir,1)
% stimpath = [pwd filesep 'behaviour_data' filesep 'spmReady_MTMST_files'];
% stimdir = get_subdir_regex(stimpath,subject); char(stimdir)
% fons = get_subdir_regex_files(stimdir,'MT',2);
% char(fons)

fons_TR900  = incompleteExams.getSerie('run_MTMST').getStim.toJob
fons_TR1000 = completeExams.  getSerie('run_MTMST').getStim.toJob

%% Specify model

par.rp = 1; % realignment paramters : movement regressors

par.run = 1;
par.display = 0;

par.TR=0.900; % seconds
j_specify = job_first_level_specify(dfonc_TR900,all_locs_dir_TR900,fons_TR900,par)

par.TR=1; % seconds
j_specify = job_first_level_specify(dfonc_TR1000,all_locs_dir_TR1000,fons_TR1000,par)


%% Estimate model

fspm_TR900 = get_subdir_regex_files(all_locs_dir_TR900,'SPM',1)
j_estimate = job_first_level_estimate(fspm_TR900,par)

fspm_TR1000 = get_subdir_regex_files(all_locs_dirfspm_TR1000,'SPM',1)
j_estimate = job_first_level_estimate(fspmfspm_TR1000,par)


%% Prepare contrasts

rp = [0 0 0 0 0 0];

base      = [0 0 0 rp];
mouvement = [1 0 0 rp];
fixation  = [0 1 0 rp];
click     = [0 0 1 rp];


contrast.names = {
    
    
    'main effect : leftINOUT'
    'main effect : leftFIXATION'
    'main effect : rightINOUT'
    'main effect : rightFIXATION'
    'main effect : CLICK'
    
    
    'leftINOUT  - leftFIXATION'
    'rightINOUT - rightFIXATION'
    'INOUTl&r  - FIXATIONl&r'
    
    };
    
contrast.values = {
    
    [mouvement base]
    [fixation base]
    [base mouvement]
    [base fixation]
    [click click]
    
    [mouvement-fixation base]
    [base mouvement-fixation]
    [mouvement-fixation mouvement-fixation]
        
    };

contrast.types = repmat({'T'},[1 length(contrast.values)]);
par.delete_previous=1;

par.sessrep = 'none';

%% Generate contrasts

j_contrast = job_first_level_contrast(fspm_TR900 ,contrast,par)
j_contrast = job_first_level_contrast(fspm_TR1000,contrast,par)
