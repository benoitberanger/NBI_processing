clear
clc
global subject_regex nbi
nbi = [];

% subject_regex = '(AMJU)|(ROCA)|(PIET)|(TAMY)';%'(TRAL)|(THMI)|(ELOU)|(CELE)|(STCH)|(AMJU)|(ROCA)|(PIET)|(TAMY)|(pilot';
subject_regex = 'NBI_';
% subject_regex = '(VEAR)|(SIKA)|(BOPI)|(EYCE)|(HEJU)|(BAFR)|(SAPH)';%|(AMJU)|(ROCA)|(PIET)|(TAMY)|(pilot';
% |(VEMA)|(PEPI)|(PEPA)
% all subjects : 'NBI_'
% one subject : 'ROCA'
% 2+ subjects : '(ROCA)|(CELE)'
% subject_regex = '(TRAL)';
setenv('FSLOUTPUTTYPE','NIFTI')

return % never execute the whole script : it will erase data


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
preprocessing_MTMSTloc   % smooth
preprocessing_Retinotopy % smooth

% Illusion stim files
stimpath_miniblock = [pwd filesep 'behaviour_data' filesep 'spmReady_mat_files'];
for mb = 1 : 16
    nbi.getSerie(sprintf('run_miniblock_%.3d',mb)).addStim(stimpath_miniblock, sprintf('miniblock_%.2d',1), 'stimfile', 1 )
end

% MTMST [RL] stim files
stimpath_MTMST = [pwd filesep 'behaviour_data' filesep 'spmReady_MTMST_files'];
nbi.getSerie('run_MTMSTL').addStim(stimpath_MTMST, 'MT_LEFT.mat' , 'MT_LEFT' , 1 )
nbi.getSerie('run_MTMSTR').addStim(stimpath_MTMST, 'MT_RIGHT.mat', 'MT_RIGHT', 1 )

% Retinotopy stim files
stimpath_retinotopy = [pwd filesep 'behaviour_data' filesep 'raw'];
nbi.getSerie('run_retinotopy').addStim(stimpath_retinotopy, 'Retinotopy.*\d.mat$' , 'retinotopy'  )

nbi.explore

save('nbi','nbi')

%% First-level

firstlevel_miniblocks

firstlevel_MTMSTloc
