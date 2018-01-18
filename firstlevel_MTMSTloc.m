clear
clc

global subject_regex

%% Prepare paths and regexp

imgdir=[ pwd filesep 'img'];

subjectdir = get_subdir_regex(imgdir,subject_regex);
% subjectdir = get_subdir_regex(imgdir);
%to see the content
char(subjectdir)

%functional and anatomic subdir
par.dfonc_reg='MTMST[LR]$';
% par.dfonc_reg_oposit_phase = 'MTMST[LR]_BLIP$';
% par.danat_reg='(t1mpr)|(T1w)';

%for the preprocessing : Volume selecytion
% par.anat_file_reg  = '^s.*nii'; %le nom generique du volume pour l'anat
% par.file_reg  = '^f.*nii'; %le nom generique du volume pour les fonctionel

par.display=0;
par.run=1;


%% Get files paths

dfonc = get_subdir_regex_multi(subjectdir,par.dfonc_reg) % ; char(dfonc{:})
% dfonc_op = get_subdir_regex_multi(subjectdir,par.dfonc_reg_oposit_phase)% ; char(dfonc_op{:})
% dfoncall = get_subdir_regex_multi(subjectdir,{par.dfonc_reg,par.dfonc_reg_oposit_phase })% ; char(dfoncall{:})
% anat = get_subdir_regex_one(subjectdir,par.danat_reg)% ; char(anat) %should be no warning


%% Get files

ffonc = get_subdir_regex_files(dfonc,'^utrf.*nii',1)
nrRun = size(ffonc{1},1);


%% prepare first level

statdir=r_mkdir(subjectdir,'stat_loc')
all_locs_dir=r_mkdir(statdir,'all_locs')
do_delete(all_locs_dir,0)
all_locs_dir=r_mkdir(statdir,'all_locs')

par.file_reg = '^sutrf.*nii';

par.TR=1; % seconds
par.delete_previous=1;

% Fetch onset .mat files
[~, subject] = get_parent_path(subjectdir,1)
stimpath = [pwd filesep 'behaviour_data' filesep 'spmReady_MTMST_files'];
stimdir = get_subdir_regex(stimpath,subject); char(stimdir)

fons = get_subdir_regex_files(stimdir,'MT',2);
char(fons)


%% Specify model

par.rp = 1; % realignment paramters : movement regressors

par.run = 1;
par.display = 0;

j_specify = job_first_level_specify(dfonc,all_locs_dir,fons,par)


%% Estimate model

fspm = get_subdir_regex_files(all_locs_dir,'SPM',1)
j_estimate = job_first_level_estimate(fspm,par)


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

j_contrast = job_first_level_contrast(fspm,contrast,par)

