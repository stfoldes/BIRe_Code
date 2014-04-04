function MRI_Info=Prep_Paths(MRI_Info)
% Fill in paths for MRI_Info_Class
%
% 2012-08-06 Foldes
% UPDATES
% 2013-02-09 Foldes: ***VERSION 1.0-Maxwell***
% 2014-01-01 Foldes: This needs to be an object
% 2014-04-03 Foldes: Now part of MRI_Info_Class, renamed from fMRI_Prep_Paths

% path to spm
if isempty(MRI_Info.spm_path)
    % locate SPM function folder automatically (must be in the path)
    MRI_Info.spm_path= which('spm');
end

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

% path to scripts (SCRIPTS MUST BE IN MATLAB PATH)
if isempty(MRI_Info.FS_script_path)
    if ~isempty(strfind(MRI_Info.FS_script,filesep)) % script variable IS a path
        MRI_Info.FS_script_path = MRI_Info.FS_script;
    else % script variable is NOT a path, get it
        MRI_Info.FS_script_path = which(['' MRI_Info.FS_script '']);
    end
end
if isempty(MRI_Info.SPM2SUMA_script_path)
    if ~isempty(strfind(MRI_Info.SPM2SUMA_script,filesep)) % script variable IS a path
        MRI_Info.SPM2SUMA_script_path = MRI_Info.SPM2SUMA_script;
    else % script variable is NOT a path, get it
        MRI_Info.SPM2SUMA_script_path = which(['' MRI_Info.SPM2SUMA_script '']);
    end
end

% spm_path, raw_data_path, study_path all defined