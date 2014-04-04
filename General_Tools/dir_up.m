function up_dir = dir_up(org_dir)
% String for the directory above the given
% Super simple, probably just type out; but this will help remember
%
% 2014-01-07 Foldes
% UPDATES:
%

up_dir = org_dir(1:max(strfind(org_dir,filesep)));
