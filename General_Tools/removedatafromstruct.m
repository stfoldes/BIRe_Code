% Remove data points from structure children
% Stephen Foldes
% 05-27-10
%
% Removes points in structure children as given by remove_vec.
% Removes data points from all children whose lengths match that of remove_vec

function new_struct = removedatafromstruct(struct,remove_vec)

struct_childern=fields(struct);
new_struct =[];

for ichild=1:size(struct_childern,1)
    clear new_vec
    
    child_char =[];
    child_char = char(struct_childern(ichild,:));
    eval(['new_struct.' child_char '= [];'])
        
    % if this child is the approprate size, then remove data points
    eval(['child_size= size(struct.' child_char ');'])
    if min(child_size==size(remove_vec))
        
        eval(['new_vec= struct.' child_char ';'])
        new_vec=new_vec(~remove_vec);
        
        eval(['new_struct.' child_char '= new_vec;'])
    else % don't change if not the same size
        eval(['new_struct.' child_char '= struct.' child_char ';'])
    end
    
end


