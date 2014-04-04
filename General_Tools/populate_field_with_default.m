% BaseStruct = populate_field_with_default(BaseStruct,field_name,default)
% Stephen Foldes (2012-01-30)
%
% populates the field 'field_name' in 'BaseStruct' with 'default' UNLESS 'field_name' has already been defined. Saves lots of text
% WILL NOT OVERWRITE FIELDS
% Can put char or numbers in 'default' (this was a pain, but could maybe be done smarter)
% EXAMPLE:
%   Extract.holiday >> ??? Reference to non-existent field 'holiday'
%   Extract = create_new_field(Extract,'holiday','Christmas'); Extract.holiday >> ans = Christmas
%   Extract = create_new_field(Extract,'holiday','Thanksgiving'); Extract.holiday >> ans = Christmas  (i.e. didn't change b/c it was previously defined)
%
% SEE: varargin_extraction for better way to do this.
%
% UPDATES
% 2012-01-31 SF: now supports multidimensional defaults
% 2012-03-02 SF: Now supports cells
% 2012-08-31 Foldes: If no default is given, try to use what is already there, if not possible, ask the user to input value.

function BaseStruct = populate_field_with_default(BaseStruct,field_name,default)

% if the default is empty, just let it pass
if isempty(default)
    if ~isfield(BaseStruct,field_name) % if you don't have anything to put, tell the user
        new_value=input(['No value set for ' field_name '. ENTER VALUE: ']);
        eval(['BaseStruct.' field_name '=[' new_value '];']);
        return
    else
        return
    end
end

empty_flg=0;

% char inputs need to be treated special (need to put quotes in the eval)
if isa(default,'char')
    % if the field hasn't been defined, or if its empty, then define it as given
    if ~isfield(BaseStruct,field_name)
        for idim = 1:size(default,1) % if the default is multidimensional
            eval(['BaseStruct.' field_name '(' num2str(idim) ',:)=''' default(idim,:) ''';']); % the [] and num2str don't seem to hurt
        end
    else
        eval(['empty_flg = isempty(BaseStruct.' field_name ');']);
        if empty_flg
            for idim = 1:size(default,2) % if the default is multidimensional
                eval(['BaseStruct.' field_name '(' num2str(idim) ',:)=[' default(idim,:) '];']); % the [] and num2str don't seem to hurt
            end
        end
    end

    
% Cells are special
elseif isa(default,'cell')
    
    % if the field hasn't been defined, or if its empty, then define it as given
    if ~isfield(BaseStruct,field_name)
        for idim = 1:size(default,2) % if the default is multicelluar
            eval(['BaseStruct.' field_name '{' num2str(idim) '}=''' num2str(default{idim}) ''';']); % the [] and num2str don't seem to hurt
        end
    else
        eval(['empty_flg = isempty(BaseStruct.' field_name ');']);
        if empty_flg
            eval(['BaseStruct.' field_name '=[' num2str(default) '];']);
            
            for idim = 1:size(default,2) % if the default is multi-celluar
                eval(['BaseStruct.' field_name '{' num2str(idim) '}=''' num2str(default{idim}) ''';']); % the [] and num2str don't seem to hurt
            end
        end
    end
    
% non-char inputs need to be treated special (need to do num2str in the eval)
else
    
    % if the field hasn't been defined, or if its empty, then define it as given
    if ~isfield(BaseStruct,field_name)
        for idim = 1:size(default,1) % if the default is multidimensional
            eval(['BaseStruct.' field_name '(' num2str(idim) ',:)=[' num2str(default(idim,:)) '];']); % the [] and num2str don't seem to hurt
        end
    else
        eval(['empty_flg = isempty(BaseStruct.' field_name ');']);
        if empty_flg
            eval(['BaseStruct.' field_name '=[' num2str(default) '];']);
            
            for idim = 1:size(default,2) % if the default is multidimensional
                eval(['BaseStruct.' field_name '(' num2str(idim) ',:)=[' num2str(default(idim,:)) '];']); % the [] and num2str don't seem to hurt
            end
        end
    end
    
end











