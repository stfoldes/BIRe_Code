function Figure_Stretch(width,height)
%
% Just takes the current figure and stretches it proportionally
% Will do full screen if first input = 'full' (i.e. width = 'full') OR no inputs are given
% 
% Foldes 2012-10-05
% UPDATES:
% 2013-02-28 Foldes: Changed name from StretchFigure
% 2013-04-18 Foldes: Added full screen option
% 2013-08-29 Foldes: Tried to fix the linux/windows figure-position issue, stupid matlab

% For Full screen (then return)
if ~exist('width') || strcmpi(width,'full') 
%     set(gcf,'units','normalized','Position',[0.02 0 0.47 0.9]) % For Stephen's computer
    %set(gcf,'units','normalized','Position',[0 0 1 1]) % For complete full screen
    
    % Info about monitors (stupid matlab made this harder)
    [monitor_width,monitor_height] = ScreenSize;
    
    set(gcf,'units','pixels','Position',[0 0 monitor_width/2.1 monitor_height/1.1]);
    return
end

%%
if ~exist('width') || isempty(width)
    width = 1;
end

if ~exist('height') || isempty(height)
    height = 1;
end

%% Now apply
try
    set(gcf,'units','pixels');
    org_pos = get(gcf,'Position');
    org_ypos = org_pos(2);
    org_height = org_pos(4);   
    org_xpos = org_pos(1);
    org_width = org_pos(3);
    
    % org center
    center_x = org_xpos+(org_width/2);
    center_y = org_ypos+(org_height/2);
    
    % New dimensions
    new_width = (width*org_width);
    new_height =(height*org_height);
    
    % new center = org center, so move bottom-left corner
    new_xpos = center_x-(new_width/2);
    new_ypos = center_y-(new_height/2);

    set(gcf,'Position',[new_xpos new_ypos new_width new_height]);

end
drawnow