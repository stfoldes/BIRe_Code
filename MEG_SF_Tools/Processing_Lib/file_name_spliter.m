function [subject, session, run] = file_name_spliter(file_base_name,subject_id_length)
% Break apart the standard file name to figure out basic file information
% file_base_name should not have path or extension
% nc01s01r02 => subject:nc01, session:01, run:02
% works for weird cases like
% nc01s001emptyroom => subject:nc01, session:01, run:emptyroom
%
% 2013-02-07 Foldes
% UPDATES
% 2013-09-30 Foldes: adjustible length for subject ids

if ~exist('subject_id_length')||isempty(subject_id_length)
    subject_id_length=4; % default for MEG
end

% Subject ID is always first 4 characters
subject = upper(file_base_name(1:subject_id_length));


% Session is after "s" and before any other letters
idx_session_num_begining = find(file_base_name(5:end)=='s',1,'first')+4+1; % +4 to make sure not in subject name, +1 to remove the 's'
idx_session_num_end = find(isstrprop(file_base_name(idx_session_num_begining:end),'alpha'),1,'first') -1+(idx_session_num_begining-1); % -1 to remove char, -1 to remove beginign offset
session = file_base_name(idx_session_num_begining:idx_session_num_end);

% Run is what ever is after (if r###, removes first alpha)
idx_run_num_begining=idx_session_num_end+1;
idx_run_num_end = length(file_base_name);

run = file_base_name(idx_run_num_begining:idx_run_num_end);

if isstrprop(run(1),'alpha') && isstrprop(run(2),'digit')
    run = run(2:end);
end