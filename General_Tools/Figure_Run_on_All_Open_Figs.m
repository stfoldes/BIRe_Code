function Figure_Run_on_All_Open_Figs(function2run)
% runs the string code given in function2run on each open figure
%
% EXAMPLE:
%   Figure_Run_on_All_Open_Figs('Figure_Save')
%
% 2013-07-18 Foldes


% Get all open figure handles
figHandles = findobj('Type','figure');

for ihand = 1:length(figHandles)
    try
        current_handle = figHandles(ihand);
        
        % put focus on current handle-figure
        figure(current_handle)
        eval(function2run);
    catch
        disp('No Function Performed')
    end
end
