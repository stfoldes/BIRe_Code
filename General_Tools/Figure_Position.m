function Figure_Position(x,y,h)
%function Figure_Position(x,y,h)
% Just move current figure (or figure with given handle, h)
%
% x,y [OPTIONAL]: Position of figure in units of % of workspace, can move one dimension only if desired
%                 Center of box is placed in position, but can't go off the screen
% h[OPIONAL]: handle
%
% 2013-06-07 Foldes
% UPDATES:
% 2013-07-30 Foldes: Added handle
% 2013-08-29 Foldes: Fixed Matlabs mistakes with 'normalized' figure position (dude, it could be over 1!)

% initialize handle
if ~exist('h') || isempty(h)
    h = gcf;
end

% set(h,'Units','Normalized')
% orig_pos = get(h,'Position');


set(h,'Units','Pixels')
orig_pos = get(h,'Position');

% Info about monitors (stupid matlab made this harder)
[monitor_width,monitor_height] = ScreenSize;

% Get screen limits to make sure the box doesn't go off the screen
x_max = monitor_width-orig_pos(3); % can't go past width of box
y_max = monitor_height-orig_pos(4);

if ~exist('x') || isempty(x)
    x=orig_pos(1);
end
if ~exist('y') || isempty(y)
    y=orig_pos(2);
end

set(h,'Position',[x*x_max y*y_max orig_pos(3) orig_pos(4)])
figure(h)

% % The default way move the top left corner of the box to the location
% set(h,'Units','normalized');
% org_pos = get(h,'Position');
% set(h,'Position',[0.5 1 org_pos(3) org_pos(4)])

drawnow