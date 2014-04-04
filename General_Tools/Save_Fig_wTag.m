% Save_Fig_wTag(tag)
% Save all open figures that have a tag that matches the tag input
% fig_info_str[OPTIONAL] = string of information to put in the file name (will add a time stamp to the file name)
%
% Saves as .fig and .png formats
%
% path_fig_default defaulted for Stephen
%
% To set tags, set(current_handle,'Tag','GoodResult');
%
% 2013-01-30 Foldes
% UPDATES:
% 2013-06-27 Foldes: now saves .fig also, and
% 2013-07-13 Foldes: Fixed windows bug w/ .png file name

function Save_Fig_wTag(tag,fig_info_str,path_fig_default)

if ~exist('path_fig_default') || isempty(path_fig_default)
    path_fig_default='/home/foldes/Dropbox/Code/figs';
end

if nargin<2
    fig_info_str = [tag '_'];
else
    fig_info_str = [fig_info_str '_'];
end

figure_save_name = [path_fig_default filesep fig_info_str datestr(now, 'yyyy.mm.dd_HHMMSS')];

% Get all open figure handles
figHandles = findobj('Type','figure');
for ihand = 1:length(figHandles)
    current_handle = figHandles(ihand);
    
    if strcmp(get(current_handle,'Tag'),tag)
        saveas(current_handle,[figure_save_name  '_' num2str(current_handle) '.fig']);
        
        print(current_handle,'-dpng',[figure_save_name  '_' num2str(current_handle)])
        disp(['SAVED FIG: ' figure_save_name  '_' num2str(current_handle) '.png'])
    end
    
end
