% Script for fMRI SPM Analysis Performing Preprocessing, Modeling, and Co-registering
%
% Requires Master_Processing_Parameter.mat from fMRI_Script_RunFunctionalAnalysis.m (requires: MRI_Info.study_path and MRI_Info.file4spm_processing); MRI_Info.T1_file is optional, defaults finding T1.nii within MRI_Info.study_path)
%
% Job configuration created by cfg_util (rev $Rev: 4252 $)
%
% 2012-07-12 (Foldes and Randazzo)
% UPDATES:
% 2012-08-07 SF: Made more robust to any experiment and differnt file organizations, added SUMA Coreg, uses MRI_Info struct
% 2012-12-04 Foldes: Will automatically SEARCH for *T1.nii file from MRI_Info.study_path. T1-path is now the T1 file name w/ path. Also removed SUMA coreg b/c it is redundent (just copy regular coreg)
% 2013-02-01 Alan: Generates nii file list. Hardcoded to be 90 for now.
% 2013-12-02 Randazzo: findFiles

%%

% Loading parameters for this evaluation (see fMRI_Script_RunFunctionalAnalysis.m)
load('Master_Processing_Parameter.mat'); % Loads MRI_Info

% Set path to the study folder
file_path = [MRI_Info.study_path '/NIFTI/' MRI_Info.file4spm_processing '/'];

% Find T1 to use if not already defined (hopefully it is).
if ~isfield(MRI_Info,'T1_file') || isempty(MRI_Info.T1_file)
    % Search for the T1 from the study path UPDATED 2012-12-04 Foldes
    MRI_Info.T1_file = cell2mat(find_Files('*T1.nii', MRI_Info.study_path, 1));
    if isempty(MRI_Info.T1_file)
       error('NO T1.nii FOUND') 
    end
end

%% ---PREPROCESS---

% Loop through all *.nii files
nFiles = 90; % Pre-determined
tempFile = cell(nFiles,1);
for i = 1:nFiles
    niiStr = sprintf('.nii,%d',i);
    tempStr = strcat(file_path,MRI_Info.file4spm_processing,niiStr);
    tempFile{i} = tempStr;
end

matlabbatch{1}.spm.spatial.realign.estwrite.data = {tempFile}';

matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r1';

%% PREPROCESS (Smooth)
matlabbatch{2}.spm.spatial.smooth.data(1) = cfg_dep;
matlabbatch{2}.spm.spatial.smooth.data(1).tname = 'Images to Smooth';
matlabbatch{2}.spm.spatial.smooth.data(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{2}.spm.spatial.smooth.data(1).tgt_spec{1}(1).value = 'image';
matlabbatch{2}.spm.spatial.smooth.data(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{2}.spm.spatial.smooth.data(1).tgt_spec{1}(2).value = 'e';
matlabbatch{2}.spm.spatial.smooth.data(1).sname = 'Realign: Estimate & Reslice: Resliced Images (Sess 1)';
matlabbatch{2}.spm.spatial.smooth.data(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{2}.spm.spatial.smooth.data(1).src_output = substruct('.','sess', '()',{1}, '.','rfiles');
matlabbatch{2}.spm.spatial.smooth.fwhm = [4 4 4];
matlabbatch{2}.spm.spatial.smooth.dtype = 0;
matlabbatch{2}.spm.spatial.smooth.im = 0;
matlabbatch{2}.spm.spatial.smooth.prefix = 's1';

%% MODEL Estimation

matlabbatch{3}.spm.stats.fmri_spec.dir = {file_path};
matlabbatch{3}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{3}.spm.stats.fmri_spec.timing.RT = 2;
matlabbatch{3}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{3}.spm.stats.fmri_spec.timing.fmri_t0 = 1;

% Loop through all *.nii files
nFiles = 90; % Pre-determined
tempFile = cell(nFiles,1);
for i = 1:nFiles
    niiStr = sprintf('.nii,%d',i);
    tempStr = strcat(file_path,'s1r1',MRI_Info.file4spm_processing ,niiStr);
    tempFile{i} = tempStr;
end

matlabbatch{3}.spm.stats.fmri_spec.sess.scans = tempFile;
                                                    
%%
matlabbatch{3}.spm.stats.fmri_spec.sess.cond.name = 'Task';
matlabbatch{3}.spm.stats.fmri_spec.sess.cond.onset = [10
                                                      30
                                                      50
                                                      70];
matlabbatch{3}.spm.stats.fmri_spec.sess.cond.duration = 10;
matlabbatch{3}.spm.stats.fmri_spec.sess.cond.tmod = 0;
matlabbatch{3}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{3}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{3}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{3}.spm.stats.fmri_spec.sess.multi_reg = {strcat(file_path,'rp_',MRI_Info.file4spm_processing ,'.txt')};
matlabbatch{3}.spm.stats.fmri_spec.sess.hpf = 60;
matlabbatch{3}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{3}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{3}.spm.stats.fmri_spec.volt = 1;
matlabbatch{3}.spm.stats.fmri_spec.global = 'None';
matlabbatch{3}.spm.stats.fmri_spec.mask = {''};
matlabbatch{3}.spm.stats.fmri_spec.cvi = 'AR(1)';

%%
matlabbatch{4}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
matlabbatch{4}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
matlabbatch{4}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{4}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{4}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{4}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
matlabbatch{4}.spm.stats.fmri_est.spmmat(1).sname = 'fMRI model specification: SPM.mat File';
matlabbatch{4}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{4}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
matlabbatch{4}.spm.stats.fmri_est.method.Classical = 1;

%% MODEL (Contrast Manager)
matlabbatch{5}.spm.stats.con.spmmat(1) = cfg_dep;
matlabbatch{5}.spm.stats.con.spmmat(1).tname = 'Select SPM.mat';
matlabbatch{5}.spm.stats.con.spmmat(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{5}.spm.stats.con.spmmat(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{5}.spm.stats.con.spmmat(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{5}.spm.stats.con.spmmat(1).tgt_spec{1}(2).value = 'e';
matlabbatch{5}.spm.stats.con.spmmat(1).sname = 'Model estimation: SPM.mat File';
matlabbatch{5}.spm.stats.con.spmmat(1).src_exbranch = substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{5}.spm.stats.con.spmmat(1).src_output = substruct('.','spmmat');
matlabbatch{5}.spm.stats.con.consess{1}.tcon.name = 'Move';
matlabbatch{5}.spm.stats.con.consess{1}.tcon.convec = [1 0 0 0 0 0 0 0];
matlabbatch{5}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.consess{2}.fcon.name = 'MotionArtifact';
matlabbatch{5}.spm.stats.con.consess{2}.fcon.convec = {
                                                       [0 1 0 0 0 0 0 0
                                                       0 0 1 0 0 0 0 0
                                                       0 0 0 1 0 0 0 0]
                                                       }';
matlabbatch{5}.spm.stats.con.consess{2}.fcon.sessrep = 'none';
matlabbatch{5}.spm.stats.con.delete = 0;

%% COREGISTER
matlabbatch{6}.spm.spatial.coreg.estwrite.ref = {strcat(MRI_Info.T1_file ,',1')}; % UPDATED 2012-12-04 FOLDES
matlabbatch{6}.spm.spatial.coreg.estwrite.source = {strcat(file_path,'mean',MRI_Info.file4spm_processing ,'.nii,1')};
matlabbatch{6}.spm.spatial.coreg.estwrite.other = {strcat(file_path,'spmT_0001.img,1')};
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.interp = 1;
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.prefix = 'coreg';
