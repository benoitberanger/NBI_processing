% add all raw subject behaviour data in : ./behaviour_data/raw/

%


%% Init

clear
clc

global subject_regex

%% Fetch dirs and files

% Get behaviour dir full path
behav_raw_dirs = get_subdir_regex('behaviour_data','raw',subject_regex); char(behav_raw_dirs)

% Extract subject dir name
[~, subject_dir_name] = get_parent_path(behav_raw_dirs,1); 

% Fetch the fullpaht of each .mat file for each subject
MTMSTloc_files = get_subdir_regex_files(behav_raw_dirs,'_MTMST_.*\d.mat$',2); char(MTMSTloc_files)


%% Make new dir (delete the previous if exist)

% Make new dirs according to each subject dir name
behav_only_MTMSTmat_files_dirs = r_mkdir( [ pwd filesep 'behaviour_data' filesep 'only_MTMSTloc_mat_files' ],subject_dir_name); char(behav_only_MTMSTmat_files_dirs)
do_delete(behav_only_MTMSTmat_files_dirs,0)
behav_only_MTMSTmat_files_dirs = r_mkdir( [ pwd filesep 'behaviour_data' filesep 'only_MTMSTloc_mat_files' ],subject_dir_name); char(behav_only_MTMSTmat_files_dirs)


%% Copy each file

new_MTMSTloc_files = r_movefile( MTMSTloc_files , behav_only_MTMSTmat_files_dirs ,'copy'); char(new_MTMSTloc_files)

