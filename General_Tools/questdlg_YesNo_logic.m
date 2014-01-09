% questdlg_YesNo_logic(input_dialog,input_question[OPTIONAL]);
% A simple yes or no question box which outputs a 1 for yes, and a 0 for no
% A code-saver to be used in a logical statement, like 'if questdlg_YesNo_logic()'
%
% Foldes 2013-04-25

function flag = questdlg_YesNo_logic(input_dialog,input_question)

if ~exist('input_question')
    input_question = '';
end

flag = strcmp(questdlg_wPosition([],input_dialog,input_question,'Yes','No','Yes'),'Yes');
