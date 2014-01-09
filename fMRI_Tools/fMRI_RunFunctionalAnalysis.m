% MRI_Info = fMRI_RunFunctionalAnalysis(MRI_Info[OPTIONAL])
% Script to run SPM for standard Functional Analysis
% Requires T1 from Freesurfer and NIFTI files (see fMRI_Script_ConvertMRRCdata)
% 
% MRI_Info.spm_run_list[OPTIONAL] = run name or cell-array of run names to process (ie. NIFIT/folder_name). Used for running single runs
%     If empty or not a field, program will automatically find all runs to process in MRI_Info.study_path/NIFTI/ (excludes MPRAGE)
%
% 2012-08-06 (Foldes and Randazzo - via Betsy and Tim)
% UPDATES:
% 2012-12-04 Foldes: SUMA fMRI is now a simple copy of coreg since the SPM part for SUMA was redundent. T1.nii is now automatically found within study_path if no T1 file is given in MRI_Info. Can now have a run list for spm to run (optional)
% 2012-12-12 Foldes: Search for *T1.nii if not defined in MRI_Info within 
% 2013-02-01 Foldes: Now a function
% 2013-02-05 Foldes: /ProcessedData folder renamed /FunctionalData
% 2013-02-09 Foldes: Removed 'script' from function name
% 2013-02-10 Foldes: ***VERSION 1.0-Maxwell***
% 2013-12-02 Randazzo: findFiles new spelling
% 2014-01-06 Foldes: find_Files replaced w/ search_dir

function MRI_Info = fMRI_RunFunctionalAnalysis(MRI_Info)

%% Standard setup

% Sets paths if haven't already
if ~exist('MRI_Info');MRI_Info=[];end
MRI_Info=fMRI_Prep_Paths(MRI_Info);

% Find T1 to use if not already defined. [2012-12-12 Foldes]
if ~isfield(MRI_Info,'T1_file') || isempty(MRI_Info.T1_file)
    % Search for the T1 from the study path
    MRI_Info.T1_file = cell2mat(search_dir(MRI_Info.study_path,'*T1.nii'));
    if isempty(MRI_Info.T1_file)
       error('NO T1.nii FOUND') 
    end
end

%% nii files to process

% unless you've specified the files to do spm on, then go ahead and find all valid
if ~isfield(MRI_Info,'spm_run_list') || isempty(MRI_Info.spm_run_list) || strcmpi(MRI_Info.spm_run_list,'all')
    
    NIFTI_dir_info = dir([MRI_Info.study_path '/NIFTI']);
    
    clear run_name_list
    % Note: This can include hidden files (start with .)
    for ifile=3:length(NIFTI_dir_info)
        run_name_list{ifile-2} = NIFTI_dir_info(ifile).name;
    end
else % spm_run_list is good to use UPDATED 2012-12-04 Foldes
    if ~iscell(MRI_Info.spm_run_list) % if its not a cell, make it one
        run_name_list{1} = MRI_Info.spm_run_list;
    else % already a cell
        run_name_list = MRI_Info.spm_run_list;
    end
end

%% Create a job-document to run each scan

% List of open inputs
jobfile = {which('Final_Script_job.m')};
jobs = repmat(jobfile, 1, 1);
inputs = cell(0, 1);

% RUN THIS FIRST?
spm_jobman('initcfg');

%Cycles through all movements and body parts
for ifile = 1:length(run_name_list)
    MRI_Info.file4spm_processing = cell2mat(run_name_list(ifile));
    
    if isempty(regexp(MRI_Info.file4spm_processing,'MPRAGE')) % Don't do for MPRAGE
        
        % Printing the MRI_Info.file4spm_processing the program is on
        disp(' ')
        disp('**************************************************************')
        disp(['***' MRI_Info.file4spm_processing ' @fMRI_RunFunctionalAnalysis***'])
        disp('**************************************************************')
        
        current_file_path = [MRI_Info.study_path '/NIFTI/' MRI_Info.file4spm_processing];

        exist_path = exist(current_file_path,'dir');
        %Checking for the file
        if exist_path == 7
            try
                save('Master_Processing_Parameter.mat','MRI_Info'); % spm_jobman will read in Final_Script_job.m, which will read in Master_Processing_Parameter.mat
                spm('defaults', 'FMRI');
                spm_jobman('serial',jobs, '', inputs{:});
                
                % Pull out the file to the study folder (with rename)
                if exist([MRI_Info.study_path '/FunctionalData'],'dir')~=7
                    mkdir([MRI_Info.study_path '/FunctionalData'])
                end
                copyfile([current_file_path '/coregspmT_0001.hdr'], ...
                    [MRI_Info.study_path '/FunctionalData/fMRI_' ...
                    MRI_Info.file4spm_processing(5:end) '.hdr'])
                copyfile([current_file_path '/coregspmT_0001.img'], ...
                    [MRI_Info.study_path '/FunctionalData/fMRI_' ...
                    MRI_Info.file4spm_processing(5:end) '.img']);
                
                % UPDATED 2012-12-04 FOLDES: Changed to a simple copy of coreg since the SPM part for SUMA was redundent
                copyfile([current_file_path '/coregspmT_0001.hdr'], ...
                    [MRI_Info.study_path '/FunctionalData/fMRI_suma_' ...
                    MRI_Info.file4spm_processing(5:end) '.hdr']);
                copyfile([current_file_path '/coregspmT_0001.img'], ...
                    [MRI_Info.study_path '/FunctionalData/fMRI_suma_' ...
                    MRI_Info.file4spm_processing(5:end) '.img']);
                
            catch 
                warning(['Failure with SPM processing of: ' MRI_Info.file4spm_processing ' (could be an error with copying the files) @fMRI_RunFunctionalAnalysis'])
            end
        else
            error('Paths are wrong for SPM data @fMRI_RunFunctionalAnalysis')
        end
        
    end % Dont do for MPRAGE
end
