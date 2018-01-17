clear
clc

global subject_regex


%% Prepare paths and regexp

chemin=[ pwd filesep 'img'];

suj = get_subdir_regex(chemin,subject_regex);
% suj = get_subdir_regex(chemin);
%to see the content
char(suj)

%functional and anatomic subdir
par.dfonc_reg='((MTMSTL)|(MTMSTR))$';
par.dfonc_reg_oposit_phase = '((MTMSTL)|(MTMSTR))+_BLIP$';

%for the preprocessing : Volume selecytion
par.anat_file_reg  = '^s.*nii'; %le nom generique du volume pour l'anat
par.file_reg  = '^f.*nii'; %le nom generique du volume pour les fonctionel

par.display=0;
par.run=1;


%% Get files paths

dfonc = get_subdir_regex_multi(suj,par.dfonc_reg) % ; char(dfonc{:})


%% Preprocess fMRI runs

%smooth the data
ffonc = get_subdir_regex_files(dfonc,'^utrf.*nii$')
par.smooth = [6 6 6];
j_smooth=job_smooth(ffonc,par)
