%


%% Init

close all
clear
clc


%% Fetch dirs and files

% Get behaviour dir full path
Illusion_dirs = get_subdir_regex('behaviour_data','only_Illusion_mat_files','NBI'); char(Illusion_dirs)

% Extract subject dir name
[~, subject_dir_name] = get_parent_path(Illusion_dirs,1);

% Fetch the fullpaht of each .mat file for each subject
Illusion_files = get_subdir_regex_files(Illusion_dirs,'.mat$'); char(Illusion_files)


%% Make new dir (delete the previous if exist)

% Make new dirs according to each subject dir name
% spmReady_mat_files_dirs = r_mkdir( [ pwd filesep 'behaviour_data' filesep 'spmReady_mat_files' ],subject_dir_name); char(spmReady_mat_files_dirs)
% do_delete(spmReady_mat_files_dirs,0)
% spmReady_mat_files_dirs = r_mkdir( [ pwd filesep 'behaviour_data' filesep 'spmReady_mat_files' ],subject_dir_name); char(spmReady_mat_files_dirs)


%% Re-process each beahaviour file to generate names onsets durations

for sbj = 1 : length( Illusion_files )
    for run = 1 : size( Illusion_files{sbj} , 1 )
        fprintf('currentFile = %s \n' , Illusion_files{sbj}(run,:) )
        currentFile = load(Illusion_files{sbj}(run,:));
        
        if sbj==1 || sbj==2 % special rule for Pilote01 and TAMY, because the Catch Trials are not blocks (block cars)
            currentFile.DataStruct = formatS1S2_NBI(currentFile.DataStruct);
        end
        
        [ names , onsets , durations ] = SPMnod( currentFile.DataStruct );
        
        
    end
end


plotSPMnod(names , onsets , durations)

