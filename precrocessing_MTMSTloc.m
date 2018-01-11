clear
clc

global subject_regex

%% Prepare paths and regexp

chemin=[ pwd filesep 'img'];

suj = get_subdir_regex(chemin,subject_regex);
% suj = get_subdir_regex(chemin);
%to see the content
char(suj)

%functional and anatomic subdir
par.dfonc_reg='(MTMSTL)|(MTMSTR)$';
par.dfonc_reg_oposit_phase = '(MTMSTL)|(MTMSTR)+_BLIP$';
par.danat_reg='(t1mpr)|(T1w)';

%for the preprocessing : Volume selecytion
par.anat_file_reg  = '^s.*nii'; %le nom generique du volume pour l'anat
par.file_reg  = '^f.*nii'; %le nom generique du volume pour les fonctionel

par.display=0;
par.run=1;


%% Get files paths

dfonc = get_subdir_regex_multi(suj,par.dfonc_reg) % ; char(dfonc{:})
dfonc_op = get_subdir_regex_multi(suj,par.dfonc_reg_oposit_phase)% ; char(dfonc_op{:})
dfoncall = get_subdir_regex_multi(suj,{par.dfonc_reg,par.dfonc_reg_oposit_phase })% ; char(dfoncall{:})
anat = get_subdir_regex_one(suj,par.danat_reg)% ; char(anat) %should be no warning


% %% Segment anat
% 
% %anat segment
% anat = get_subdir_regex(suj,par.danat_reg)
% fanat = get_subdir_regex_files(anat,par.anat_file_reg,1)
% 
% par.GM   = [1 0 1 0]; % Unmodulated / modulated / native_space dartel / import
% par.WM   = [1 0 1 0];
% j_segment = job_do_segment(fanat,par)
% 
% %apply normalize on anat
% fy = get_subdir_regex_files(anat,'^y',1)
% fanat = get_subdir_regex_files(anat,'^ms',1)
% j_apply_normalise=job_apply_normalize(fy,fanat,par)
% 
% 
% %% Brain extract
% 
% ff=get_subdir_regex_files(anat,'^c[123]',3);
% fo=addsufixtofilenames(anat,'/mask_brain');
% do_fsl_add(ff,fo)
% fm=get_subdir_regex_files(anat,'^mask_b',1); fanat=get_subdir_regex_files(anat,'^s.*nii',1);
% fo = addprefixtofilenames(fanat,'brain_');
% do_fsl_mult(concat_cell(fm,fanat),fo);


%% Preprocess fMRI runs

%realign and reslice
par.file_reg = '^f.*nii'; par.type = 'estimate_and_reslice';
j_realign_reslice = job_realign(dfonc,par)

%realign and reslice opposite phase
par.file_reg = '^f.*nii'; par.type = 'estimate_and_reslice';
j_realign_reslice_op = job_realign(dfonc_op,par)

%topup and unwarp
par.file_reg = {'^rf.*nii'}; par.sge=0;
do_topup_unwarp_4D(dfoncall,par)

%coregister mean fonc on brain_anat
% fanat = get_subdir_regex_files(anat,'^s.*nii$',1) % raw anat
% fanat = get_subdir_regex_files(anat,'^ms.*nii$',1) % raw anat + signal bias correction
fanat = get_subdir_regex_files(anat,'^brain_s.*nii$',1) % brain mask applied (not perfect, there are holes in the mask)

par.type = 'estimate';
for nbs=1:length(suj)
    fmean(nbs) = get_subdir_regex_files(dfonc{nbs}(1),'^utmeanf');
end

fo = get_subdir_regex_files(dfonc,'^utrf.*nii',1)
j_coregister=job_coregister(fmean,fanat,fo,par)

%apply normalize
% fy = get_subdir_regex_files(anat,'^y',1)
% j_apply_normalize=job_apply_normalize(fy,fo,par)

%smooth the data
ffonc = get_subdir_regex_files(dfonc,'^utrf')
par.smooth = [6 6 6];
j_smooth=job_smooth(ffonc,par)