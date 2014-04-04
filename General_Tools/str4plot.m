function str_new = str4plot(str,cap_flag)
% cleans up a string so it can be added to a plot
% Removes _
% cap_flag = 1 will make the first letter of words capital
%
% 2013-09-16 Foldes
% UPDATES:
%

underscore_idx = strfind(str,'_');

str_new = str;
str_new(underscore_idx)= ' ';

% default do doing capital
if ~exist('cap_flag')
    cap_flag = 1;
end

if cap_flag==1
    % find places that are spaces, the character after is a new word
    % however, the last char can not be a space (hence end-1)
    % Also, the first char is also cap (hence 0)
    space_idx = [0 strfind(str_new(1:end-1),' ')];
    
    str_new(space_idx+1)=upper(str_new(space_idx+1));
end

