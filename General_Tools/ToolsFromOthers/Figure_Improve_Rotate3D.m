function Figure_Improve_Rotate3D(fig, butt)
% Figure_Improve_Rotate3D  Figure Control Widget: Manipulate figures with key and button presses
%
%   Figure_Improve_Rotate3D([fig], [buttons])
%
% Allows the user to rotate, pan and zoom a figure using key presses and
% mouse gestures. Additionally, press q to quit the widget, r to reset the
% axes and escape to close the figure. This function is non-blocking, but
% fixes axes aspect ratios.
%
% IN:
%   fig - Handle of the figure to be manipulated (default: gcf).
%   buttons - 4x1 cell array indicating the function to associate with
%             each mouse button (left to right) and the scroll action.
%             Functions can be any of:
%                'rot' - Rotate about x and y axes of viewer's coordinate
%                        frame
%                'rotz' - Rotate about z axis of viewer's coordinate frame
%                'zoom' - Zoom (change canera view angle)
%                'zoomz' - Move along z axis of viewer's coordinate frame
%                'pan' - Pan
%                '' - Don't use that button
%             Default: {'rot', 'zoomz', 'pan', 'zoomz'}).
%
% (C) Copyright Oliver Woodford 2006-2012
% Much of the code here comes from Torsten Vogel's view3d function, which
% was in turn inspired by rotate3d from The MathWorks, Inc.
% Thanks to Sam Johnson for some bug fixes and good feature requests.
%
% NOTES (Foldes)
%   You can overwrite button button controls outside of this. See at the very bottom for an example
%
% UPDATES:
% 2014-01-28 Foldes: Renamed from fcw, added camview local, scroll works in correct direction now, mouseup moves the light to the cam pos
% 2014-01-28 Foldes: Rotation changed to BST style. Original was aweful!!

% Parse input arguments
buttons = {'rot', 'pan', 'zoomz', 'zoom'};
switch nargin
    case 0
        fig = gcf;
    case 1
        if ~ishandle(fig)
            buttons = fig;
            fig = gcf;
        end
    otherwise
        buttons = butt;
end

% Clear any visualization modes we might be in
pan(fig, 'off');
zoom(fig, 'off');
rotate3d(fig, 'off');
% For each set of axes
for h = findobj(fig, 'Type', 'axes', '-depth', 1)'
    % Set everything to manual
    set(h, 'CameraViewAngleMode', 'manual', 'CameraTargetMode', 'manual', 'CameraPositionMode', 'manual');
    % Store the camera viewpoint
    set(h, 'UserData', camview(h));
end
% Initialize the callbacks
set(fig, 'WindowButtonDownFcn', {@mousedown, {str2func(['fcw_' buttons{1}]), str2func(['fcw_' buttons{2}]), str2func(['fcw_' buttons{3}])}}, ...
    'WindowButtonUpFcn', @mouseup, ...
    'KeyPressFcn', @keypress, ...
    'WindowScrollWheelFcn', {@scroll, str2func(['fcw_' buttons{4}])}, ...
    'BusyAction', 'cancel');
return

function keypress(src, eventData)
% Define button presses
% WARNING, THIS MIGHT BE OVERWRITTEN IN A PARENT FUNCTION

fig = ancestor(src, 'figure');
cax = get(fig, 'CurrentAxes');
if isempty(cax)
    return;
end
step = 1;
if ismember('shift', eventData.Modifier)
    step = 2;
end
if ismember('control', eventData.Modifier)
    step = step * 4;
end
% Which keys do what

% a-d:      rotate l/r
% w-s:      zoom z in/out
% <-|-> :   pan l/r
% ^|v :     pan up/down

switch eventData.Key
    
    case {'a'}
        fcw_rotz([], [0 step], cax);
    case {'d'}
        fcw_rotz([], [0 -step], cax);
    case {'s'}
        fcw_zoom([], [0 step], cax);
    case {'w'}
        fcw_zoom([], [0 -step], cax);
    case {'leftarrow'}
        fcw_pan([], [step 0], cax);
    case {'rightarrow'}
        fcw_pan([], [-step 0], cax);
    case {'uparrow'}
        fcw_pan([], [0 -step], cax);
    case {'downarrow'}
        fcw_pan([], [0 step], cax);
    case 'r'
        % Reset all the axes
        for h = findobj(fig, 'Type', 'axes', '-depth', 1)'
            camview(h, get(h, 'UserData'));
        end
    case 'q'
        % Quit the widget
        set(fig, 'WindowButtonDownFcn', [], 'WindowButtonUpFcn', @mouseup, 'KeyPressFcn', @keypress);
    case 'escape'
        close(fig);
end
return

function mousedown(src, eventData, funcs)
% Get the button pressed
fig = ancestor(src, 'figure');
cax = get(fig, 'CurrentAxes');
if isempty(cax)
    return;
end
switch get(fig, 'SelectionType')
    case 'extend' % Middle button
        method = funcs{2};
    case 'alt' % Right hand button
        method = funcs{3};
    case 'open' % Double click
        camview(cax, get(cax, 'UserData'));
        return;
    otherwise
        method = funcs{1};
end

% Set the cursor
switch func2str(method)
    case {'fcw_zoom', 'fcw_zoomz'}
        shape=[ 2   2   2   2   2   2   2   2   2   2 NaN NaN NaN NaN NaN NaN  ;
            2   1   1   1   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN  ;
            2   1   2   2   2   2   2   2   2   2 NaN NaN NaN NaN NaN NaN  ;
            2   1   2   1   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN  ;
            2   1   2   1   1   1   1   1   2 NaN NaN NaN NaN NaN NaN NaN  ;
            2   1   2   1   1   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN  ;
            2   1   2   1   1   1   1   1   2 NaN NaN NaN   2   2   2   2  ;
            2   1   2   1   1   2   1   1   1   2 NaN   2   1   2   1   2  ;
            2   1   2   1   2 NaN   2   1   1   1   2   1   1   2   1   2  ;
            2   2   2   2 NaN NaN NaN   2   1   1   1   1   1   2   1   2  ;
            NaN NaN NaN NaN NaN NaN NaN NaN   2   1   1   1   1   2   1   2  ;
            NaN NaN NaN NaN NaN NaN NaN   2   1   1   1   1   1   2   1   2  ;
            NaN NaN NaN NaN NaN NaN   2   1   1   1   1   1   1   2   1   2  ;
            NaN NaN NaN NaN NaN NaN   2   2   2   2   2   2   2   2   1   2  ;
            NaN NaN NaN NaN NaN NaN   2   1   1   1   1   1   1   1   1   2  ;
            NaN NaN NaN NaN NaN NaN   2   2   2   2   2   2   2   2   2   2  ];
    case 'fcw_pan'
        shape=[ NaN NaN NaN NaN NaN NaN NaN   2   2 NaN NaN NaN NaN NaN NaN NaN ;
            NaN NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN ;
            NaN NaN NaN NaN NaN   2   1   1   1   1   2 NaN NaN NaN NaN NaN ;
            NaN NaN NaN NaN NaN   1   1   1   1   1   1 NaN NaN NaN NaN NaN ;
            NaN NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN ;
            NaN NaN   2   1 NaN NaN   2   1   1   2 NaN NaN   1   2 NaN NaN ;
            NaN   2   1   1   2   2   2   1   1   2   2   2   1   1   2 NaN ;
            2   1   1   1   1   1   1   1   1   1   1   1   1   1   1   2 ;
            2   1   1   1   1   1   1   1   1   1   1   1   1   1   1   2 ;
            NaN   2   1   1   2   2   2   1   1   2   2   2   1   1   2 NaN ;
            NaN NaN   2   1 NaN NaN   2   1   1   2 NaN NaN   1   2 NaN NaN ;
            NaN NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN ;
            NaN NaN NaN NaN NaN   1   1   1   1   1   1 NaN NaN NaN NaN NaN ;
            NaN NaN NaN NaN NaN   2   1   1   1   1   2 NaN NaN NaN NaN NaN ;
            NaN NaN NaN NaN NaN NaN   2   1   1   2 NaN NaN NaN NaN NaN NaN ;
            NaN NaN NaN NaN NaN NaN NaN   2   2 NaN NaN NaN NaN NaN NaN NaN ];
    case {'fcw_rotz', 'fcw_rot'}
        % Rotate
        shape=[ NaN NaN NaN   2   2   2   2   2 NaN   2   2 NaN NaN NaN NaN NaN ;
            NaN NaN NaN   1   1   1   1   1   2   1   1   2 NaN NaN NaN NaN ;
            NaN NaN NaN   2   1   1   1   1   2   1   1   1   2 NaN NaN NaN ;
            NaN NaN   2   1   1   1   1   1   2   2   1   1   1   2 NaN NaN ;
            NaN   2   1   1   1   2   1   1   2 NaN NaN   2   1   1   2 NaN ;
            NaN   2   1   1   2 NaN   2   1   2 NaN NaN   2   1   1   2 NaN ;
            2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN   2   1   1   2 ;
            2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN   2   1   1   2 ;
            2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN   2   1   1   2 ;
            2   1   1   2 NaN NaN NaN NaN NaN NaN NaN NaN   2   1   1   2 ;
            NaN   2   1   1   2 NaN NaN   2   1   2 NaN   2   1   1   2 NaN ;
            NaN   2   1   1   2 NaN NaN   2   1   1   2   1   1   1   2 NaN ;
            NaN NaN   2   1   1   1   2   2   1   1   1   1   1   2 NaN NaN ;
            NaN NaN NaN   2   1   1   1   2   1   1   1   1   2 NaN NaN NaN ;
            NaN NaN NaN NaN   2   1   1   2   1   1   1   1   1 NaN NaN NaN ;
            NaN NaN NaN NaN NaN   2   2 NaN   2   2   2   2   2 NaN NaN NaN ];
    otherwise
        return
end
% Record where the pointer is
global fcw_POS
fcw_POS = get(0, 'PointerLocation');

% 2014-01-28 FOR ROTATION FROM BST
% Reset the motion flag
setappdata(fig, 'hasMoved', 0);
% Record mouse location in the figure coordinates system
setappdata(fig, 'clickPositionFigure', get(fig, 'CurrentPoint'));

% Set the cursor and callback
set(ancestor(src, 'figure'), 'Pointer', 'custom', 'pointershapecdata', shape, 'WindowButtonMotionFcn', {method, cax});
return

function mouseup(src, eventData)
% Clear the cursor and callback
set(ancestor(src, 'figure'), 'WindowButtonMotionFcn', '', 'Pointer', 'arrow');

% 2014-01-28 FOR ROTATION FROM BST
% Reset the motion flag
fig = ancestor(src, 'figure');
% Remove mouse appdata (to stop movements first)
setappdata(fig, 'hasMoved', 0);
if isappdata(fig, 'clickPositionFigure')
    rmappdata(fig, 'clickPositionFigure');
end


% Reset the light to be at the camera
% 2014-01-28 Foldes
% remove last light
delete(findobj(ancestor(src, 'figure'), 'type', 'light')); % not sure if this should be src or ancestor
% add a new light
camlight('headlight', 'infinite');

return

%% ==============================================================

function scroll(src, eventData, func)
% Get the axes handle
cax = get(ancestor(src, 'figure'), 'CurrentAxes');
if isempty(cax)
    return;
end
% Call the scroll function
func([], [0 10*eventData.VerticalScrollCount], cax); % 2014-01-28
return

function d = check_vals(s, d)
% Check the inputs to the manipulation methods are valid
global fcw_POS
if ~isempty(s)
    % Return the mouse pointers displacement
    new_pt = get(0, 'PointerLocation');
    d = fcw_POS - new_pt;
    fcw_POS = new_pt;
end
return

% Figure manipulation functions
function fcw_rot(s, d, cax)
d = check_vals(s, d);
try
    % Rotate XY (ORIGINAL -- THIS IS IMPOSSIBLE TO USE)
    %camorbit(cax, d(1), d(2), 'camera', [0 0 1]);
    
    % ===Rotate XY (BST: figure_3d.m)===
    
    fig = ancestor(cax, 'figure');
    
    % Set the motion flag
    setappdata(fig, 'hasMoved', 1);
    % Get current mouse location in figure
    curptFigure = get(fig, 'CurrentPoint');
    % motion = current point - starting point
    motionFigure = 0.3 * (curptFigure - getappdata(fig, 'clickPositionFigure'));
    % Update click point location
    setappdata(fig, 'clickPositionFigure', curptFigure);
    
    
    figPos = get(fig, 'Position');
    
    
    % Rotation functions : 5 different areas in the figure window
    %     ,---------------------------.
    %     |             2             |
    % .75 |---------------------------|
    %     |   3  |      5      |  4   |
    %     |      |             |      |
    % .25 |---------------------------|
    %     |             1             |
    %     '---------------------------'
    %           .25           .75
    %
    % ----- AREA 1 -----
    if (curptFigure(2) < .25 * figPos(4))
        camroll(cax, motionFigure(1));
        camorbit(cax, 0,-motionFigure(2), 'camera');
        % ----- AREA 2 -----
    elseif (curptFigure(2) > .75 * figPos(4))
        camroll(cax, -motionFigure(1));
        camorbit(cax, 0,-motionFigure(2), 'camera');
        % ----- AREA 3 -----
    elseif (curptFigure(1) < .25 * figPos(3))
        camroll(cax, -motionFigure(2));
        camorbit(cax, -motionFigure(1),0, 'camera');
        % ----- AREA 4 -----
    elseif (curptFigure(1) > .75 * figPos(3))
        camroll(cax, motionFigure(2));
        camorbit(cax, -motionFigure(1),0, 'camera');
        % ----- AREA 5 -----
    else
        camorbit(cax, -motionFigure(1),-motionFigure(2), 'camera');
    end
    
catch
    % Error, so release mouse down
    mouseup(cax)
end
return

function fcw_rotz(s, d, cax)
d = check_vals(s, d);
try
    % Rotate Z
    camroll(cax, d(2));
catch
    % Error, so release mouse down
    mouseup(cax)
end
return

function fcw_zoom(s, d, cax)
d = check_vals(s, d);
% Zoom
d = (1 - 0.01 * sign(d(2))) ^ abs(d(2));
try
    camzoom(cax, d);
catch
    % Error, so release mouse down
    mouseup(cax)
end
return

function fcw_zoomz(s, d, cax)
d = check_vals(s, d);
% Zoom by moving towards the camera
d = (1 - 0.01 * sign(d(2))) ^ abs(d(2)) - 1;
try
    camdolly(cax, 0, 0, d, 'fixtarget', 'camera');
catch
    % Error, so release mouse down
    mouseup(cax)
end
return

function fcw_pan(s, d, cax)
d = check_vals(s, d);
try
    % Pan
    camdolly(cax, d(1), d(2), 0, 'movetarget', 'pixels');
catch
    % Error, so release mouse down
    mouseup(cax)
end
return




%% ==============================================================

function Vo = camview(varargin)
%CAMVIEW  Records or sets the viewpoint of the current axes
%
%   Vo = camview([hAx], [Vi])
%
% Records or sets the viewpoint of the current axes, including projection
% type. This is useful for giving multiple axes (with the same coordinate
% frame) the same viewpoint, or resetting the viewpoint to a known point.
% A data aspect ratio of [1 1 1] is assumed.
%
% The view is recorded and set using a 4x4 matrix. The upper 3x4 quadrant
% of this matrix is a projection matrix from the axes coordinate frame to
% the camera coordinate frame (the view frustrum coordinates range from -1
% to 1 in x and y directions). Padding the last row with [0 0 0 1] makes it
% possible to use projection matrices computed externally.
%
% IN:
%    hAx - Handle to the axes in question. Default: gca.
%    Vi - 4x4 matrix defining the viewpoint to set the current axes to. The
%         matrix should defined by calling camview on previous axes.
%
% OUT:
%    Vo - 4x4 matrix specifying the viewpoint of the current axes just
%         prior to the function being called.

% Set default inputs
hAx = gca;
Vi = [];
% Parse the inputs
for a = 1:nargin
    if ishandle(varargin{a})
        hAx = varargin{a};
    else
        Vi = varargin{a};
    end
end

if nargout > 0
    % Get the current viewpoint
    t = get(hAx, 'CameraPosition');
    d = get(hAx, 'CameraTarget') - t;
    K = eye(3);
    K([1 5]) = 1 / tan(get(hAx, 'CameraViewAngle') * pi / 360);
    R(:,3) = d / norm(d);
    R(:,2) = get(hAx, 'CameraUpVector');
    R(:,1) = cross(R(:,3), R(:,2));
    Vo = K * R' * [eye(3) -t'];
    Vo(4,:) = [norm(d) 0 0 strcmp(get(hAx, 'Projection'), 'perspective')];
end
if ~isempty(Vi)
    % Decompose the projection matrix
    st = @(M) M(end:-1:1,end:-1:1)';
    [R, K] = qr(st(Vi(1:3,1:3)));
    K = st(K);
    I = diag(K) < 0;
    K(:,I) = -K(:,I);
    R = st(R);
    R(I,:) = -R(I,:);
    t = (K * R) \ -Vi(1:3,4);
    K = K / K(3,3);
    
    % Set the current viewpoint
    projection = {'perspective', 'orthographic'};
    set(hAx, 'CameraTarget', t'+R(3,:)*(Vi(4)+(Vi(4)==0)), ...
        'CameraPosition', t, ...
        'CameraUpVector', R(2,:), ...
        'CameraViewAngle', atan(1/K(5))*360/pi, ...
        'Projection', projection{(Vi(16)==0)+1});
end
return

%% =============================================

% EXAMPLE OF CODE YOU CAN ADD AFTER THIS FUNCTION RUNS TO ADD MORE BUTTON CLICK OPTIONS
%
% % Initialize the callbacks
% set(obj.h, 'KeyPressFcn', @change_view, ...
%     'BusyAction', 'cancel');
%
%
% function change_view(src, eventData)
% fig = ancestor(src, 'figure');
% cax = get(fig, 'CurrentAxes');
% if isempty(cax)
%     return;
% end
% step = 1;
% if ismember('shift', eventData.Modifier)
%     step = 2;
% end
% if ismember('control', eventData.Modifier)
%     step = step * 4;
% end
% eventData.Key
% % Which keys do what
% switch eventData.Key
%
%     case {'comma','<'}
%         disp('you win')
%     case {'period','>'}
%         disp('you win->>')
% end
% return

