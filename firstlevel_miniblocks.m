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
par.dfonc_reg='miniblock_\d+$';
par.dfonc_reg_oposit_phase = 'miniblock_\d+_ref$';
par.danat_reg='t1mpr';

%for the preprocessing : Volume selecytion
par.anat_file_reg  = '^s.*nii'; %le nom generique du volume pour l'anat
par.file_reg  = '^f.*nii'; %le nom generique du volume pour les fonctionel

par.display=0;
par.run=1;


%% Get files paths

dfonc = get_subdir_regex_multi(subjectdir,par.dfonc_reg) % ; char(dfonc{:})
dfonc_op = get_subdir_regex_multi(subjectdir,par.dfonc_reg_oposit_phase)% ; char(dfonc_op{:})
dfoncall = get_subdir_regex_multi(subjectdir,{par.dfonc_reg,par.dfonc_reg_oposit_phase })% ; char(dfoncall{:})
anat = get_subdir_regex_one(subjectdir,par.danat_reg)% ; char(anat) %should be no warning


%% Get files

ffonc = get_subdir_regex_files(dfonc,'^utrf.*nii',1)
nrRun = size(ffonc{1},1);


%% prepare first level

statdir=r_mkdir(subjectdir,'stat')
all_miniblocks_dir=r_mkdir(statdir,'all_miniblocks')
do_delete(all_miniblocks_dir,0)
all_miniblocks_dir=r_mkdir(statdir,'all_miniblocks')

par.file_reg = '^utrf.*nii';

par.TR=0.900; % seconds
par.delete_previous=1;

% Fetch onset .mat files
[~, subject] = get_parent_path(subjectdir,1)
stimpath = [pwd filesep 'behaviour_data' filesep 'spmReady_mat_files'];
stimdir = get_subdir_regex(stimpath,subject); char(stimdir)

fons = get_subdir_regex_files(stimdir,'miniblock_\d+.mat$',16);
char(fons)


%% Specify model

par.rp = 1; % realignment paramters : movement regressors

par.run = 1;
par.display = 0;

j_specify = job_first_level_specify(dfonc,all_miniblocks_dir,fons,par)


%% Estimate model

fspm = get_subdir_regex_files(all_miniblocks_dir,'SPM',1)
j_estimate = job_first_level_estimate(fspm,par)


%% Prepare contrasts

base                = [0 0 0 0 0 0 0 0 0 0];

Illusion_InOut      = [1 0 0 0 0 0 0 0 0 0];
Illusion_rotation   = [0 1 0 0 0 0 0 0 0 0];
Control_inOut       = [0 0 1 0 0 0 0 0 0 0];
Control_rotation    = [0 0 0 1 0 0 0 0 0 0];
Control_global      = [0 0 0 0 1 0 0 0 0 0];
Control_local_inOut = [0 0 0 0 0 1 0 0 0 0];
Control_local_rot   = [0 0 0 0 0 0 1 0 0 0];
Null                = [0 0 0 0 0 0 0 1 0 0];
CATCH               = [0 0 0 0 0 0 0 0 1 0];
CLICK               = [0 0 0 0 0 0 0 0 0 1];

contrast.names = {
    
    'main effect : Illusion_InOut'
    'main effect : Illusion_rotation'
    'main effect : Control_inOut'
    'main effect : Control_rotation'
    'main effect : Control_global'
    'main effect : Control_local_inOut'
    'main effect : Control_local_rot'
    'main effect : Null'
    'main effect : CATCH'
    'main effect : CLICK'
    
    'Illusion_InOut - Control_inOut'
    'Control_inOut  - Illusion_InOut'
    'Illusion_rotation - Control_rotation'
    'Control_rotation - Illusion_rotation'
    
    'Null - illusion/control'
    'CATCH - illusion/control'
    'CLICK - illusion/control'
    
    };


    
contrast.values = {
    
    Illusion_InOut
    Illusion_rotation
    Control_inOut
    Control_rotation
    Control_global
    Control_local_inOut
    Control_local_rot
    Null
    CATCH
    CLICK
    
    Illusion_InOut - Control_inOut
    Control_inOut  - Illusion_InOut
    Illusion_rotation - Control_rotation
    Control_rotation - Illusion_rotation
    
    Null*7-Illusion_InOut-Illusion_rotation-Control_inOut-Control_rotation-Control_global-Control_local_inOut-Control_local_rot
    CATCH*7-Illusion_InOut-Illusion_rotation-Control_inOut-Control_rotation-Control_global-Control_local_inOut-Control_local_rot
    CLICK*7-Illusion_InOut-Illusion_rotation-Control_inOut-Control_rotation-Control_global-Control_local_inOut-Control_local_rot
    
    };

contrast.types = repmat({'T'},[1 length(contrast.values)]);
par.delete_previous=1;

par.sessrep = 'repl';

%% Generate contrasts

j_contrast = job_first_level_contrast(fspm,contrast,par)

