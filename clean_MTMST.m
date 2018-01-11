%% Init

clear
clc

global subject_regex

%% Fetch dirs and files

% Get behaviour dir full path
matfiles_dirs = get_subdir_regex(pwd,'behaviour_data','only_MTMSTloc_mat_files',subject_regex); char(matfiles_dirs)

% Extract subject dir name
[~, subject_dir_name] = get_parent_path(matfiles_dirs,1);

% Fetch the fullpaht of each .mat file for each subject
MTMST_left_files = get_subdir_regex_files(matfiles_dirs,'MTMST_Left_MRI_1.mat$'); char(MTMST_left_files)
MTMST_right_files = get_subdir_regex_files(matfiles_dirs,'MTMST_Right_MRI_1.mat$'); char(MTMST_right_files)


%% Make new dir (delete the previous if exist)

% Make new dirs according to each subject dir name

spmReady_MTMST_files_dirs = r_mkdir( [ pwd filesep 'behaviour_data' filesep 'spmReady_MTMST_files' ],subject_dir_name); %char(spmReady_MTMST_files)
do_delete(spmReady_MTMST_files_dirs,0)
spmReady_MTMST_files_dirs = r_mkdir( [ pwd filesep 'behaviour_data' filesep 'spmReady_MTMST_files' ],subject_dir_name); %char(spmReady_MTMST_files)


%% Re-process each beahaviour file to generate names onsets durations

for i = 1:2
    
    if i == 1
        MTMST_files = MTMST_left_files;
    elseif i == 2
        MTMST_files = MTMST_right_files;
    end
    
    for sbj = 1 : length( MTMST_files )
        for run = 1 : size( MTMST_files{sbj} , 1 )
            %% Load the .mat behaviour file
            
            fprintf('currentFile = %s \n' , MTMST_files{sbj}(run,:) )
            currentFile = load(MTMST_files{sbj}(run,:));
            
            
            %% Special rule for Pilote01 and TAMY
            % because the Catch Trials are not blocks (block cars)
            
            if regexp( MTMST_files{sbj}(1,:),'Pilote01|TAMY','once')
                currentFile.DataStruct = formatS1S2_NBI(currentFile.DataStruct);
            end
            
            
            %% Transfort into SPM onsets
            
            [ names , onsets , durations ] = SPMnod( currentFile.DataStruct );
            
            
            %% Delete REST and CATCH
            
            names(4) = [];
            onsets(4) = [];
            durations(4) = [];
            names(3) = [];
            onsets(3) = [];
            durations(3) = [];
            
            
            %% Save
            
            if i == 1
                file_suffix = 'LEFT';
            elseif i == 2
                file_suffix = 'RIGHT';
            end
            % Save
            fprintf('saving %s in %s\n', sprintf('MT_%s',file_suffix), spmReady_MTMST_files_dirs{sbj})
            save(sprintf('%s%s',spmReady_MTMST_files_dirs{sbj},sprintf('MT_%s',file_suffix)), 'names', 'onsets', 'durations' )
            
            
            
        end
    end
    
end