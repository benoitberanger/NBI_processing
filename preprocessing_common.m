clear
clc

global subject_regex nbi

%% Prepare paths and regexp

chemin=[ pwd filesep 'img'];

suj = get_subdir_regex(chemin,subject_regex);
% suj = get_subdir_regex(chemin);
%to see the content
% char(suj)

%functional and anatomic subdir
par.regex.dfonc = '((MTMSTL)|(MTMSTR)|(miniblock_\d+)|(RETINO))$';
par.regex.dfonc_oposit_phase = '((MTMSTL)|(MTMSTR)|(miniblock_\d+)|(RETINO))_BLIP$';
par.regex.dfonc_all = '((MTMSTL)|(MTMSTR)|(miniblock)|(RETINO))';
par.regex.danat='(t1mpr)|(T1w)';

%for the preprocessing : Volume selecytion
par.regex.anat_file  = '^s.*nii'; %le nom generique du volume pour l'anat
par.regex.file  = '^f.*nii'; %le nom generique du volume pour les fonctionel

par.display=0;
par.run=1;


%% Get files paths

% dfonc = get_subdir_regex_multi(suj,par.regex.dfonc) % ; char(dfonc{:})
% dfonc_op = get_subdir_regex_multi(suj,par.regex.dfonc_oposit_phase)% ; char(dfonc_op{:})
% dfoncall = get_subdir_regex_multi(suj,{par.regex.dfonc,par.regex.dfonc_oposit_phase })% ; char(dfoncall{:})
% anat = get_subdir_regex_one(suj,par.regex.danat)% ; char(anat) %should be no warning

nbi = exam( chemin, subject_regex );

% --- 3DT1 ----------------------------------------------------------------
nbi.addSerie(par.regex.danat,'anat_T1',1)
nbi.getSerie('anat_T1').addVolume(par.regex.anat_file, 's', 1)

% --- Illusion in miniblocks ----------------------------------------------

% Normal
par.miniblock_reg = 'miniblock_\d+$';
nbi.addSerie(par.miniblock_reg,'run_miniblock',16)
nbi.getSerie('run_miniblock').addVolume(par.regex.file,'f',1)

% Opposite phase
par.miniblock_reg_BLIP = 'miniblock_\d+_BLIP$';
nbi.addSerie(par.miniblock_reg_BLIP,'runBLIP_miniblock',16)
nbi.getSerie('runBLIP_miniblock').addVolume(par.regex.file,'f',1)

% --- MTMST ---------------------------------------------------------------

% Left
par.MTMSTL_reg = 'MTMSTL$';
nbi.addSerie(par.MTMSTL_reg,'run_MTMSTL',1)
nbi.getSerie('run_MTMSTL').addVolume(par.regex.file,'f',1)

% Left opposite phase
par.MTMSTL_reg_BLIP = 'MTMSTL_BLIP$';
nbi.addSerie(par.MTMSTL_reg_BLIP,'runBLIP_MTMSTL',1)
nbi.getSerie('runBLIP_MTMSTL').addVolume(par.regex.file,'f',1)

% Right
par.MTMSTR_reg = 'MTMSTR$';
nbi.addSerie(par.MTMSTR_reg,'run_MTMSTR',1)
nbi.getSerie('run_MTMSTR').addVolume(par.regex.file,'f',1)

% Right opposite phase
par.MTMSTR_reg_BLIP = 'MTMSTR_BLIP$';
nbi.addSerie(par.MTMSTR_reg_BLIP,'runBLIP_MTMSTR',1)
nbi.getSerie('runBLIP_MTMSTR').addVolume(par.regex.file,'f',1)

% --- Retinotopy ----------------------------------------------------------

% Normal
par.retinotopy_reg = 'RETINO$';
nbi.addSerie(par.retinotopy_reg,'run_retinotopy',1)
nbi.getSerie('run_retinotopy').addVolume(par.regex.file,'f',1)

% Opposite phase
par.retinotopy_reg_BLIP = 'RETINO_BLIP$';
nbi.addSerie(par.retinotopy_reg_BLIP,'runBLIP_retinotopy',1)
nbi.getSerie('runBLIP_retinotopy').addVolume(par.regex.file,'f',1)


% Unzip if necessary
nbi.unzipVolume

% Reorder ?
% nbi.reorderSeries

% nbi.explore

dfonc    = nbi.getSerie('run_'   ).toJob   ;
dfonc_op = nbi.getSerie('runBLIP').toJob   ;
dfoncall = nbi.getSerie('run'    ).toJob   ;
anat     = nbi.getSerie('anat_T1').toJob(0);


%% Segment anat

% %anat segment
% anat = get_subdir_regex(suj,par.regex.danat)
% fanat = get_subdir_regex_files(anat,par.regex.anat_file,1)
%
% par.GM   = [1 0 1 0]; % Unmodulated / modulated / native_space dartel / import
% par.WM   = [1 0 1 0];
% j_segment = job_do_segment(fanat,par)
%
% %apply normalize on anat
% fy = get_subdir_regex_files(anat,'^y',1)
% fanat = get_subdir_regex_files(anat,'^ms',1)
% j_apply_normalise=job_apply_normalize(fy,fanat,par)


%anat segment
fanat = nbi.getSerie('anat_T1').getVolume('^s').toJob;

par.GM   = [1 0 1 0]; % Unmodulated / modulated / native_space dartel / import
par.WM   = [1 0 1 0];
j_segment = job_do_segment(fanat,par)

%apply normalize on anat
fy    = nbi.getSerie('anat_T1').addVolume('^y' ,'y' );
fanat = nbi.getSerie('anat_T1').addVolume('^ms','ms');
j_apply_normalise=job_apply_normalize(fy,fanat,par)
nbi.getSerie('anat_T1').addVolume('^wms','wms');



%% Brain extract

% ff=get_subdir_regex_files(anat,'^c[123]',3);
% fo=addsuffixtofilenames(anat,'/mask_brain');
% do_fsl_add(ff,fo)
% fm=get_subdir_regex_files(anat,'^mask_b',1); fanat=get_subdir_regex_files(anat,'^s.*nii',1);
% fo = addprefixtofilenames(fanat,'brain_');
% do_fsl_mult(concat_cell(fm,fanat),fo);


ff=nbi.getSerie('anat_T1').addVolume('^c[123]','c',3);
fo=addsuffixtofilenames(anat,'/mask_brain');
do_fsl_add(ff,fo);
fm=nbi.getSerie('anat_T1').addVolume('^mask_b','mask_brain',1);

fanat=nbi.getSerie('anat_T1').getVolume('^s').toJob;
fo = addprefixtofilenames(fanat,'brain_');
do_fsl_mult(concat_cell(fm,fanat),fo);
nbi.getSerie('anat_T1').addVolume('^brain_','brain_extract',1)


%% Preprocess fMRI runs

%realign and reslice
par.regex.file = '^f.*nii'; par.type = 'estimate_and_reslice';
j_realign_reslice = job_realign(dfonc,par)
nbi.getSerie('run_').addVolume('^rf','rf',1)

%realign and reslice opposite phase
par.regex.file = '^f.*nii'; par.type = 'estimate_and_reslice';
j_realign_reslice_op = job_realign(dfonc_op,par)
nbi.getSerie('runBLIP').addVolume('^rf','rf',1)

%topup and unwarp
par.regex.file = {'^rf.*nii'}; par.sge=0;
do_topup_unwarp_4D(dfoncall,par)
nbi.getSerie('run').addVolume('^utmeanf'  ,'utmeanf',1)
nbi.getSerie('run').addVolume('^utrf.*nii','utrf'   ,1)

%coregister mean fonc on brain_anat
% fanat = get_subdir_regex_files(anat,'^s.*nii$',1) % raw anat
% fanat = get_subdir_regex_files(anat,'^ms.*nii$',1) % raw anat + signal bias correction
% fanat = get_subdir_regex_files(anat,'^brain_s.*nii$',1) % brain mask applied (not perfect, there are holes in the mask)
fanat = nbi.getSerie('anat_T1').getVolume('^brain_extract').toJob;

par.type = 'estimate';
fmean = nbi.getSerie('run_miniblock_001').getVolume('^utmeanf').toJob;
% fo = get_subdir_regex_files(dfonc,'^utrf.*nii',1)
fo = nbi.getSerie('run').getVolume('^utrf').toJob;
j_coregister=job_coregister(fmean,fanat,fo,par)

%apply normalize
% fy = get_subdir_regex_files(anat,'^y',1)
% j_apply_normalize=job_apply_normalize(fy,fo,par)

