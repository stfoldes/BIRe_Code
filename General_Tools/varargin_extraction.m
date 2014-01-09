function parm_struct = varargin_extraction(defaults,org_varargin)
% Parses org_varargin and loads defaults
% Used at the begining of functions to have variable number of inputs and set defaults
% Will also take the place of if ~exist('') || isempty()
%
% INPUTS:
%   org_varargin = just the org_varargin from the original function (e.g. 'plot_color','r')
%   defaults = structure with all the required fields (defaults.plot_color = 'k')
%
% OUTPUTS:
%   parm_struct = parameter structure same as defaults, but replaced fields in org_varargin
%
% EXAMPLE:
%   Change plot color to red from default black
%   org_varargin: ...,'plot_color','r',...)
%   defaults.plot_color = 'k';
%   parms = varargin_extraction(defaults,org_varargin);
%   plot(x,y,'Color',parms.plot_color);
%   
% SEE: populate_field_with_default.m
%
% 2013-08-09 Foldes (loosely inspired by Jim and RNEL)
% UPDATES:
% 2013-08-16 Foldes: Now checks if variable name is valid

% turn org_varargin into a structure and get field names
varargin_struct = cell2struct(org_varargin(2:2:end),org_varargin(1:2:end),2);
varar_fields = fieldnames(varargin_struct);

% make output structure that is the same as defaults
parm_struct = defaults;

% go through each input field and replace the new value
for ifields = 1:size(varar_fields,1)
    current_field = cell2mat(varar_fields(ifields));
    if ~isfield(parm_struct,current_field) % NOT A VALID FIELD
       warning([current_field ' is NOT a valid varargin!'])
    end
    parm_struct.(current_field) = varargin_struct.(current_field);
end
