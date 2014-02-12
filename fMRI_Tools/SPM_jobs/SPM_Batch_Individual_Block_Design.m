% Programatic Batch for SPM for standard individual fMRI analysis
%   SPM Analysis Performing Preprocessing, Modeling, and Co-registering
% 
% REQUIRES:
%   Master_Processing_Parameter.mat must have MRI_Info and current_epi
%   current_epi:                Full path to the current epi
%   MRI_Info.
%   .T1_file:                   [OPTIONAL] Name and path for the T1.nii. If empty, will use a GUI.
%   .T1_auto_find:              [OPTIONAL] If =1, will look through MRI_Info.study_path for a T1.nii
%   SPM variables:
%       .ExpDef_TR =             0; % TR 'Interscan interval'
%       .ExpDef_event_onsets =   [0]; % vector of when conditions/events happen, in scan # (hardcoded, but can be changed)
%       .ExpDef_event_duration = 0; % num scans for the event/condition to happen
%
% OUTPUT
%   coregspmT_0001.img
%   SPM.mat
%
% LATER
%   Include stimulus timing etc
%
% 2012-07-12 (Foldes and Randazzo)
% UPDATES:
% 2012-08-07 SF: Made more robust to any experiment and differnt file organizations, added SUMA Coreg, uses MRI_Info struct
% 2012-12-04 Foldes: Will automatically SEARCH for *T1.nii file from MRI_Info.study_path. T1-path is now the T1 file name w/ path. Also removed SUMA coreg b/c it is redundent (just copy regular coreg)
% 2013-02-01 Alan: Generates nii file list. Hardcoded to be 90 for now.
% 2013-12-02 Randazzo: findFiles
% 2014-01-01 Foldes: MAJOR Branch
% 2014-01-06 Foldes: Finds number of nii files, uses task design, T1 found here

%%

% Loading parameters for this evaluation (see fMRI_Script_RunFunctionalAnalysis.m)
load('Master_Processing_Parameter.mat'); % Loads MRI_Info and current_epi

[file_path,file_name] = fileparts(current_epi);

% Figure out the T1 
if isempty(MRI_Info.T1_file)
    % Search for the T1 from the study path
    possible_T1s = search_dir(MRI_Info.study_path,'*T1.nii');
    if isempty(possible_T1s)
        error('No T1 found')
    end
    T1_guess = cell2mat(possible_T1s(1));
    
    if MRI_Info.T1_auto_find == 1
        MRI_Info.T1_file = T1_guess;
    else
        [FileName,PathName] = uigetfile('*.nii','Select T1 (No T1 file given in MRI_Info.T1_file)',T1_guess);
        MRI_Info.T1_file = [PathName filesep FileName];
    end
    
    if isempty(MRI_Info.T1_file)
        error('NO T1.nii FOUND')
    end
end

%% Realign
% Loop through all *.nii files

% number of files in NII (2014-01-06)
nFiles =length(spm_vol(current_epi));
tempFile = cell(nFiles,1);
for i = 1:nFiles
    niiStr = sprintf('.nii,%d',i);
    tempStr = [file_path filesep file_name niiStr];
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
matlabbatch{3}.spm.stats.fmri_spec.timing.RT = MRI_Info.ExpDef_TR; % <-- VARIABLE
matlabbatch{3}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{3}.spm.stats.fmri_spec.timing.fmri_t0 = 1;

% Loop through all *.nii files
tempFile = cell(nFiles,1);
for i = 1:nFiles
    niiStr = sprintf('.nii,%d',i);
    tempStr = [file_path filesep 's1r1' file_name niiStr];
    tempFile{i} = tempStr;
end
matlabbatch{3}.spm.stats.fmri_spec.sess.scans = tempFile;

matlabbatch{3}.spm.stats.fmri_spec.sess.cond.name = 'Task';
matlabbatch{3}.spm.stats.fmri_spec.sess.cond.onset = MRI_Info.ExpDef_event_onsets;% <-- VARIABLE
matlabbatch{3}.spm.stats.fmri_spec.sess.cond.duration = MRI_Info.ExpDef_event_duration;% <-- VARIABLE

matlabbatch{3}.spm.stats.fmri_spec.sess.cond.tmod = 0;
matlabbatch{3}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{3}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{3}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{3}.spm.stats.fmri_spec.sess.multi_reg = {[file_path filesep 'rp_' file_name '.txt']};
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
matlabbatch{6}.spm.spatial.coreg.estwrite.ref = {[MRI_Info.T1_file ',1']}; % <-- VARIABLE
matlabbatch{6}.spm.spatial.coreg.estwrite.source = {[file_path filesep 'mean' file_name '.nii,1']};
matlabbatch{6}.spm.spatial.coreg.estwrite.other = {[file_path filesep 'spmT_0001.img,1']}; % <--- This could be a stats image dependency, but only works if hardcoded to spmT filename due to bug
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.cost_fun = 'nmi';
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.sep = [4 2];
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{6}.spm.spatial.coreg.estwrite.eoptions.fwhm = [7 7];
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.interp = 1;
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.wrap = [0 0 0];
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.mask = 0;
matlabbatch{6}.spm.spatial.coreg.estwrite.roptions.prefix = 'coreg';
