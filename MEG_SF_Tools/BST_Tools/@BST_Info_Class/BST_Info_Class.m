% Class to hold information used in manipulating BST
%
% 2014-02-15 Foldes
% UPDATES:
% 2014-02-17 Foldes: stimulus


classdef BST_Info_Class
    properties
        subject =               char([]); % Subjects ID in BST
        condition =             char([]); % Task/Trial name
        protocol =              char([]); % Automatically defined by looking up in BST
        protocol_anat_path =    char([]); % path to the anat folder for this protocol
        protocol_data_path =    char([]); % path to the data folder for this protocol
        eventname =             char([]); % [OPTIONAL] str of stimulus name. Helps for finding files

        % Analysis Prop
        group_or_ind =          char([]); % 'individual' or 'group' brain
        inverse_method =        char([]); % for inverse files only ('wMNE','dSPM')
        
    end % props
    
    
    methods
        
        % ===CONSTRUCTOR===
        % Makes sure BST is open
        % Fills in protocol information
        function obj = BST_Info_Class()
            % Must start BST first
            if brainstorm('status') == 0 % unless its already open
                brainstorm;
                error('BST must be open and pointed to the correct protocol (try again)')
            end
            
            % Basic info from BST
            ProtocolInfo =      bst_get('ProtocolInfo');
            obj.protocol =  ProtocolInfo.Comment;
            
            obj.protocol_data_path = ProtocolInfo.STUDIES;
            obj.protocol_anat_path = ProtocolInfo.SUBJECTS;
        end
        
        % ===OTHER METHODS===
        
        % Generates the path to files in the brainstorm_db
        %       file_type: 'inverse','headmodel','average','noisecov','avg', 'surface','t1','mri'
        [fullfile_name,localfile_name] = Get_File_Path(obj,file_type);
        
        % Loads BST data from files within the BST_db
        %       file_type: 'inverse','headmodel','average','noisecov','avg', 'surface','t1','mri'
        [data_out,fullfile_name] = Load_File(obj,file_type);
        
        % List things from what is in BST
        list_out = List(obj,list_type);
        
        % Just builds the OverlayFile input string for view_surface_data.m
        link_str = OverlayFile_str(obj);

        
    end % methods
    
end % class

















