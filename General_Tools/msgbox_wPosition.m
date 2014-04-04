function hh = msgbox_wPosition(Pos,message_str,title_str,icon)
% Message box with position
% See msgbox help for more info
%
% Most inputs are opional except message_str
% This secretly changes the font to be bigger
%
% 2013-07-30 Foldes
% UPDATES

% Defaults
if isempty(Pos)
    Pos = [0 1];
end
if ~exist('title_str') || isempty(title_str)
    title_str = '';
end
if ~exist('icon') || isempty(icon)
    icon = 'none';
end
    
h=msgbox(message_str,title_str,icon);

% Cheat and change the font
ah = get( h, 'CurrentAxes' );
ch = get( ah, 'Children' );
set( ch, 'FontSize', 12 );

Figure_Position(Pos(1),Pos(2),h);

% Only send outputs if requested
if nargout
    hh = h;
end
