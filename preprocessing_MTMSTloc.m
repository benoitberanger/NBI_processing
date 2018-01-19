clear
clc

global subject_regex nbi


%% Prepare paths and regexp

chemin=[ pwd filesep 'img'];

suj = get_subdir_regex(chemin,subject_regex);
% suj = get_subdir_regex(chemin);
%to see the content
% char(suj)

%functional and anatomic subdir
par.dfonc_reg='((MTMSTL)|(MTMSTR))$';
par.dfonc_reg_oposit_phase = '((MTMSTL)|(MTMSTR))+_BLIP$';

%for the preprocessing : Volume selecytion
par.anat_file_reg  = '^s.*nii'; %le nom generique du volume pour l'anat
par.file_reg  = '^f.*nii'; %le nom generique du volume pour les fonctionel

par.display=0;
par.run=1;


%% Preprocess fMRI runs

%smooth the data
ffonc = nbi.getSerie('run_MTMST[RL]').getVolume('^utrf').toJob;
par.smooth = [6 6 6];
j_smooth=job_smooth(ffonc,par)
nbi.getSerie('run_MTMST[RL]').addVolume('^sutrf.*nii','sutrf')
