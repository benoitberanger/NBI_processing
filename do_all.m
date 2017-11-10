clear
clc

global subject_regex
subject_regex = '';

% all subjects : 'NBI_'
% one subject : 'ROCA'
% 2+ subjects : '(ROCA)|(CELE)'


%% Prepare stim files

copy_Illusion_matfiles

split_Illusion_matfiles_into_miniblocks


%% Split run .nii files into 2 miniblocks

split_Illusion_runs_into_miniblocks


%% Preprocessing

precrocessing_miniblocks


%% First-level

firstlevel_miniblocks

