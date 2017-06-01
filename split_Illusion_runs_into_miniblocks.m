%% Init

close all
clear
clc


%% Fetch dirs and files

% Get behaviour dir full path
subject_dirs = get_subdir_regex(pwd,'img','NBI'); char(subject_dirs)

% Get Illusion dir full path
Illusion_dirs = get_subdir_regex_multi(subject_dirs,'ILLUSION_run\d$');

% Fetch the fullpaht of each .mat file for each subject
raw_images = get_subdir_regex_files(Illusion_dirs,'^f.*run\d.nii'); % char(raw_images)
unzip_volume(raw_images) % Unzip files if needed
raw_images = get_subdir_regex_files(Illusion_dirs,'^f.*run\d.nii'); % char(raw_images)


%% Make new dir (delete the previous if exist)

% Make new dirs according to each subject dir name

for mb = 1 : 16
    mb_dir{mb} = r_mkdir( subject_dirs, sprintf('miniblock_%d',mb)); %char(mb_dir{mb})
    do_delete(mb_dir{mb},0);
    mb_dir{mb} = r_mkdir( subject_dirs, sprintf('miniblock_%d',mb)); %char(mb_dir{mb})
end


%% Split the runs

setenv('FSLOUTPUTTYPE','NIFTI')

for subj = 1 : length(subject_dirs)
    mb = 0;
    for run = 1 : size(raw_images{subj},1)
        %% How to cut ?
        
        
        % mb1 = 175 vol, mb2 = 175vol
        if regexp( raw_images{subj}(1,:),'Pilote01|TAMY|PIET','once')
            volume_idx.mb1.start = 1;
            volume_idx.mb1.nr    = 175;
            volume_idx.mb2.start = volume_idx.mb1.start + volume_idx.mb1.nr;
            volume_idx.mb2.nr    = 175;
            
            if regexp( raw_images{subj}(1,:),'Pilote01','once')
                volume_idx.security  = 1;
            else % TAMY | PIET
                volume_idx.security  = 5;
            end
            
            % mb1 = 175 vol, mb2 = 175vol, +9 at the end
        elseif regexp( raw_images{subj}(1,:),'ROCA','once')
            volume_idx.mb1.start = 1;
            volume_idx.mb1.nr    = 175;
            volume_idx.mb2.start = volume_idx.mb1.start + volume_idx.mb1.nr;
            volume_idx.mb2.nr    = 175 + 9;
            volume_idx.security  = 5;
            
            % and the rest...
            % mb1 = 175 + 9 vol, mb2 = 175 + 9 vol
        else
            volume_idx.mb1.start = 1;
            volume_idx.mb1.nr    = 175 + 9;
            volume_idx.mb2.start = volume_idx.mb1.start + volume_idx.mb1.nr;
            volume_idx.mb2.nr    = 175 + 9;
            volume_idx.security  = 2;
            
        end
        
        
        
        fprintf('input file = %s \n',raw_images{subj}(run,:))
        
        
        %% miniblock_1
        
        mb = mb + 1;
        
        minblocks = do_fsl_roi(...
            raw_images{subj}(run,:),...
            ['f_miniblock_' num2str(mb)],...
            volume_idx.mb1.start-1,...
            volume_idx.mb1.nr);
        
        fprintf('mb1 = %s | from %d to %d \n',...
            mb_dir{mb}{subj},...
            volume_idx.mb1.start,...
            volume_idx.mb1.start + volume_idx.mb1.nr - 1)
        
        r_movefile(...
            {[minblocks{:} '.nii']},...
            mb_dir{mb}(subj),...
            'move');
        
        
        %% miniblock_2
        
        mb = mb + 1;
        
        minblocks = do_fsl_roi(...
            raw_images{subj}(run,:),...
            ['f_miniblock_' num2str(mb)],...
            volume_idx.mb2.start-1,...
            volume_idx.mb2.nr);
        
        fprintf('mb2 = %s | from %d to %d \n',...
            mb_dir{mb}{subj},...
            volume_idx.mb2.start,...
            volume_idx.mb2.start + volume_idx.mb2.nr - 1 + volume_idx.security)
        
        r_movefile(...
            {[minblocks{:} '.nii']},...
            mb_dir{mb}(subj),...
            'move');
        
        
    end
end
