function [width,height] = ScreenSize
% Gets the width and height for a multimonitor system.
% HEIGHT IS THE MAXIMUM OF MULTIPLE SCREENS
% This is really tricky since Matlab can't figure this out.
% Things are different on different systems (linux/mac/windows)
%
% 2013-08-30 Foldes
% UPDATES:
%

% Info about monitors (stupid matlab made this harder)
monitor_pos = get(0,'MonitorPositions');

% For 1 screen OR Linux/Mac
if size(monitor_pos,2)==1
    width  = monitor_pos(:,3);
    height = monitor_pos(:,4);
    
else % Windows multiple screens
    
    width  = sum(max(abs(monitor_pos(:,1))+1,abs(monitor_pos(:,3)))); % Not sure why +1 is needed, but it is (2013-08-30)
    height = sum(max(abs(monitor_pos(:,2))+1,abs(monitor_pos(:,4))));
end


