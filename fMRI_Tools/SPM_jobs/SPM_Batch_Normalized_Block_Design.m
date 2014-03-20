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
% 2013-11-14 Randazzo: Updated for normalized analysis
% 2014-03-07 Randazzo: Renamed to SPM_Batch_Normalized_Block_Design in accordance with Individual Block Design and revised code to be compatible with Script_Run_fMRI_Analysis

%%

% Loading parameters for this evaluation (see fMRI_Script_RunFunctionalAnalysis.m)
load('Master_Processing_Parameter.mat'); % Loads MRI_Info

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

%% ---PREPROCESS---

%% REALIGN

% number of files in NII (2014-01-06)
nFiles =length(spm_vol(current_epi));
tempFile = cell(nFiles,1);
for i = 1:nFiles
    niiStr = sprintf('.nii,%d',i);
    tempStr = [file_path filesep file_name niiStr];
    tempFile{i} = tempStr;
end


matlabbatch{1}.spm.spatial.realign.estimate.data = {tempFile}';

matlabbatch{1}.spm.spatial.realign.estimate.eoptions.quality = 0.9;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.sep = 4;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.fwhm = 5;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.rtm = 1;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.interp = 2;
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.wrap = [0 0 0];
matlabbatch{1}.spm.spatial.realign.estimate.eoptions.weight = '';

% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.quality = 0.9;
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.sep = 4;
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.fwhm = 5;
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.rtm = 0;
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.interp = 2;
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.wrap = [0 0 0];
% matlabbatch{1}.spm.spatial.realign.estwrite.eoptions.weight = {''};
% matlabbatch{1}.spm.spatial.realign.estwrite.roptions.which = [2 1];
% matlabbatch{1}.spm.spatial.realign.estwrite.roptions.interp = 4;
% matlabbatch{1}.spm.spatial.realign.estwrite.roptions.wrap = [0 0 0];
% matlabbatch{1}.spm.spatial.realign.estwrite.roptions.mask = 1;
% matlabbatch{1}.spm.spatial.realign.estwrite.roptions.prefix = 'r1';

%% COREGISTER

matlabbatch{2}.spm.spatial.coreg.estimate.ref = {[file_path filesep file_name '.nii,1']};
matlabbatch{2}.spm.spatial.coreg.estimate.source = {[MRI_Info.T1_file ',1']}; % <-- VARIABLE
matlabbatch{2}.spm.spatial.coreg.estimate.other = {''};
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.cost_fun = 'nmi';
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.sep = [4 2];
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.tol = [0.02 0.02 0.02 0.001 0.001 0.001 0.01 0.01 0.01 0.001 0.001 0.001];
matlabbatch{2}.spm.spatial.coreg.estimate.eoptions.fwhm = [7 7];


%% SEGMENTATION

matlabbatch{3}.spm.spatial.preproc.data(1) = cfg_dep;
matlabbatch{3}.spm.spatial.preproc.data(1).tname = 'Data';
matlabbatch{3}.spm.spatial.preproc.data(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{3}.spm.spatial.preproc.data(1).tgt_spec{1}(1).value = 'image';
matlabbatch{3}.spm.spatial.preproc.data(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{3}.spm.spatial.preproc.data(1).tgt_spec{1}(2).value = 'e';
matlabbatch{3}.spm.spatial.preproc.data(1).sname = 'Coregister: Estimate: Coregistered Images';
matlabbatch{3}.spm.spatial.preproc.data(1).src_exbranch = substruct('.','val', '{}',{2}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{3}.spm.spatial.preproc.data(1).src_output = substruct('.','cfiles');
matlabbatch{3}.spm.spatial.preproc.output.GM = [0 0 1];
matlabbatch{3}.spm.spatial.preproc.output.WM = [0 0 1];
matlabbatch{3}.spm.spatial.preproc.output.CSF = [0 0 0];
matlabbatch{3}.spm.spatial.preproc.output.biascor = 1;
matlabbatch{3}.spm.spatial.preproc.output.cleanup = 0;
matlabbatch{3}.spm.spatial.preproc.opts.tpm = {
                                               strcat([fileparts(MRI_Info.spm_path) filesep 'tpm' filesep 'grey.nii'])
                                               strcat([fileparts(MRI_Info.spm_path) filesep 'tpm' filesep 'white.nii'])
                                               strcat([fileparts(MRI_Info.spm_path) filesep 'tpm' filesep 'csf.nii'])
                                               };
matlabbatch{3}.spm.spatial.preproc.opts.ngaus = [2
                                                 2
                                                 2
                                                 4];
matlabbatch{3}.spm.spatial.preproc.opts.regtype = 'mni';
matlabbatch{3}.spm.spatial.preproc.opts.warpreg = 1;
matlabbatch{3}.spm.spatial.preproc.opts.warpco = 25;
matlabbatch{3}.spm.spatial.preproc.opts.biasreg = 0.0001;
matlabbatch{3}.spm.spatial.preproc.opts.biasfwhm = 60;
matlabbatch{3}.spm.spatial.preproc.opts.samp = 3;
matlabbatch{3}.spm.spatial.preproc.opts.msk = {''};

%% NORMALIZE 

matlabbatch{4}.spm.spatial.normalise.write.subj.matname(1) = cfg_dep;
matlabbatch{4}.spm.spatial.normalise.write.subj.matname(1).tname = 'Parameter File';
matlabbatch{4}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{4}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{4}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{4}.spm.spatial.normalise.write.subj.matname(1).tgt_spec{1}(2).value = 'e';
matlabbatch{4}.spm.spatial.normalise.write.subj.matname(1).sname = 'Segment: Norm Params Subj->MNI';
matlabbatch{4}.spm.spatial.normalise.write.subj.matname(1).src_exbranch = substruct('.','val', '{}',{3}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{4}.spm.spatial.normalise.write.subj.matname(1).src_output = substruct('()',{1}, '.','snfile', '()',{':'});
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1) = cfg_dep;
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1).tname = 'Images to Write';
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1).tgt_spec{1}(1).value = 'image';
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1).tgt_spec{1}(2).value = 'e';
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1).sname = 'Realign: Estimate: Realigned Images (Sess 1)';
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{4}.spm.spatial.normalise.write.subj.resample(1).src_output = substruct('.','sess', '()',{1}, '.','cfiles');
matlabbatch{4}.spm.spatial.normalise.write.roptions.preserve = 0;
matlabbatch{4}.spm.spatial.normalise.write.roptions.bb = [-78 -112 -50
                                                          78 76 85];
matlabbatch{4}.spm.spatial.normalise.write.roptions.vox = [2 2 2];
matlabbatch{4}.spm.spatial.normalise.write.roptions.interp = 3;
matlabbatch{4}.spm.spatial.normalise.write.roptions.wrap = [0 0 0];
matlabbatch{4}.spm.spatial.normalise.write.roptions.prefix = 'w';

%% SMOOTHING

matlabbatch{5}.spm.spatial.smooth.data(1) = cfg_dep;
matlabbatch{5}.spm.spatial.smooth.data(1).tname = 'Images to Smooth';
matlabbatch{5}.spm.spatial.smooth.data(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{5}.spm.spatial.smooth.data(1).tgt_spec{1}(1).value = 'image';
matlabbatch{5}.spm.spatial.smooth.data(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{5}.spm.spatial.smooth.data(1).tgt_spec{1}(2).value = 'e';
matlabbatch{5}.spm.spatial.smooth.data(1).sname = 'Normalise: Write: Normalised Images (Subj 1)';
matlabbatch{5}.spm.spatial.smooth.data(1).src_exbranch = substruct('.','val', '{}',{4}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{5}.spm.spatial.smooth.data(1).src_output = substruct('()',{1}, '.','files');
matlabbatch{5}.spm.spatial.smooth.fwhm = [10 10 10];
matlabbatch{5}.spm.spatial.smooth.dtype = 0;
matlabbatch{5}.spm.spatial.smooth.im = 0;
matlabbatch{5}.spm.spatial.smooth.prefix = 's';


%% fMRI MODEL SPECIFICATION

matlabbatch{6}.spm.stats.fmri_spec.dir = {file_path};
matlabbatch{6}.spm.stats.fmri_spec.timing.units = 'scans';
matlabbatch{6}.spm.stats.fmri_spec.timing.RT = MRI_Info.ExpDef_TR; % <-- VARIABLE;
matlabbatch{6}.spm.stats.fmri_spec.timing.fmri_t = 16;
matlabbatch{6}.spm.stats.fmri_spec.timing.fmri_t0 = 1;
matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1) = cfg_dep;
matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1).tname = 'Scans';
matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1).tgt_spec{1}(1).value = 'image';
matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1).tgt_spec{1}(2).value = 'e';
matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1).sname = 'Smooth: Smoothed Images';
matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1).src_exbranch = substruct('.','val', '{}',{5}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{6}.spm.stats.fmri_spec.sess.scans(1).src_output = substruct('.','files');
                                                    
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.name = 'Task';
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.onset = MRI_Info.ExpDef_event_onsets;% <-- VARIABLE
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.duration = MRI_Info.ExpDef_event_duration;% <-- VARIABLE
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.tmod = 0;
matlabbatch{6}.spm.stats.fmri_spec.sess.cond.pmod = struct('name', {}, 'param', {}, 'poly', {});
matlabbatch{6}.spm.stats.fmri_spec.sess.multi = {''};
matlabbatch{6}.spm.stats.fmri_spec.sess.regress = struct('name', {}, 'val', {});
matlabbatch{6}.spm.stats.fmri_spec.sess.multi_reg(1) = cfg_dep;
matlabbatch{6}.spm.stats.fmri_spec.sess.multi_reg(1).tname = 'Multiple regressors';
matlabbatch{6}.spm.stats.fmri_spec.sess.multi_reg(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{6}.spm.stats.fmri_spec.sess.multi_reg(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{6}.spm.stats.fmri_spec.sess.multi_reg(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{6}.spm.stats.fmri_spec.sess.multi_reg(1).tgt_spec{1}(2).value = 'e';
matlabbatch{6}.spm.stats.fmri_spec.sess.multi_reg(1).sname = 'Realign: Estimate: Realignment Param File (Sess 1)';
matlabbatch{6}.spm.stats.fmri_spec.sess.multi_reg(1).src_exbranch = substruct('.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{6}.spm.stats.fmri_spec.sess.multi_reg(1).src_output = substruct('.','sess', '()',{1}, '.','rpfile');
matlabbatch{6}.spm.stats.fmri_spec.sess.hpf = 60;
matlabbatch{6}.spm.stats.fmri_spec.fact = struct('name', {}, 'levels', {});
matlabbatch{6}.spm.stats.fmri_spec.bases.hrf.derivs = [0 0];
matlabbatch{6}.spm.stats.fmri_spec.volt = 1;
matlabbatch{6}.spm.stats.fmri_spec.global = 'None';
matlabbatch{6}.spm.stats.fmri_spec.mask = {''};
matlabbatch{6}.spm.stats.fmri_spec.cvi = 'AR(1)';


%% MODEL ESTIMATION

matlabbatch{7}.spm.stats.fmri_est.spmmat(1) = cfg_dep;
matlabbatch{7}.spm.stats.fmri_est.spmmat(1).tname = 'Select SPM.mat';
matlabbatch{7}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{7}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{7}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{7}.spm.stats.fmri_est.spmmat(1).tgt_spec{1}(2).value = 'e';
matlabbatch{7}.spm.stats.fmri_est.spmmat(1).sname = 'fMRI model specification: SPM.mat File';
matlabbatch{7}.spm.stats.fmri_est.spmmat(1).src_exbranch = substruct('.','val', '{}',{6}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{7}.spm.stats.fmri_est.spmmat(1).src_output = substruct('.','spmmat');
matlabbatch{7}.spm.stats.fmri_est.method.Classical = 1;


%% MODEL (Contrast Manager)
matlabbatch{8}.spm.stats.con.spmmat(1) = cfg_dep;
matlabbatch{8}.spm.stats.con.spmmat(1).tname = 'Select SPM.mat';
matlabbatch{8}.spm.stats.con.spmmat(1).tgt_spec{1}(1).name = 'filter';
matlabbatch{8}.spm.stats.con.spmmat(1).tgt_spec{1}(1).value = 'mat';
matlabbatch{8}.spm.stats.con.spmmat(1).tgt_spec{1}(2).name = 'strtype';
matlabbatch{8}.spm.stats.con.spmmat(1).tgt_spec{1}(2).value = 'e';
matlabbatch{8}.spm.stats.con.spmmat(1).sname = 'Model estimation: SPM.mat File';
matlabbatch{8}.spm.stats.con.spmmat(1).src_exbranch = substruct('.','val', '{}',{7}, '.','val', '{}',{1}, '.','val', '{}',{1});
matlabbatch{8}.spm.stats.con.spmmat(1).src_output = substruct('.','spmmat');
matlabbatch{8}.spm.stats.con.consess{1}.tcon.name = 'Move';
matlabbatch{8}.spm.stats.con.consess{1}.tcon.convec = [1 0 0 0 0 0 0 0];
matlabbatch{8}.spm.stats.con.consess{1}.tcon.sessrep = 'none';
matlabbatch{8}.spm.stats.con.consess{2}.fcon.name = 'MotionArtifact';
matlabbatch{8}.spm.stats.con.consess{2}.fcon.convec = {
                                                       [0 1 0 0 0 0 0 0
                                                       0 0 1 0 0 0 0 0
                                                       0 0 0 1 0 0 0 0]
                                                       }';
matlabbatch{8}.spm.stats.con.consess{2}.fcon.sessrep = 'none';
matlabbatch{8}.spm.stats.con.delete = 0;

