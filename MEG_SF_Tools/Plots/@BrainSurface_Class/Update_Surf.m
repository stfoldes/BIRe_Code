function obj = Update_Surf(obj,parms)
% Helper function
%   parms.Viewpoint:        Can be empty (or nonexist) to maintain view
%   parms.BackgroundColor
%   parms.Transp:           Empty uses previous surface's alpha
%
% 2014-01-27 Foldes
% UPDATES:
% 2014-01-28 Foldes: Added better UI
% 2014-02-06 Foldes: Added, changed from trisurf


%% Set up figure

if isempty(obj.fig)
    obj.fig = figure;
end
figure(obj.fig);hold all

% Make the figure DOUBLE the size if its the default size
current_pos =   get(obj.fig,'Position');
% current figure is the default size, then double it
if min(current_pos == get(0,'DefaultFigurePosition')) == 1
    Figure_Stretch(2,2);
end

%% Calculate colors
% HERE OR BEFORE THIS FUNCTION

%% Calculate Alpha

% If no Alpha defined, try to use the current, if there is a figure
if ~isfield(parms,'Transp') || isempty(parms.Transp) 
    if ~isempty(obj.hPatch) % you have a patch, see it's alpha
        parms.Transp = 1 - get(obj.hPatch,'FaceAlpha');
    else
        parms.Transp = 0; % DEFAULT
    end
end

%% Generate Patch

% Create patch
obj.hPatch = patch('Faces',     obj.Faces, ...
    'Vertices',         obj.Vertices,...
    'FaceVertexCData',  obj.VerticesColor, ...
    'FaceColor',        'interp', ...
    'FaceAlpha',        1 - parms.Transp, ...
    'AlphaDataMapping', 'none', ...
    'EdgeColor',        'interp', ...
    'BackfaceLighting', 'lit',...
    'Tag',              'BrainSurface');

% You can make the underlay a different transparenecy 
% %  Get Underlay gets one transp
% %  Overlay gets another
% Transp_Vert = 
% obj.hPatch = patch('Faces', obj.Faces, ...
%     'Vertices',             obj.Vertices,...
%     'FaceVertexCData',      obj.VerticesColor, ...
%     'FaceColor',            'interp', ...
%     'FaceAlpha',            'flat', ...
%     'AlphaDataMapping',     'none', ...
%     'FaceVertexAlphaData',  1 - Transp_Vert, ...
%     'EdgeColor',            'interp', ...
%     'BackfaceLighting',     'lit',...
%     'Tag',                  'BrainSurface');


% % This will also work
% trisurf(obj.Faces, obj.Vertices(:,1), obj.Vertices(:,2), obj.Vertices(:,3), ...
%     'FaceVertexCData', obj.VerticesColor, ...
%     'FaceColor', 'interp', ...
%     'FaceVertexAlphaData', parms.Transp*ones( size(obj.Vertices,1), 1 ), ...
%     'Tag', 'brain');


% Set viewing params
shading interp;
lighting gouraud;
material dull;

axis off
axis equal;
camproj('orthographic');

% set background
set(gcf, 'color',parms.BackgroundColor);

% Push data to figure
setappdata(obj.fig,'BrainSurface',obj); % write object to the figure


%% Set view and light

% if no view given, don't change the view
if ~isfield(parms,'Viewpoint')
    parms.Viewpoint = [];
end

% translate string Viewpoints into numbers based on typical
parms.Viewpoint = translate_viewpoint_name(parms.Viewpoint);

% set the view (if there is one)
if ~isempty(parms.Viewpoint)
    view(parms.Viewpoint);
end

% Update Light
% remove last light
delete(findobj(gca, 'type', 'light'));
% add a new light
camlight('headlight', 'infinite');

% Change the how the user interfaces with the figure
custom_control(obj.fig);

end % Update Surf



%% Smoothing (need sulci too)
% function [Vertices_sm, A] = tess_smooth(Vertices, a, nIterations, VertConn, isKeepSize, Faces)
% % TESS_SMOOTH: Smooths a surface.
% %
% % USAGE:  [Vertices_sm, A] = tess_smooth(Vertices, a, nIterations, VertConn, isKeepSize)
% %         [Vertices_sm, A] = tess_smooth(Vertices, a, nIterations, VertConn)
% %
% % INPUT:
% %    - Vertices    : [N,3] vertices of matrix to smooth
% %    - a           : scalar smooth weighting parameter (0-1 less-more smoothing)
% %    - nIterations : number of times to apply the smoothing
% %    - VertConn    : Vertex connectivity sparse matrix
% %    - isKeepSize  : If 1, the final surface is scaled so that the convex envelope
% %                    has the same bounding box as the initial surface
% % OUTPUT:
% %    - Vertices_sm : vertices list of smoothed surface
% %    - A           : smoothing matrix

% a = 1
% nIterations = 1
% isKeepSize = 1
% VertConn = 15002x15002
% Vertices = 15002x3

% Vertices_sm = 15002x3
% A = 15002x15002



% ========================================================================



function custom_control(fig)
%% Improve the control of the view, cam, light etc.
% <|>: Change view btw defaults

Figure_Improve_Rotate3D;

set(fig, 'KeyPressFcn', @keypress, ...
    'BusyAction', 'cancel');

end

%% Keypress instructions
function keypress(src, eventData)

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
switch eventData.Key
    %
    %     % If you want to switch btw all possible view defaults
    %     % your going to have to pass the view number through
    %     % handle's UserData (probably)
    %     % That's a pain
    %     %     case {'comma','<'}
    %     %         disp('you win')
    %     %     case {'period','>'}
    %     %         disp('you win->>')
    %
    
    case {'b','t','l','r','f'}
        % Translate key presses into default views
        % This requires translate_viewpoint_name() to have the key codes
        Viewpoint = translate_viewpoint_name(eventData.Key);
        % set the view (if there is one)
        if ~isempty(Viewpoint)
            view(Viewpoint);
        end
        
    case {'s'}
        set(fig, 'Pointer', 'cross');
        set(fig, 'WindowButtonDownFcn', @select_point);
        
end % switch

% Update Light
% remove last light
delete(findobj(gca, 'type', 'light'));
% add a new light
camlight('headlight', 'infinite');

end % keypress


%% Select point to find location
function select_point(src, eventData)

fig = ancestor(src, 'figure');
cax = get(fig, 'CurrentAxes');
% Get data from figure
Brain = getappdata(fig,'BrainSurface');


% Get cursor point in SCS (subject coordiant 'system')
[~, SelectedPoint.scsLoc, SelectedPoint.vertice]  = select3d(get(fig,'Children'));
SelectedPoint.scsLoc =  SelectedPoint.scsLoc * 1000;

% The T1 file is in the Underlay File folder (i.e. Surface File)
search_str = ['subjectimage_T1.mat'];
MRIFile_name = search_dir(dir_up(Brain.underlay_file),search_str,'SingleFile',1);
MRIFile = load(MRIFile_name);

fprintf('\nSELECTED POINT:\n');
fprintf('\tVertex:\t%i\n',SelectedPoint.vertice)
fprintf('\tSCS:\t x:%6.2f \ty:%6.2f \tz:%6.2f \n',SelectedPoint.scsLoc(1),SelectedPoint.scsLoc(2),SelectedPoint.scsLoc(3));

% get MRI from file
SelectedPoint.mriLoc =  cs_scs2mri(MRIFile, SelectedPoint.scsLoc);
fprintf('\tMRI:\t x:%6.2f \ty:%6.2f \tz:%6.2f \n',SelectedPoint.mriLoc(1),SelectedPoint.mriLoc(2),SelectedPoint.mriLoc(3));

    SelectedPoint.mniLoc =  cs_mri2mni(MRIFile, SelectedPoint.mriLoc); % Needs to be in MNI space
if ~isempty(SelectedPoint.mniLoc)
    fprintf('\tMNI:\t x:%6.2f \ty:%6.2f \tz:%6.2f \n',SelectedPoint.mniLoc(1),SelectedPoint.mniLoc(2),SelectedPoint.mniLoc(3));
    
    SelectedPoint.talLoc = mni2tal(SelectedPoint.mniLoc);
    fprintf('\tTAL*:\t x:%6.2f \ty:%6.2f \tz:%6.2f \n',SelectedPoint.talLoc(1),SelectedPoint.talLoc(2),SelectedPoint.talLoc(3));
end

% Update click point location
setappdata(fig, 'SelectedPoint', SelectedPoint);


% Return controls to normal
custom_control(fig);

end % select point




%% Default view points defined
function Viewpoint = translate_viewpoint_name(Viewpoint)
% translate string Viewpoints into numbers based on typical
if ischar(Viewpoint)
    switch lower(Viewpoint)
        case {'back','b'}
            Viewpoint = [270 0]; % back
        case {'top','t'}
            Viewpoint = [180 90]; % starting view (Top w/ nose to left)
        case {'left','l'}
            Viewpoint = [180 40];
        case {'right','r'}
            Viewpoint = [0 40];
        case {'front','f'}
            Viewpoint = [90 0];
            
        case {'left_motor'}
            Viewpoint = [180 50];
            %case 'bottom'
    end
end
end % translate view



