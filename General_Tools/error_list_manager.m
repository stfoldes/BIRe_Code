function ErrorList = error_list_manager(ErrorList,program_msg)
% To be used in a try-catch within a loop to keep a record of what failed
% program_msg is a str that can be passed from the program (like subject-id)
% ErrorList must be started outside (ErrorList = [];)
%
% ErrorList .program_msg
%           .message
%           .identifier
%           .stack_name {}
%           .stack_line {}
%           .time
%
% 2014-03-26 Foldes


if ~exist('program_msg')
    program_msg = [];
end

error_cnt = length(ErrorList) + 1;

ErrorList(error_cnt).program_msg = program_msg;

% Error info
e = lasterror;
ErrorList(error_cnt).message =      e.message;
ErrorList(error_cnt).identifier =   e.identifier;

fprintf('\n_______________________________________________\n');
fprintf('================== ERROR ======================\n');

fprintf('Message: \t%s\n',ErrorList(error_cnt).message);
fprintf('Info: \t\t%s\n',program_msg);
fprintf('Error ID: \t%s\n',ErrorList(error_cnt).identifier);

if ~isempty(e.stack)
    ErrorList(error_cnt).stack_name = {e.stack.name};
    ErrorList(error_cnt).stack_line = {e.stack.line};
    fprintf('Root: \t\t%s [line %i]\n',e.stack(1).name,e.stack(1).line);
    if length(e.stack)>1
        fprintf('Parent: \t%s [line %i]\n',e.stack(end).name,e.stack(end).line);
    end
end

ErrorList(error_cnt).time = datestr(now,'yyyy-mm-dd HH:MM:SS');
fprintf('Time: \t\t%s\n',ErrorList(error_cnt).time);
    
fprintf('_______________________________________________\n');

