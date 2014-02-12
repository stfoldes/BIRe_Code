% For CRX data
% SHOULD BE DB_CLASS SUBCLASS
% Or even a DB_MEG_CLASS subclass!
%
% 2014-01-15 Foldes
% UPDATES


classdef Feedback_Class
    properties
        % Basic file info
        entry_id =      char([]);
        subject =       char([]);
        session =       char([]);
        date =          char([]);
        
        run =           char([]);
        % Run Info
        run_type =      char([]); % Closed_Loop_MEG
        run_action =    char([]); % Grasp
        run_task_side = char([]); % Right
        run_intention = char([]); % Imitate
        run_info =      char([]); % subject_action_side_intention (see Metadata_Script_AutoFill)
                
        run_group =     []; % other runs that should be joined (cell array)
        
    end
    properties (Hidden)
        % MUST USE fieldnames_all() TO GET HIDDEN NAMES
    end % properties - hidden
    
    
    % METHODS: To be Inherited
    methods

        % Replaces an entry with another (used to update entries)
        obj = update_entry(obj,DB_entry);
        
        % Get data entries in a variety of many ways
        [entry,entry_idx] = get_entry(obj,varargin);
        
%         % Builds the path to the entry (but not the file)
%         path = file_path(obj,location_name);
%         % file_full_path = file(obj,file_ext,base_path); % Defined in subclass for now

        % Returns a sorted database which is sorted by property name
        [obj,idx] = sort_enteries(obj,property_str,sort_mode)
% 
%         % Checks if the pointer exists local or server.
%         exists_flag = pointer_check(obj,pointer_name,varargin)%location_name,dialog_flag
                
        % isfield for objects
        function [x] = isfield(obj,input_field)
            % Needed for tools that will work for both structs AND objects
            % 2013-08-22 Foldes
            x = isprop(obj,input_field);
        end % isfield
        
        
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
