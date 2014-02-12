% For CRX RESULTS
% SHOULD BE DB_CLASS SUBCLASS
% Or even a DB_MEG_CLASS subclass!
%
% 2014-01-16 Foldes
% UPDATES:
%


classdef CRX_Results_Class < DB_Class
    properties
        % Basic file info (DB_Class)
        %         %entry_id =      char([]);
        %         subject =       char([]);
        %         session =       char([]);
        %         %date =          char([]);
        %
        
        %run =           char([]);
        % Run Info
        %run_type =      char([]); % Closed_Loop_MEG
        run_action =    char([]); % Grasp
        run_task_side = char([]); % Right
        run_intention = char([]); % Imitate
        run_info =      char([]); % subject_action_side_intention (see Metadata_Script_AutoFill)
                
        run_group =     []; % other runs that should be joined (cell array)
        file_splits = [];
        
        hold_timeS = 0;
        num_trials = 0;
        
        mean_success_timeS = 0;
        target_code_types = 0;
        hit_per_dim = 0;
        trial_per_dim = 0;
        hit_rate = 0;
        
        run_by_trial = [];
        success_timeS = [];
        success_trial_num = [];
        success_trial_target = [];
        
    end
    properties (Hidden)
        % MUST USE fieldnames_all() TO GET HIDDEN NAMES
    end % properties - hidden
    
    
    % METHODS: To be Inherited
    methods % see DB_Class

        % CONSTRUCTOR
        %         function obj = Metadata(x)
        %         end
        %
        %         %% Populate Metadata with
        %         function obj = Metadata_Populate
        
    end
    
    methods (Abstract)
        % Stuff that must be defined in a subclass
        
%         % full path to a file
%         file
        

        
    end
    
end
