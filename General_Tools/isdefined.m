% function def_flag = isdefined(var_str)
% Returns 1 if the input varible-name (as string) both exists and is NOT empty.
% Returns 0 if the varible is either nonexistant or is empty.
% Useful for deciding if you should set a default value. Also, an isempty for a nonexistant varible will crash, this won't
% Also works for a single field-deep structure (that is, Extract.subject.name will NOT work yet b/c it is 2 field deep struct)
%
% Stephen Foldes (2012-04-11)
% Might be able to have input not be a string by reading in the varible's name?

function def_flag = isdefined(var_str)

MUST LOOK BACK AT PREVIOUS WORKSPACE!!!!
dbup

% You want to check on a struct field, you need to do something different
period_idx = strfind(var_str,'.');

% Just regular (not a structure)
if isempty(period_idx)
    eval(['def_flag = ~(~exist(''' var_str ''') || isempty(' var_str '));'])

% Check structure
else
    eval(['def_flag = ~(~exist(''' var_str(1:period_idx(:,1)-1) ''') || isempty(' var_str(1:period_idx(:,1)-1) '));'])

    if def_flag % main structure exists
        eval(['def_flag = ~(~isfield(' var_str(1:period_idx(:,1)-1) ',''' var_str(period_idx(:,1)+1:end) ''') || isempty(' var_str '));'])
    end
end

