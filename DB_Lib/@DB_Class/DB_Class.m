% This is a superclass for databases.
% Intended to give metadata and pointers related to individual files
% Developed for experiment data
% Cast each property as either char or double (see Metadata_Load_from_TXT for more info)
%
% 2013-01 Foldes
% UPDATES
% 2013-10-03 Foldes: Branched from Metadata_Class into superclass


classdef DB_Class
    properties
        % Basic file info
        entry_id =  char([]);
        subject =   char([]);
        session =   char([]);
        date =      char([]);
    end
    properties (Hidden)
        % MUST USE fieldnames_all() TO GET HIDDEN NAMES
    end % properties - hidden
    
    
    % METHODS: To be Inherited
    methods
        
        %% LOAD AND SAVE
        % build a database from txt-file
        obj=build(obj,path_file);
        
        % Write database to TXT file
        save_DB(obj,database_location); % database_location is optional
                
        % Download Data from server (unless it exists locally AND isn't fresh)
        download(obj,file_name_ending,force_transfer_flag,pointer_name);

        % Replaces an entry with another (used to update entries)
        obj = update_entry(obj,DB_entry);
        
        % loads a pointer file
        output = load_pointer(obj,pointer_name);
        
        % Save pointer to file and server
        [obj,save_flag] = save_pointer(obj,pointer_data,pointer_name,save_type,overwrite_flag);
        
        
        %% TOOLS
        
        % Get data entries in a variety of many ways
        [entry,entry_idx] = get_entry(obj,varargin);
        
        % Builds the path to the entry (but not the file)
        path = file_path(obj,location_name);
        % file_full_path = file(obj,file_ext,base_path); % Defined in subclass for now

        % Returns a sorted database which is sorted by property name
        [obj,idx] = sort_enteries(obj,property_str,sort_mode)

        % Checks if the pointer exists local or server.
        exists_flag = pointer_check(obj,pointer_name,varargin)%location_name,dialog_flag
                
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
