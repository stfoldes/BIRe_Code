function [subject, session, run] = split_data_file_name(file_name)
% Break apart the standard file name to figure out basic file information
% Made for MEG and CRX data, but likely for many experimental data sets
% SubjectID session_char Session# run_char Run# (currently hardcoded)
%
% EXAMPLE:
%   nc01s01r02 => subject:nc01, session:01, run:02
%   
% All outputs are strs
% Will NOT change case of text
% file_name can have path or extension
% Assumes subject id won't have the session_char in it past 4 chars
%
% 2013-02-07 Foldes
% UPDATES
% 2013-09-30 Foldes: adjustible length for subject ids
% 2014-01-15 Foldes: REMADE, renamed from file_name_splitter, upper/lower case not defined here, uses regexp
% 2014-02-07 Foldes: Fixed bug with ext

%%
session_char = 's'; % will be case insensitive
run_char = 'r'; % will be case insensitive

% remove file separators
filesep_idx = regexpi(file_name,regexptranslate('escape',filesep));
if ~isempty(filesep_idx)
    file_base_name = file_name(max(filesep_idx)+1:end);
else
    file_base_name = file_name;
end

% find Subject str based on session str
session_idx = regexpi(file_base_name,session_char);
session_idx(session_idx<4) = []; % remove any idx that is less than 4 b/c it probably part of the subject name

% Subject ID is first characters
subject = (file_base_name(1:session_idx(1)-1)); % only consider first 's' after first 3

run_idx = regexpi(file_base_name,run_char);
run_idx(run_idx<session_idx) = []; % remove any idx before session idx

session = (file_base_name(session_idx(1)+1:run_idx(1)-1)); % only consider first 's' after first 3

ext_idx = regexpi(file_base_name,regexptranslate('escape','.'));
if isempty(ext_idx) % if not escape,  go to end 2014-02-07
   ext_idx = length(file_base_name)+1; % If you get here you need to include last character (hence +1)
end
ext_idx(ext_idx<session_idx) = []; % remove any idx before session idx

run = (file_base_name(run_idx(1)+1:ext_idx(1)-1)); % only consider first 's' after first 3
