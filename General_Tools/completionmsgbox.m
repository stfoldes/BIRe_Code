% completionmsgbox
% Stephen Foldes (2012-01-26)
%
% Displays a message box indicating the completion of a function.
% FORMAT: "function_name" @ XX:XX AM/PM
% Automatically finds parent-function's name and completion time.
% Currently finds calling-parent with "ST(2)", could also do most-senior parent w/ "ST(end)"

function completionmsgbox

[ST I]=dbstack('-completenames');
msgbox([ST(2).name ' @ ' datestr(now,'HH:MM PM')],'COMPLETE','help')