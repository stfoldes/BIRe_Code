% Class to hold information used in running Pipelines
%
% 2014-02-1 Foldes
% UPDATES:
% 


classdef BST_Pipeline_Class < BST_Info_Class
    properties
        % INHERITED PROPERTIES FROM BST_Info_Class
        %         subject =               char([]); % Subjects ID in BST
        %         condition =             char([]); % Task/Trial name
        %         protocol =              char([]); % Automatically defined by looking up in BST
        %         protocol_anat_path =    char([]); % path to the anat folder for this protocol
        %         protocol_data_path =    char([]); % path to the data folder for this protocol
        %         eventname =             char([]); % [OPTIONAL] str of stimulus name. Helps for finding files
        %
        %         % Analysis Prop
        %         group_or_ind =          char([]); % 'individual' or 'group' brain
        %         inverse_method =        char([]); % for inverse files only ('wMNE','dSPM')
        
        % IMPORT
        FIFFile =               char([]); % 
        EventFile =             char([]); % [OPTIONAL]
        epochtime =             double([]); % 
        trial_list =            'all';
        
        % SOURCE
        % inverse_method =      char([]); % for inverse files only ('wMNE','dSPM')
        noisecov_time =         [-0.1, 0];
        inverse_orientation =   'fixed';
        
    end % props
    
    
    methods

        % INHERITED METHODS FROM BST_Info_Class
        %         % ===CONSTRUCTOR===
        %         % Makes sure BST is open
        %         % Fills in protocol information
        %         function obj = BST_Info_Class()
        %             % Must start BST first
        %             if brainstorm('status') == 0 % unless its already open
        %                 brainstorm;
        %                 error('BST must be open and pointed to the correct protocol (try again)')
        %             end
        %             
        %             % Basic info from BST
        %             ProtocolInfo =  bst_get('ProtocolInfo');
        %             obj.protocol =  ProtocolInfo.Comment;
        %             
        %             obj.protocol_data_path = ProtocolInfo.STUDIES;
        %             obj.protocol_anat_path = ProtocolInfo.SUBJECTS;
        %         end
        %         
        %         % ===OTHER METHODS===
        %         
        %         % Generates the path to files in the brainstorm_db
        %         %       file_type: 'inverse','headmodel','average','noisecov','avg', 'surface','t1','mri'
        %         [fullfile_name,localfile_name] = Get_File_Path(obj,file_type);
        %         
        %         % Loads BST data from files within the BST_db
        %         %       file_type: 'inverse','headmodel','average','noisecov','avg', 'surface','t1','mri'
        %         [data_out,fullfile_name] = Load_File(obj,file_type);
        %         
        %         % List things from what is in BST
        %         list_out = List(obj,list_type);
        %         
        %         % Just builds the OverlayFile input string for view_surface_data.m
        %         link_str = OverlayFile_str(obj);

        % Get Trial files
        sFiles = Get_Trial_File_Names(obj);
        
        % Run general pipelines
        [PipeInfo, sFiles_4debug] = Run(PipeInfo,varargin)
        
    end % methods
    
end % class

















