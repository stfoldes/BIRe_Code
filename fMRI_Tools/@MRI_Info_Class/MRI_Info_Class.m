% Object for fMRI processing
%
% SPM can't deal with relative paths right now (spm_existfile fail...whoops)
% This includes ~/
%
% 2014-01-01 Foldes
% UPDATES:
% 2014-01-06 Foldes: Added ExpDef for SPM variables

classdef MRI_Info_Class
    
    properties
        
        % Critial
        study_path =            char([]); 
        
        subject_id =            char([]); % Only needed for Freesurfer and UNIX things and designs
        raw_data_path =         char([]); % use design
        
        % FS and SUMA scripts
        FS_script =             char([]);
        SPM2SUMA_script =       char([]);
        
        % SPM Basics
        T1_file =               char([]); % use design
        epi_run_list =          char([]);
        epi_path =              char([]); % path to epi folder. use design
        epi_full_file_names =   char([]); % Used in spm job
        
        % SPM variables
        spm_job =               char([]);
        ExpDef_TR =             []; % TR 'Interscan interval'
        ExpDef_event_onsets =   []; % vector of when conditions/events happen, in scan # (hardcoded, but can be changed)
        ExpDef_event_duration = []; % num scans for the event/condition to happen
        
        % Mis
        output_path =           char([]);
        output_prefix =         char([]);
        
    end
    
    properties (Hidden)
        spm_path =              char([]);
        T1_auto_find =          0;

        % Designs (SEE: str_from_design.m, struct_auto_translate.m)        
        study_path_design =     char([]);
        raw_data_path_design =  char([]);
        epi_path_design =       char([]);
        T1_file_design =        char([]);
        
        output_path_design =    char([]);
        output_prefix_design =  char([]);

    end
    
    methods
        % can add prep
        
    end
end    
    
    
    
    
    
