% Returns info about the user's computer
%
% computer_name = name of computer (on network)
% user_name = log in name
% os = Operating system info (e.g. GLNXA64, output of computer.m)
%
% Foldes 2013-07-02
% UPDATES:
%

function [computer_name,user_name,os] = computer_info


[~,computer_name]=system('hostname');
computer_name = computer_name(1:end-1); % I HAVE NO IDEA WHY THERE IS AN EXTRA CHAR

[~, user_name] = system('whoami');
user_name = user_name(1:end-1);

os = computer;

% Get user info
% if isunix
%     [~, user_name] = system('whoami');
%     
% elseif ispc
%     [~, user_name] = system('echo %USERDOMAIN%\%USERNAME%');
% end



