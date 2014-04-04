% ylabel_right(label_str)
% Stephen Foldes (2012-02-17)
%
% CURRENTLY THE SCALE IS NOT LINKED AND ITS HARD TO SET IT SO THIS JUST MAKES A LABLE, NO NUMBERS
%
% Quickly makes and labels a yaxis on the right side. Can give it an axis handle if you don't want to use the current (i.e. gca)
% Just shows a right-yaxis with label, it does NOT corrispond to the data.
% YOU MUST SET THE SCALING TO THE DATA MANUALLY
% Function sets ylim to other axis limits, but can be changed to ylim() but will NOT change actual scalling of data 
% After calling this function, gca is now the right axis, so any changes to limits/text/etc. will not be done to the first axis.
%
% Returns handel to new axis
% Also see plotyy()
%
% EXAMPLE: ylabel_right('Stephen is Right');

function axis_handle_right = ylabel_right(label_str,axis_handle)

% use current axis if none was given
if ~exist('axis_handle') || isempty(axis_handle)
    axis_handle = gca;
end

% Collect original info so you can return it for new axis
% org_stuff = get(axis_handle); % DOESN'T WORK
org_fontsize = get(axis_handle,'FontSize');
org_ylim = get(axis_handle,'YLim');
org_xlim = get(axis_handle,'XLim');
org_yaxis_loc = get(axis_handle,'YAxisLocation');

% Delete the current label if already on the right
if strcmp(org_yaxis_loc,'right')
    set(get(axis_handle,'Ylabel'),'String','')
end

axis_handle_right = axes('Position',get(axis_handle,'Position'),'Units',get(axis_handle,'Units'),'Parent',get(axis_handle,'Parent'));
set(axis_handle_right,'YAxisLocation','right','Color','none','XTick',[]);

% Turn off numbers until scaling is fixed.
set(axis_handle_right,'YTick',[]);

% return font size
set(gca,'FontSize',org_fontsize)
set(gca,'YLim',org_ylim)
set(gca,'XLim',org_xlim)
set(gca,'Box','on')

% THIS DOESN'T WORK
% info_field_names = fields(org_stuff);
% for ifield = 1:size(info_field_names,1)
%     try
%         eval(['set(gca,''' cell2mat(info_field_names(ifield)) ''',org_stuff.' cell2mat(info_field_names(ifield)) ');'])
%     catch
%         cell2mat(info_field_names(ifield))
%     end
% end

ylabel(label_str)
