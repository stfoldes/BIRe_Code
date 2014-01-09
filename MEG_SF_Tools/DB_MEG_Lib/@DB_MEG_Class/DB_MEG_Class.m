% Class to hold information about each experiment run
% Cast each property as either char or double (see Metadata_Load_from_TXT for more info)
%
% 2013-01 Foldes
% UPDATES
% 2013-02-07 Foldes: Renamed from FileInfo, changed properties
% 2013-02-21 Foldes: Forced properties to be cast as certain type (don't really force)
% 2013-03-02 Foldes: New ModDepth Pointers
% 2013-03-06 Foldes: MEDIUM - all "Analysis_xxx_pointer" properties were changed to "Pointer_xxx"
% 2013-03-28 Foldes: rename Pointer_bad_channel-->Pointer_prebadchan
% 2013-04-08 Foldes: Pointer_processed_data_for_events
% 2013-04-24 Foldes: Pointer_* --> Preproc.* and ResultsPointers.*
% 2013-08-07 Foldes: run_info and data_usable added
% 2013-08-13 Foldes: Started adding methods, Plot_BadChans
% 2013-08-22 Foldes: datatype_ moved to PreProc.
% 2013-10-04 Foldes: file_base_name replaced w/ entry_id

classdef DB_MEG_Class < DB_Class
    properties
        % Basic file info (FROM SUPERCLASS)
        % entry_id = char([]);
        % subject = char([]);
        % session = char([]);
        % date = char([]);
        
        run = char([]);
        
        % Subject Info
        subject_type = char([]); % AB
        gender = char([]);
        handedness = char([]);

        % Run Info
        run_type = char([]); % Open_Loop_MEG
        run_action = char([]); % Grasp
        run_task_side = char([]); % Right
        run_intention = char([]); % Imitate
        run_info = char([]); % subject_action_side_intention (see Metadata_Script_AutoFill)
                
        % Preprocessing Info and pointers
        Preproc = PreprocInfo_Class();
        
        % Results Pointers
        ResultPointers = ResultPointers_Class();
        
    end
    
    properties (Hidden)
        % MUST USE fieldnames_all() TO GET HIDDEN NAMES
    end % properties - hidden
    
    methods
        
        %function obj=DB_MEG_Class
        % COntrsuctor to includ DEF_MEG_paths
        
        
        % Head plots of bad channels
        bad_entry_list_out = Plot_BadChans(obj,varargin);

%         % Download Data from server (unless it exists locally AND isn't fresh)
%         Download_Data(obj,local_path,server_path,file_name_ending,force_transfer_flag)
%         
        
        
        % CONSTRUCTOR
        %         function obj = Metadata(x)
        %         end
        %
        %         %% Populate Metadata with
        %         function obj = Metadata_Populate

    end
    
    
    
end
