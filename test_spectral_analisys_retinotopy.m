clear
clc

file = '/mnt/data/benoit/Protocol/NBI/fmri/img/2016_05_20_NBI_ROCA/S21_MBB3_ep2d_TR900_3iso_RETINO/sutrf430_S21_MBB3_ep2d_TR900_3iso_RETINO.nii';

mri = ft_read_mri(file)

%% Shortcuts

Sro = size(mri.anatomy,1); % size ReadOut
Sph = size(mri.anatomy,2); % size PHase
Ssl = size(mri.anatomy,3); % size SLice
St  = size(mri.anatomy,4); % size Time


%% Plot slice

% close all
% 
% figure
% image(mri.anatomy(:,:,15,10))
% colormap(gray(2^15))


%% Time series

S = reshape(mri.anatomy,[Sro*Sph*Ssl St]);


%% Filter

rotation_req = 1/48 % Hz

S_filtBP = ft_preproc_bandpassfilter(S,1/0.900,[0.010 0.030]);


%%

close all
figure
image(S_filtBP)


%% 

vx = sub2ind(size(mri.anatomy),8, 43, 15);
plotFFT(S_filtBP(vx,:),1/0.900,[0 0.1])


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



