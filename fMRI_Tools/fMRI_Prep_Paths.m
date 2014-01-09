% fMRI_Prep_Paths
% Creates MRI_Info structure used in all of my code
% if MRI_Info is not defined, it will be
%
% 2012-08-06 Foldes
% UPDATES
% 2013-02-09 Foldes: ***VERSION 1.0-Maxwell***
% 2014-01-01 Foldes: This needs to be an object

function MRI_Info=fMRI_Prep_Paths(MRI_Info)

%% Initialize MRI_Info if not already done
if ~exist('MRI_Info'); MRI_Info=[];end

% path to spm
if isempty(MRI_Info.spm_path)
    % locate SPM function folder automatically (must be in the path)
    MRI_Info.spm_path= which('spm');
end

% % path to raw data
% if ~isfield(MRI_Info,'raw_data_path') || isempty(MRI_Info.raw_data_path)
%     % Allows user to specify where the fMRI data is located
%     if ~exist('raw_data_path') || isempty(raw_data_path)
%         MRI_Info.raw_data_path = uigetdir('Please select the path to the raw MRI data folder');
%     end
% end

% path to study
if isempty(MRI_Info.study_path)
    % find the path to the parent folder (hopefully the subject's folder)
    current_dir = pwd;
    
    if ~isempty(MRI_Info.raw_data_path)
        
        cd(MRI_Info.raw_data_path); cd('..')
        MRI_Info.study_path = pwd;
        cd(current_dir)
        
    else % GUI
        MRI_Info.study_path = uigetdir(pwd,'Please select the path to the study folder (folder just before raw)');
    end
end

% spm_path, raw_data_path, study_path all defined