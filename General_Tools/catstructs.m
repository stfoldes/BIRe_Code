% new_struct = catstructs(struct2,struct1,dim)
% Concatinate Two Structures together
% Stephen Foldes (2010-05-25)
%
% Concatinates all childern from the first structure into the second. Will automatically figure out which dimension to concatinate across.
% If all dimensions are equal sized, it will use 'dim' to define which to concatinat across, or the longest if 'dim' doesn't exist
%
% UPDATES:
% 2012-03-31 SF: Now automatically figures out dimension to cat. Also allows for missing fields in struct1 and empty struct1. Checks dimensionality differences and provides warnings.

function new_struct = catstructs(struct1,struct2,dim)

struct2_childern=fields(struct2);

try % struct 1 might be empty, if it is not, make sure you keep all it's children as well.
    struct1_childern=fields(struct1);
    struct_children = unique(cat(1,struct2_childern,struct1_childern));
catch
    struct_children=struct2_childern;
end

new_struct =[];

for ichild=1:size(struct_children,1)
    
    child_char =[];
    child_char = char(struct_children(ichild,:));
    
    %% Figure out which dimension
    clear current_dim
    
    if isfield(struct1,child_char) && isfield(struct2,child_char)
        eval(['struct2_current_child_size = size(struct2.' child_char ');'])
        eval(['struct1_current_child_size = size(struct1.' child_char ');'])
        
        % if there is a dimension difference, thats a problem
        if length(struct2_current_child_size) ~= length(struct1_current_child_size)
            warning(['@catstructs.m The "' child_char '" Field has different dimensions between the two structs, skipping concatination']);
            continue
        else % Choose the dimension that is different between the structs to concatinate across
            current_dim=find(struct2_current_child_size~=struct1_current_child_size);
            if isempty(current_dim) % all dims are equal
                if ~exist('dim') || isempty(dim)
                    current_dim = find(struct2_current_child_size==max(struct2_current_child_size));
                else % dim was given, use it
                    current_dim = dim;
                end
            end
        end
    else % struct1 doesn't have this child, so whatever
        disp(['     @catstructs.m The "' child_char '" Field does not exist in one of the structs, just copying field']);
        current_dim = 1;
    end
    
    %% Do concatination
    eval(['new_struct.' child_char '= [];'])
    if  isfield(struct1,child_char)
        eval(['new_struct.' child_char '= cat(' num2str(current_dim) ',new_struct.' child_char ',struct1.' child_char '); ' ])
    end
    % Only concatinate if struct 2 has the given field
    if isfield(struct2,child_char)
        eval(['new_struct.' child_char '= cat(' num2str(current_dim) ',new_struct.' child_char ',struct2.' child_char '); ' ])
    end
    
    
    
end


