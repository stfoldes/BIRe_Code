function names = fieldnames_all(obj)
% Get the fields/properties for an object or struct that includes hidden
%
% 2013-08-22 Foldes/Bauman
% UPDATES:
%

% struct() will give a warning on objects
warning 'off'
names = fieldnames(struct(obj));
warning 'on'
