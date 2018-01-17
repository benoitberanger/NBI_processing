% add all raw subject behaviour data in : ./behaviour_data/raw/

% Before running this script, I deleted the wrong (empty) subject dirs.
% Also, I removed the canceled run files such as "Block8_1" and keep only
% the "Block8_2".


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
Illusion_files = get_subdir_regex_files(behav_raw_dirs,'_Illusion_.*\d.mat$'); char(Illusion_files)

for i = 1 :length(Illusion_files)
    assert( size(Illusion_files{i},1) == 8, 'error : %d stim files found in %d', size(Illusion_files{1},1), i)
end

%% Make new dir (delete the previous if exist)

% Make new dirs according to each subject dir name
behav_only_mat_files_dirs = r_mkdir( [ pwd filesep 'behaviour_data' filesep 'only_Illusion_mat_files' ],subject_dir_name); char(behav_only_mat_files_dirs)
do_delete(behav_only_mat_files_dirs,0)
behav_only_mat_files_dirs = r_mkdir( [ pwd filesep 'behaviour_data' filesep 'only_Illusion_mat_files' ],subject_dir_name); char(behav_only_mat_files_dirs)


%% Copy each file

new_Illusion_files = r_movefile( Illusion_files , behav_only_mat_files_dirs ,'copy'); char(new_Illusion_files)

