function Figure_Annotate(text_input,varargin) % Location,ax,Color
% Figure_Annotate(text_input,varargin) % Location,ax,Color
% Puts text in a corner of a plot. Esp useful for adding notes on what the data is
%
% text_input: For multiple lines use cell
% VARARGIN OPTIONS:
%     Location: 'NorthEast'[DEFAULT],'NorthWest,'SouthWest','SouthEast', OR
%               Quadrent number (1,2,3,4) or I,II,III,IV
%     Color: text color-letter (e.g. 'r'),
%            if its a list of color-letters each line will be a different color! (e.g. 'krg')
%     ax: axis handle
%
% EXAMPLE:
%     text_input={'Subject ID: ','Date: '};
%     figure_Annotate(text_input,'Location','NorthEast','rg')
%
% NOTE: Not relative to figure, only axis. Text positions will change with resizing
%       Resize before annotating (UNTIL BUG FIXED)
%
% For more text properties: http://www.mathworks.com/help/matlab/ref/text_props.html
%
% 2013-07-31 Foldes
% UPDATES:
% 2013-09-25 Foldes: MAJOR: added varargin, added colors
% 2013-10-21 Foldes: added str4plot

%% Defaults

defaults.ax = gca;
defaults.Location = 'NorthWest';
defaults.Color = 'k';
parms=varargin_extraction(defaults,varargin);

%% Get text box positions

% Get axis limits
x_range = get(parms.ax,'XLim');
y_range = get(parms.ax,'YLim');
% Could do instead:
% x = get(h,'XData');
% y = get(h,'YData');

switch parms.Location
    case {'NorthEast','I',1}
        % max X, max Y, vert top
        txt_pos = [x_range(2),y_range(2)];
        lon = 'East'; % longitude
        lat = 'North'; % latatude
    case {'NorthWest','II',2}
        % min X, max Y, vert top
        txt_pos = [x_range(1),y_range(2)];
        lon = 'West'; % longitude
        lat = 'North'; % latatude
    case {'SouthWest','III',3}
        % min X, min Y, vert bottom
        txt_pos = [x_range(1),y_range(1)];
        lon = 'West'; % longitude
        lat = 'South'; % latatude
    case {'SouthEast','IV',4}
        % max X, min Y, vert bottom
        txt_pos = [x_range(2),y_range(1)];
        lon = 'East'; % longitude
        lat = 'South'; % latatude
end

% % MIGHT NEED TO MAKE POS RELATIVE TO FIGURE
% [txt_fig_pos(1),txt_fig_pos(2)] = Figure_coordinates_from_data_space(parms.ax,txt_pos(1),txt_pos(2));


%% Prepare Lines

% make sure text is a cell, just easier
if ~iscell(text_input)
    org_text = text_input;
    clear text_input
    text_input{1}=org_text;
end
num_lines = length(text_input);

% make a long list of colors
color_list = repmat(parms.Color,1,num_lines);

% For South box locations, reverses line order and write backwards!
if strcmpi(lat,'South')
    clear org_text
    org_text = text_input;
    clear text_input
    cnt = 0;
    for iline = size(org_text,2):-1:1;
        cnt=cnt+1;
        text_input{cnt}=org_text{iline};
    end
    color_list = color_list(num_lines:-1:1); % reverse colors too
    vert_align = 'Bottom';
else
    vert_align = 'Top';
end


%% Write text box
for iline = 1:num_lines    
    h = text(txt_pos(1),txt_pos(2),str4plot(text_input{iline}),...
        'HorizontalAlignment','left',...
        'VerticalAlignment',vert_align,...
        'FontSize',10,'Color',color_list(iline));
    
    text_extent = get(h,'Extent'); % text box [left,bottom,width,height]
    % adjust y position for the next line ***THIS IS ONLY B/C OF COLORS***
    switch lat
        case 'North' % go down each line
            txt_pos(2)=txt_pos(2)-text_extent(4);
        case 'South' % go up 1 letter each line
            txt_pos(2)=txt_pos(2)+text_extent(4);
    end
    
    % move text to make sure its in the plot area (to keep it left-justified)
    % Only for East position
    if strcmpi(lon,'East')
        org_pos = get(h,'Position'); %
        new_pos = org_pos;
        new_pos(1)=org_pos(1)-text_extent(3);
        set(h,'Position',new_pos);
    end
    
end % lines










%% OLD
%
% switch position
%     case {'NorthEast','I',1}
%         % max X, max Y, vert top
%         h = text(x_range(2),y_range(2),text_input,...
%             'HorizontalAlignment','left',...
%             'VerticalAlignment','Top',...
%             'FontSize',10);
%         % move text to make sure its in the plot area (to keep it left-justified)
%         text_extent = get(h,'Extent'); % [left,bottom,width,height]
%         org_pos = get(h,'Position'); %
%         new_pos = org_pos;
%         new_pos(1)=org_pos(1)-text_extent(3);
%         set(h,'Position',new_pos);
%
%     case {'NorthWest','II',2}
%         % min X, max Y, vert top
%         h = text(x_range(1),y_range(2),text_input,...
%             'HorizontalAlignment','left',...
%             'VerticalAlignment','Top',...
%             'FontSize',10);
%
%     case {'SouthWest','III',3}
%         % min X, min Y, vert bottom
%         h = text(x_range(1),y_range(1),text_input,...
%             'HorizontalAlignment','left',...
%             'VerticalAlignment','Bottom',...
%             'FontSize',10);
%
%     case {'SouthEast','IV',4}
%         % max X, min Y, vert bottom
%         h = text(x_range(2),y_range(1),text_input,...
%             'HorizontalAlignment','left',...
%             'VerticalAlignment','Bottom',...
%             'FontSize',10);
%         % move text to make sure its in the plot area (to keep it left-justified)
%         text_extent = get(h,'Extent'); % [left,bottom,width,height]
%         org_pos = get(h,'Position'); %
%         new_pos = org_pos;
%         new_pos(1)=org_pos(1)-text_extent(3);
%         set(h,'Position',new_pos);
% end
