clear
clc

global subject_regex
% subject_regex = '(AMJU)|(ROCA)|(PIET)|(TAMY)';%'(TRAL)|(THMI)|(ELOU)|(CELE)|(STCH)|(AMJU)|(ROCA)|(PIET)|(TAMY)|(pilot';
subject_regex = 'NBI_';
% subject_regex = '(VEAR)|(SIKA)|(BOPI)|(EYCE)|(HEJU)|(BAFR)|(SAPH)';%|(AMJU)|(ROCA)|(PIET)|(TAMY)|(pilot';
% |(VEMA)|(PEPI)|(PEPA)
% all subjects : 'NBI_'
% one subject : 'ROCA'
% 2+ subjects : '(ROCA)|(CELE)'
% subject_regex = '(TRAL)';
setenv('FSLOUTPUTTYPE','NIFTI')


%% Prepare stim files

copy_Illusion_matfiles

split_Illusion_matfiles_into_miniblocks


%% Split run .nii files into 2 miniblocks

split_Illusion_runs_into_miniblocks


%% Prepare MTMST loc stim files

copy_MTMSTloc_matfiles

clean_MTMST


%% Preprocessing

% Segment anat + brain extract
% Realign-Reslice
% Topup
% Coregister
preprocessing_common

% Specific :
preprocessing_MTMSTloc % smooth


%% First-level

firstlevel_miniblocks

firstlevel_MTMSTloc
