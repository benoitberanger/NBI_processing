clear
clc

%% Path & files

maindir = fullfile(pwd,'test','func');
volumename = 'sutrf395_S21_MBB3_ep2d_TR900_3iso_RETINO.nii';
stimname   = 'TOMO_Retinotopy_MRI_1.mat';

ffunc = get_subdir_regex_files(maindir, volumename,1);
sfunc = get_subdir_regex_files(maindir, stimname  ,1);
rfunc = get_subdir_regex_files(maindir, 'rp.*txt',1);

%% Generate Sine and Consine

V = spm_vol(char(ffunc));
NrVolumes = length(V);

TR = 1.000;

l = load(char(sfunc));
TimeForTurn = l.DataStruct.TaskData.EP.Data{2,3}; % seconds, 48s
w = 2*pi/TimeForTurn/TR; % angular speed in rad/volume (not rad/second)

Scw  = sin( w * (1                      : (TimeForTurn/TR)*(4  )));
Sccw = sin(-w * ((TimeForTurn/TR)*(4  ) : (TimeForTurn/TR)*(4+4)));
S = [Scw Sccw];
S = [ S zeros(1,NrVolumes-length(S)) ];

Ccw  = cos( w * (1                      : (TimeForTurn/TR)*(4  )));
Cccw = cos(-w * ((TimeForTurn/TR)*(4  ) : (TimeForTurn/TR)*(4+4)));
C = [Ccw Cccw];
C = [ C zeros(1,NrVolumes-length(C)) ];


%% Prepare multiple regressor

rp = load(char(rfunc));

R = [S(:) C(:) rp];

names = { 'sine' 'cosine' 'R1' 'R2' 'R3' 'R4' 'R5' 'R6' };

save(fullfile(maindir,'multi_reg'),'R','names');
