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
       %% Load and re-generate names onsets durations
        
        fprintf('currentFile = %s \n' , Illusion_files{sbj}(run,:) )
        currentFile = load(Illusion_files{sbj}(run,:));
        
        if sbj==1 || sbj==2 % special rule for Pilote01 and TAMY, because the Catch Trials are not blocks (block cars)
            currentFile.DataStruct = formatS1S2_NBI(currentFile.DataStruct);
        end
        
        [ names , onsets , durations ] = SPMnod( currentFile.DataStruct );
        
        %% Take out catch trials
        
        for ct = 1 : length(onsets{9}) % 'CATCH'
            current_catch_onset = onsets{9}(ct);
            
            % Here we scan where is the current catch trial (i.e. in which
            % condition)
            trial_found = 0;
            
            
            for cond = 1 : 8
                for cond_onset = 1 : length(onsets{cond})
                    
                    if current_catch_onset == onsets{cond}(cond_onset)
                        
                        trial_found = 1;
                        
                        cond_to_remove  = cond;
                        trial_to_remove = cond_onset;
                        
                    end

                end
                
            end
            
            % Security : if we don't find the corresponding onset...
            if ~trial_found
                error('catch trial not found in any condition')
            end
            
            % Remove this trial
            onsets{cond_to_remove}(trial_to_remove) = [];
            durations{cond_to_remove}(trial_to_remove) = [];
            
        end
        
        %% Take out the clicks
        
        
    end
end


plotSPMnod(names , onsets , durations)

