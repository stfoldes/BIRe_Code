% fMRI MASTER Script for MRRC data using Maxwell-computer (MAC) (v1.0-Maxwell)
%
% STEPS:
%  1. Convert MRRC data into NIFTI (and DICOM) formats
%  2. Run Freesurfer reconstruction (creates surfaces), convert FS surfaces into SUMA surfaces, generate BEM (for MEG)
%  3. Run functional analysis with SPM (creates /FunctionalData folder with .img/.hdr Analyze files)
%  4. Prepare functional SPM volumes for SUMA surface rendering: Convert .img files to NIFTI and Create a surface for SUMA
%  5. Sends email of completion
%
% Improvements:
%  0. Transfer and select raw data folder (for advanced users, MRI_Info can be populated instead)
%  5. Saves processed data to server and sends email of completion (/Freesurfer_Reconstruction and /FunctionalData)
%
% Make sure your folder structure follows this scheme:
%   "\Data\SUBJECT_ID\fMRI\SESSION_INFO\Raw_Data" where SUBJECT_ID and SESSION_INFO can be whatever
%
% 2012-08-06 [Foldes]
% UPDATES:
% 2012-08-08 Foldes: Added UNIX SUMA scripts
% 2012-11-13 Foldes: Combine old-steps 2 and 3 (FS recon and FS->SUMA convert), added commenting
% 2013-01-04 Foldes: Updated to work on MAC(Maxwell) and with copying to and from server
% 2013-02-05 Foldes: All scripts turned into functions (including unix). Begining intial validation
% 2013-02-10 Foldes: ***VERSION 1.0-Maxwell*** (compatible with MACs w/ paths for Maxwell)

clear
clc

%% Initial Setup of 

    % MRI_Info is a container for all information needed for MRI and fMRI processing in this code.
    % MRI_Info can be automatically generated (if left out or left empty). fMRI_Prep_Paths.m will fill it in
    % For advanced users, you can specify items such as:
    %   MRI_Info.subject_id = 'NC01';
    %   MRI_Info.raw_data_path = ['/Users/hrnel/Data/' MRI_Info.subject_id '/fMRI/Initial/Raw_Data'];
    % Can also set paths to software, T1, etc. if you are doing unique processing.

    %===LEAVE BLANK FOR BASIC USE===
    MRI_Info = [];
    %===============================

    %===========================
    %===REMOVER FOR BASIC USE===
    %===========================
        % Define subject
        MRI_Info.subject_id = 'NC06';
        MRI_Info.raw_data_path = ['/Users/hrnel/Data/' MRI_Info.subject_id '/fMRI/Initial/Raw_Data'];
        % MRI_Info.spm_run_list = 'epi_Rt_hand_grasp_attempt'; % can run select functional analysis only, see fMRI_Script_RunFunctionalAnalysis.m
    %===========================

    % Email Parameters
    Email.to='stephen.foldes@gmail.com'; % Email address to send completion notice
    Email.from = 'PittBMI@gmail.com'; % sending email address
    Email.password = [80 105 116 116 66 77 73 49 57];
    Email.stmp_server='smtp.gmail.com'; % SMTP server address (depends on your location), usually 'smtp-server.neo.rr.com' or 'smtp.case.edu' or 'smtp.gmail.com';

    
    % Automatically sets some standard paths if haven't already
    MRI_Info=fMRI_Prep_Paths(MRI_Info);
    
    tic    
%% STEP 0: Copy files from server to local, if needed

    %***THIS ISN'T WORKING!!!***
    % if isfield(MRI_Info,'server_data_path') && ~isempty(MRI_Info.server_data_path)
    %     copyfile(MRI_Info.server_data_path,MRI_Info.raw_data_path)
    %     unix(['cp -R ' MRI_Info.server_data_path ' ' MRI_Info.raw_data_path])
    % end

%% STEP 1: Convert Raw Data into NIFTI

    % Converts the raw data first to DICOM and then to NIFTI
    MRI_Info=fMRI_ConvertMRRCdata(MRI_Info);
    % WHAT IT MAKES: NIFTI and DICOM folders

%% STEP 2: Construct brain and head surfaces via Freesurfer
   
    % ***ADD CHECK FOR DATA EXIST***

    % Running Unix function for Freesurfer Reconstruction and SUMA_Spec
    eval(['!' '/Users/hrnel/Documents/MATLAB/meg_analysis/fMRI_Tools/FreesurferReconstruction_Maxwell.sh ' MRI_Info.subject_id ' ' MRI_Info.study_path]);
    
    Email.subject=['Freesurfer done for ' MRI_Info.subject_id]; % you can use the command "mfilename" to put in the current mfiles name, also datestr(now,'yy-mm-dd_HHMM') for current time
    Email.body=['Freesurfer done for ' MRI_Info.subject_id ' ' 10 ...
        'Finished at ' datestr(now,'yyyy-mm-dd HH:MM') ' ' 10 ...
        'Took: ' num2str((toc/60)/60) ' Hrs'];  % 10 in the body is a carriage return (just 10, not a string).
    Send_Email(Email);
    % ===CAN STOP HERE IF ONLY ANATOMICAL===

%% STEP 3: Perform SPM on fMRI data

    % Needs T1 from Freesurfer
    MRI_Info=fMRI_RunFunctionalAnalysis(MRI_Info);

%% STEP 4: Convert functional data (via SPM) to SUMA surfaces

    % ***ADD CHECK FOR DATA EXIST***

    %Running Unix function for converting functional SPM data to SUMA ready data
    eval(['!' '/Users/hrnel/Documents/MATLAB/meg_analysis/fMRI_Tools/SPM2SUMA_Maxwell.sh ' MRI_Info.subject_id ' ' MRI_Info.study_path]);

%% STEP 5 [OPTIONAL]: Copy files to server and Send email of job done
    
    % Copy folders (/Freesurfer_Reconstruction and /FunctionalData)
    
    %***THIS ISN'T WORKING!!!***
    % if isfield(MRI_Info,'server_data_path') && ~isempty(MRI_Info.server_data_path)
    %     copyfile(MRI_Info.server_data_path,MRI_Info.raw_data_path)
    %     unix(['cp -R ' MRI_Info.server_data_path ' ' MRI_Info.raw_data_path])
    % end

    Email.subject=['MRI Job Complete for ' MRI_Info.subject_id]; % you can use the command "mfilename" to put in the current mfiles name, also datestr(now,'yy-mm-dd_HHMM') for current time
    Email.body=['MRI Job done for ' MRI_Info.subject_id ' ' 10 ...
        'Finished at ' datestr(now,'yyyy-mm-dd HH:MM') ' ' 10 ...
        'Took: ' num2str((toc/60)/60) ' Hrs'];  % 10 in the body is a carriage return (just 10, not a string).
    Send_Email(Email);

