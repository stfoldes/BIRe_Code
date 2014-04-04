% Object for fMRI processing
%
% SPM can't deal with relative paths right now (spm_existfile fail...whoops)
% This includes ~/
%
% 2014-01-01 Foldes
% UPDATES:
% 2014-01-06 Foldes: Added ExpDef for SPM variables
% 2014-04-03 Foldes: Add prep paths, defaults added

classdef MRI_Info_Class
    
    properties
        
        % Critial
        study_path =            char([]); 
        
        subject_id =            char([]); % Only needed for Freesurfer and UNIX things and designs
        raw_data_path =         char([]); % use design
        
        % FS and SUMA scripts (file names are sufficent if in the Matlab path)
        FS_script =             char([]);
        SPM2SUMA_script =       char([]);
        
        % SPM Basics
        T1_file =               char([]); % use design
        epi_run_list =          'all';
        epi_path =              char([]); % path to epi folder. use design
        epi_full_file_names =   char([]); % Used in spm job
        
        % SPM variables
        spm_job =               char([]);
        ExpDef_TR =             []; % TR 'Interscan interval'
        ExpDef_event_onsets =   []; % vector of when conditions/events happen, in scan # (hardcoded, but can be changed)
        ExpDef_event_duration = []; % num scans for the event/condition to happen
        
        % Misc
        output_path =           char([]);
        output_prefix =         char([]);
        
    end
    
    properties (Hidden)
        spm_path =              char([]);
        T1_auto_find =          0;
        FS_script_path =        char([]); % actual path to the script
        SPM2SUMA_script_path =  char([]);

        % Relative Path Designs (SEE: str_from_design.m, struct_auto_translate.m)        
        study_path_design =     char([]);
        T1_file_design =       '[study_path]/Freesurfer_Reconstruction/SUMA/T1.nii'; % Where is the T1? Blank for GUI
        epi_path_design =      '[study_path]/NIFTI/'; % Where are the EPI folders? Blank for GUI
        raw_data_path_design = '[study_path]/Raw_Data/'; % Where are the raw folders? Blank for GUI

        % Where to move analyzed files
        output_path_design =   '[study_path]/FunctionalData/'; % Where should the results go?
        output_prefix_design = '[subject_id]_'; % What new prefix should the results have?

    end
    
    methods
        
        obj = Prep_Paths(obj);
                
    end
end    
    
    
    
    
    
