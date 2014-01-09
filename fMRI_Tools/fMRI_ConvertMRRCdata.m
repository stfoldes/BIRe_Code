function MRI_Info = fMRI_ConvertMRRCdata(MRI_Info,varargin)
% Converts Raw MRI files from MRRC to NIFTI and/or DICOM format.
% Used before Freesurfer and SPM
% MRI_Info can be used. If not included, will use GUIs
% SEE: MRI_Info_Class.m
%
% INPUTS:
%   MRI_Info.raw_data_path: [OPTIONAL] path to where the raw data is. 
%                           If not defined will use UI
%   MRI_Info.epi_path:      [OPTIONAL] path to where the NIFTIs should go.
%                           If not defined will use dir one up from raw, with /NIFTI/
%
% VARARGIN:
%   save_NIFTI: flag to save (1) or remove (0) files [default to save]
%   save_DICOM: [default to remove]
%   DICOM_only: Does DICOM Only, no NIFTI
%
% 2012-08-06 (Stephen Foldes via Mike, Betsy, and Tim)
% UPDATES:
% 2012-12-12 Foldes: deletes DICOM folder at the end
% 2013-02-01 Foldes: Now a function
% 2013-02-09 Foldes: Removed 'script' from function name
% 2013-02-09 Foldes: ***VERSION 1.0-Maxwell***
% 2014-01-01 Foldes: MAJOR update w/ object, options etc.
% 2014-01-07 Foldes: MAJOR Cleaned up and now use epi_path

%% INITIALIZE
parms.save_NIFTI = 1;
parms.save_DICOM = 0; % delete DICOMs by default
parms.DICOM_only = 0;
parms = varargin_extraction(parms,varargin);

% Sets paths if haven't already
if ~exist('MRI_Info');MRI_Info=[];end
MRI_Info=fMRI_Prep_Paths(MRI_Info);

% path to raw data
if isempty(MRI_Info.raw_data_path)
    % Allows user to specify where the fMRI data is located
    MRI_Info.raw_data_path = uigetdir('Please select the path to the raw MRI data folder');
end

% No epi_path, then just use one up from raw, plus /NIFTI
if isempty(MRI_Info.epi_path)
    MRI_Info.epi_path = [dir_up(MRI_Info.raw_data_path) filesep 'NIFTI'];
end

%% DICOMS
disp('Relabeling Raw Data as DICOMs')
DICOM_folder = [MRI_Info.raw_data_path filesep 'DICOM'];
raw2dicom(MRI_Info.raw_data_path,DICOM_folder);

%% NIFTI
if parms.DICOM_only ~= 1
    % Convert DICOM to .nii
    disp('Convert DICOMs to NIFTI')
    dicom2nifti('4dnii',DICOM_folder,MRI_Info.epi_path);
end

%% Remove Files

if ~parms.save_DICOM
    rmdir(DICOM_folder,'s');
end

if ~parms.save_NIFTI && ~parms.DICOM_only
    rmdir(temp_NIFTI_folder,'s');
end


