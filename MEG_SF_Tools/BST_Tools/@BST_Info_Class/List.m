% List different things from BST
% Really just a wrapper for then confusing BST functions and structures
% Many methods don't even use the obj, they just look at BST
%
% list_type:
%       'Subjects','Conditions','Scouts'
%
% 2014-02-15 Foldes
% UPDATES:
% 2014-02-18 Foldes: scouts

% HELPER: disp_struct(BST_Struct.Study)

function list_out = List(obj,list_type)

list_out = [];

switch lower(list_type)
    
    case {'subjects','subject'}
        BST_Struct = bst_get('ProtocolSubjects');
        for isubject = 1:length(BST_Struct.Subject)
            list_out{end+1} = BST_Struct.Subject(isubject).Name;
        end
        
    case {'conditions','condition'}
        BST_Struct = bst_get('ProtocolStudies');
        for istudy = 1:length(BST_Struct.Study)
            current_name = BST_Struct.Study(istudy).Name;
            if ~strcmp(current_name(1),'@') % @ are not conditions we care about
                list_out{end+1} = current_name;
            end
        end
        
    case {'scout','scouts'}
        % This is for User Scouts only
        
        % Scout info is in the SurfaceFile (DONT LOAD FROM FILE, NOT THE SAME AS FROM MEMORY)
        SurfaceFile =   obj.Get_File_Path('surface');
        BST_Struct =    bst_memory('GetSurface', SurfaceFile);
        
        % which atlas is the user scouts? (this is easier than it looks)
        user_scout_idx = find_lists_overlap_idx(struct_field2cell(BST_Struct.Atlas,'Name'),'User scouts');
        list_out = struct_field2cell(BST_Struct.Atlas(user_scout_idx).Scouts,'Label');
        
end