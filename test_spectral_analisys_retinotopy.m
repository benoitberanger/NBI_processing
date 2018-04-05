clear
clc

file = '/teams/CENIR-IRM-MEG-EEG/ANALYSE/cenir_NBI/fmri/img/2016_05_20_NBI_ROCA/S21_MBB3_ep2d_TR900_3iso_RETINO/sutrf430_S21_MBB3_ep2d_TR900_3iso_RETINO.nii';
% 
mri = ft_read_mri(file)

% mrview coordinates
mri.anatomy = flip(mri.anatomy,2); 
mri.anatomy = permute(mri.anatomy,[2 1 3 4]);


%% Shortcuts

Sro = size(mri.anatomy,1); % size ReadOut
Sph = size(mri.anatomy,2); % size PHase
Ssl = size(mri.anatomy,3); % size SLice

Svx = Sro * Sph * Ssl;

St  = size(mri.anatomy,4); % size Time


%% Plot slice

% figure
% image(mri.anatomy(:,:,15,10))
% axis equal
% colormap(gray(2^15))


%% Time series

S = reshape(mri.anatomy,[Svx St]);
S = S - mean(S,2);

%% Filter

rotation_req = 1/48; % Hz

S_filtBP = ft_preproc_bandpassfilter(S,1/0.900,[0.015 0.035]);
% S_filtBP = ft_preproc_bandpassfilter(S,1/0.900,[0.015 0.100]);


% %%
% 
% figure
% image(S_filtBP)
% 
% 
% %% Plot single voxel time serie
% 
% voxel_index = sub2ind(size(mri.anatomy), 28, 8, 15);
% 
% plotFFT(S       (voxel_index,:), 1/0.900, [0 0.5])
% plotFFT(S_filtBP(voxel_index,:), 1/0.900, [0 0.5])


%% Init

TR = 0.900;
freq = 1/48;
fstim = 60;
ccdur = 4*48;

nrVolumes = 8*48/TR;

time1 = 0:1/fstim:ccdur;
sin1  = sin( 2*pi*freq*time1 );

time2 = ccdur:1/fstim:ccdur*2;
sin2  = sin( -2*pi*freq*time2 );

time = [time1 time2];
SIN = [sin1 sin2];


U(1).u    = SIN';
U(1).name = {'sin'};

%%volterra_convolution

fMRI_T     = spm_get_defaults('stats.fmri.t');
fMRI_T0    = spm_get_defaults('stats.fmri.t0');
xBF.T  = fMRI_T;
xBF.T0 = fMRI_T0;

xBF.dt   = TR/xBF.T;
xBF.name = 'hrf';

[xBF] = spm_get_bf(xBF); % get HRF

X = spm_Volterra(U, xBF.bf, 1); % convolution

% plot(time,SIN, time,X)

%%down sample @ TR

volumes_in_dataset_float = size(X,1)/fstim/TR;
volumes_in_dataset_int   = floor(volumes_in_dataset_float); % round toward 0
X_reg = X( round((0:(volumes_in_dataset_int - 1))*fstim*TR)+1 ,:); % resample

%%pad with zeros at the end

% add 0 at the end for the remaining volumes without stim
if St - volumes_in_dataset_int > 0
    X_reg = [X_reg ; zeros( St - volumes_in_dataset_int ,size(X_reg,2))];
elseif St - volumes_in_dataset_int < 0
    X_reg = X_reg(1:St,:);
end
X_reg = X_reg';

%%

% close all

res = nan(Svx,1);

for i = 1:Svx
    
    [acor,lag] = xcorr(S_filtBP(i,:),X_reg);
    [~,I] = max(abs(acor));
    
    res(i) = (I+1)/2;
    
%     figure
%     subplot(3,1,1)
%     plot(S_filtBP(i,:))
%     subplot(3,1,2)
%     plot(acor)
%     subplot(3,1,3)
%     plot(lags)

end


%%

res_vol = reshape(res,[Sro Sph Ssl]);

%%

mri_write = mri;
mri_write.anatomy = res_vol;
ft_write_mri(fullfile(pwd,'lag.nii'),mri_write.anatomy,'transform', mri.transform,'dataformat','nifti');


%%

% close all
% figure
% 
% vx = sub2ind(size(mri.anatomy), 8, 43, 18)
% 
% ts =r(vx,:);
% 
% subplot(2,1,1)
% plot(ts)
% 
% subplot(2,1,2)
% ts_bp = ft_preproc_bandpassfilter(ts,1/0.900,[1/(48+10) 1/(48-10)]);
% plot(ts_bp)


%% 

% figure
% image(r)
% colormap(gray(2^15))
% 
% vx = sub2ind(size(mri.anatomy),Sro/2, Sph/2, Ssl/2)
% ts =r(vx,:);

% plot(r(5,:))



