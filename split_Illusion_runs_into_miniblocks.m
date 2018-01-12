%% Init

clear
clc

global subject_regex

%% Fetch dirs and files

% Get behaviour dir full path
subject_dirs = get_subdir_regex(pwd,'img',subject_regex); char(subject_dirs) % do not overwrite the subject already splitted

% Get Illusion dir full path
Illusion_dirs = get_subdir_regex_multi(subject_dirs,'ILLUSION_run\d$');
Illusion_dirs_BLIP = get_subdir_regex_multi(subject_dirs,'ILLUSION_run\d_BLIP$');

% Fetch the fullpath of each .nii file for each subject
raw_images = get_subdir_regex_files(Illusion_dirs,'^f.*run\d.nii'); % char(raw_images)
unzip_volume(raw_images) % Unzip files if needed
raw_images = get_subdir_regex_files(Illusion_dirs,'^f.*run\d.nii'); % char(raw_images)

raw_images_BLIP = get_subdir_regex_files(Illusion_dirs_BLIP,'^f.*run\d_BLIP.nii'); % char(raw_images)
unzip_volume(raw_images_BLIP) % Unzip files if needed
raw_images_BLIP = get_subdir_regex_files(Illusion_dirs_BLIP,'^f.*run\d_BLIP.nii'); % char(raw_images)

% we need the json files for the topup
raw_json = get_subdir_regex_files(Illusion_dirs,'^dic.*.json'); % char(raw_images)
raw_json_BLIP = get_subdir_regex_files(Illusion_dirs_BLIP,'^dic.*.json'); % char(raw_images)


%% Make new dir (delete the previous if exist)

% Make new dirs according to each subject dir name

for mb = 1 : 16
    mb_dir{mb} = r_mkdir( subject_dirs, sprintf('miniblock_%.2d',mb)); %char(mb_dir{mb})
%     do_delete(mb_dir{mb},0);
    mb_dir{mb} = r_mkdir( subject_dirs, sprintf('miniblock_%.2d',mb)); %char(mb_dir{mb})
    
    mb_dir_BLIP{mb} = r_mkdir( subject_dirs, sprintf('miniblock_%.2d_BLIP',mb)); %char(mb_dir{mb})
%     do_delete(mb_dir_BLIP{mb},0);
    mb_dir_BLIP{mb} = r_mkdir( subject_dirs, sprintf('miniblock_%.2d_BLIP',mb)); %char(mb_dir{mb})
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
        
        % split
        minblocks = do_fsl_roi(...
            raw_images{subj}(run,:),...
            sprintf('f_miniblock_%.2d',mb),...
            volume_idx.mb1.start-1,...
            volume_idx.mb1.nr);
        
        fprintf('mb1 = %s | from %d to %d \n',...
            mb_dir{mb}{subj},...
            volume_idx.mb1.start,...
            volume_idx.mb1.start + volume_idx.mb1.nr - 1)
        
        % move splitted
        r_movefile(...
            {[minblocks{:} '.nii']},...
            mb_dir{mb}(subj),...
            'move');
        
        % copy json
        r_movefile(...
            {raw_json{subj}(run,:)},...
            {sprintf('%s',mb_dir{mb}{subj})},...
            'copy');
        
        % copy ref
        r_movefile(...
            {raw_images_BLIP{subj}(run,:)},...
            {sprintf('%sf_miniblock_%.2d_BLIP.nii',mb_dir_BLIP{mb}{subj},mb)},...
            'copy');
        
        
        fprintf('copy ref from %s to %s \n',...
            raw_images_BLIP{subj}(run,:),...
            sprintf('%sf_miniblock_%.2d_BLIP.nii',mb_dir_BLIP{mb}{subj},mb))
        
        % copy json ref
        r_movefile(...
            {raw_json_BLIP{subj}(run,:)},...
            {sprintf('%s',mb_dir_BLIP{mb}{subj})},...
            'copy');
        
        
        %% miniblock_2
        
        mb = mb + 1;
        
        % split
        minblocks = do_fsl_roi(...
            raw_images{subj}(run,:),...
            sprintf('f_miniblock_%.2d',mb),...
            volume_idx.mb2.start-1,...
            volume_idx.mb2.nr);
        
        fprintf('mb2 = %s | from %d to %d \n',...
            mb_dir{mb}{subj},...
            volume_idx.mb2.start,...
            volume_idx.mb2.start + volume_idx.mb2.nr - 1 + volume_idx.security)
        
        % move splitted
        r_movefile(...
            {[minblocks{:} '.nii']},...
            mb_dir{mb}(subj),...
            'move');
        
        % copy json
        r_movefile(...
            {raw_json{subj}(run,:)},...
            {sprintf('%s',mb_dir{mb}{subj})},...
            'copy');
        
        %copy ref
        r_movefile(...
            {raw_images_BLIP{subj}(run,:)},...
            {sprintf('%sf_miniblock_%.2d_BLIP.nii',mb_dir_BLIP{mb}{subj},mb)},...
            'copy');
        
        fprintf('copy ref from %s to %s \n',...
            raw_images_BLIP{subj}(run,:),...
            sprintf('%sf_miniblock_%.2d_BLIP.nii',mb_dir_BLIP{mb}{subj},mb))
        
        % copy json ref
        r_movefile(...
            {raw_json_BLIP{subj}(run,:)},...
            {sprintf('%s',mb_dir_BLIP{mb}{subj})},...
            'copy');
        
    end
end


