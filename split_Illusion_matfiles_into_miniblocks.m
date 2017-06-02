%% Init

close all
clear
clc


%% Fetch dirs and files

% Get behaviour dir full path
matfiles_dirs = get_subdir_regex(pwd,'behaviour_data','only_Illusion_mat_files','NBI'); char(matfiles_dirs)

% Extract subject dir name
[~, subject_dir_name] = get_parent_path(matfiles_dirs,1);

% Fetch the fullpaht of each .mat file for each subject
Illusion_files = get_subdir_regex_files(matfiles_dirs,'.mat$'); char(Illusion_files)


%% Make new dir (delete the previous if exist)

% Make new dirs according to each subject dir name

spmReady_mat_files_dirs = r_mkdir( [ pwd filesep 'behaviour_data' filesep 'spmReady_mat_files' ],subject_dir_name); %char(spmReady_mat_files_dirs)
do_delete(spmReady_mat_files_dirs,0)
spmReady_mat_files_dirs = r_mkdir( [ pwd filesep 'behaviour_data' filesep 'spmReady_mat_files' ],subject_dir_name); %char(spmReady_mat_files_dirs)

for mb = 1 : 16
    mb_dir{mb} = r_mkdir( spmReady_mat_files_dirs, sprintf('miniblock_%.2d',mb)); %char(mb_dir{mb})
end


%% Re-process each beahaviour file to generate names onsets durations

for sbj = 1 : length( Illusion_files )
    for run = 1 : size( Illusion_files{sbj} , 1 )
        %% Load the .mat behaviour file
        
        fprintf('currentFile = %s \n' , Illusion_files{sbj}(run,:) )
        currentFile = load(Illusion_files{sbj}(run,:));
        
        
        %% Special rule for Pilote01 and TAMY
        % because the Catch Trials are not blocks (block cars)
        
        if regexp( Illusion_files{sbj}(1,:),'Pilote01|TAMY','once')
            currentFile.DataStruct = formatS1S2_NBI(currentFile.DataStruct);
        end
        
        
        %% Find the first volume of the second concatenated mini-block
        % Here we have different cases, because the paradigme changed.
        
        % mb(i) = 157.5 seconds, mb(i+1) = 157.5 seconds
        if regexp( Illusion_files{sbj}(1,:),'Pilote01|TAMY|PIET','once')
            searchLimit = 157.5;
            
            % mb(i) = 157.5 seconds, mb(i+1) = 157.5 seconds + 9 TR
        elseif regexp( Illusion_files{sbj}(1,:),'ROCA','once')
            searchLimit = 157.5;
            
            % and the rest...
            % mb(i) = 157.5 seconds + 9 TR , mb(i+1) = 157.5 seconds + 9 TR
        else
            searchLimit = 157.5 + 9*0.900;
            
        end
        
        mriTriggers = cell2mat(currentFile.DataStruct.TaskData.KL.KbEvents{1,2}(:,1:2));
        mriTriggers = mriTriggers(mriTriggers(:,2)==1);
        
        [~,firstVolume_secondMiniBlock.idx] = min(abs(mriTriggers-searchLimit));
        firstVolume_secondMiniBlock.onset = mriTriggers(firstVolume_secondMiniBlock.idx);
        
        
        %% Transfort into SPM onsets
        
        [ mb1.names , mb1.onsets , mb1.durations ] = SPMnod( currentFile.DataStruct );
        
        
        %% Split miniblock_1 and miniblock_2
        
        mb2 = struct;
        mb2.names = mb1.names;
        
        for cond = 1 : length(mb1.names)
            
            
            
            mb2_ons_idx = mb1.onsets{cond} >= firstVolume_secondMiniBlock.onset;
            
            mb2.onsets{cond,1} = mb1.onsets{cond}(mb2_ons_idx) - firstVolume_secondMiniBlock.onset;
            mb2.durations{cond,1} = mb1.durations{cond}(mb2_ons_idx);
            
            mb1.onsets{cond}(mb2_ons_idx) = [];
            mb1.durations{cond}(mb2_ons_idx) = [];
            
        end
        
        
        
        %% Take out catch trials
        
        for mb = [1 2]
            
            switch mb
                
                case 1
                    names     = mb1.names    ;
                    onsets    = mb1.onsets   ;
                    durations = mb1.durations;
                    
                case 2
                    names     = mb2.names    ;
                    onsets    = mb2.onsets   ;
                    durations = mb2.durations;
                    
            end
            
            
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
            
            % Save
            fprintf('saving in %s\n', mb_dir{(run-1)*2+mb}{sbj})
            save(sprintf('%sminiblock_%.2d',mb_dir{(run-1)*2+mb}{sbj},(run-1)*2+mb), 'names', 'onsets', 'durations' )
            
            
        end
        
        
    end
end

