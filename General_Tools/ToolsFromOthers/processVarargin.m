function [in,extras] = processVarargin(in,org_varargin,varargin)
% Processes varargin and overrides defaults
%
% [in,extras] = processVarargin(in,org_varargin,varargin) %SEE INPUTS as this is a
% bit different convention than other functions
%
% INPUTS
% =======================================================================
% in       : defaults structure
% org_varargin        : varargin input from calling function, prop/value or structure with fields
% varargin : see optional inputs, prop/value or structure with fields
%
% OPTIONAL INPUTS (specify via prop/value pairs)
% =======================================================================
% case_sensitive    : (default false)
% allow_duplicates  : (default false) NOT YET IMPLEMENTED
% partial_match     : (default false) NOT YET IMPLEMENTED
% allow_non_matches : (default false)
%
% OUTPUTS
% =======================================================================
% extras
% .non_matches : (cellstr), list of non matches, only non-empty
% if allow_non_matches is true
%
%     EXAMPLES
%     =================================================================
%     1)
%     function test(varargin)
%     in.a = 1
%     in.b = 2
%     in = processVarargin(in,varargin,'allow_duplicates',true)
%
%     Similar functions:
%     http://www.mathworks.com/matlabcentral/fileexchange/22671
%     http://www.mathworks.com/matlabcentral/fileexchange/10670
%
%     IMPROVEMENTS
%     ===============================================================
%     1) For non-matched inputs, provide link to offending caller
%     2) Allow notation which only applies values to matching class
%     - what about subclasses or type? - provide different notation
%     - something like:
%     - for function name matching
%         ...,'@function_name',{'prop_a',1,'prop_b',2},'prop_local',true
%             - for class matching
%             ...,'#'
%                 Importantly these would not throw an error and if found
%             would run extra code to determine evaluation ...
%
% <2013 RNEL (Jim)
% UPDATES
% 2013-08-09 Foldes: Renamed from processVarargin.m

%%

% DEFAULTS
c.case_sensitive    = false;
c.allow_duplicates  = false;
c.partial_match     = false;
c.allow_non_matches = false;

% Update options using helper function
c = varargin_extraction_Helper(c,varargin,c,1);

% Update optional inputs of calling function with this function's options now set
[in,extras] = varargin_extraction_Helper(in,org_varargin,c,nargout);

end



function [in,extras] = varargin_extraction_Helper(in,org_varargin,c,nOut)

if nOut == 2
    extras             = struct;
    extras.non_matches = {};
else
    extras = [];
end

%Checking the optional inputs, either a structure or a prop/value cell
%array is allowed, or various forms of empty ...
if isempty(org_varargin)
    %do nothing
    parse_input = false;
elseif isstruct(org_varargin)
    %This case should generally not happen
    %It will if varargin is not used in the calling function
    parse_input = true;
elseif isstruct(org_varargin{1}) && length(org_varargin) == 1
    %Single structure was passed in as sole argument for varargin
    org_varargin = org_varargin{1};
    parse_input = true;
elseif iscell(org_varargin) && length(org_varargin) == 1 && isempty(org_varargin{1})
    %User passed in empty cell option to varargin instead of just ommitting input
    parse_input = false;
else
    parse_input = true;
    isStr  = cellfun('isclass',org_varargin,'char');
    if ~all(isStr(1:2:end))
        error('Unexpected format for varargin, not all properties are strings')
    end
    
    if mod(length(org_varargin),2) ~= 0
        error('Property/value pairs are not balanced, length of input: %d',length(org_varargin))
    end
    org_varargin = org_varargin(:)';
    org_varargin = cell2struct(org_varargin(2:2:end),org_varargin(1:2:end),2);
end

%NOTE: Need to be careful if we ever add on more outputs to the
%structure "extras" later on since we are returning here
if ~parse_input
    return
end

%At this point we should have a structure ...
varar_fields   = fieldnames(org_varargin);
default_fields = fieldnames(in);

%Matching location
%----------------------------------------
if c.case_sensitive % WHY WHOULD THIS NOT BE CASE SENSITIVE?
    [isPresent,loc] = ismember_str(varar_fields,default_fields);
else
    [isPresent,loc] = ismember_str(upper(varar_fields),upper(default_fields));
    %NOTE: I don't currently do a check here for uniqueness of matches ...
    %Could have many fields which case-insensitive are the same ...
end

if ~all(isPresent)
    if c.allow_non_matches
        extras.non_matches = varar_fields(~isPresent);
    else
        %NOTE: This would be improved by adding on the restrictions we used in mapping
        badVariables = varar_fields(~isPresent);
        error(['Bad variable names given in input structure: ' ...
            '\n--------------------------------- \n %s' ...
            ' \n--------------------------------------'],...
            cellArrayToString(badVariables,','))
    end
end

%Actual assignment
%---------------------------------------------------------------
for i = 1:length(varar_fields)
    if isPresent(i)
        %NOTE: By using default_fields we ensure case matching
        in.(default_fields{loc(i)}) = org_varargin.(varar_fields{i});
    end
end

end