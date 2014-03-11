function obj = Plot_Overlay(obj,NewOverlay,varargin) % 'Amplitude','Colormap','Viewpoint'
% Plot an overlay on a brain-surface figure.
% Multiple overlays will be additive
% Generate brain surface figure with Plot_Brain_Surface.m
% The data can be generated in Brainstorm (/brainstorm_db/Test/anat/Subject01_copy/tess_cortex_pial_low.mat)
%
% INPUTS:
%   NewOverlay.Values:      [nOverlay_Vertices x 1] Numbers corisponding to the Vertices that will have overlay
%                           If left out/empty, the Vertices can be used for discrete overlays (e.g. ROIs)
%   NewOverlay.Vertices:    [nOverlay_Vertices x 3] Vertices of the desired overlay
%                           You can leave out/empty if Values corrisponds to all Vertices in the Underlay (e.g. Sources)
%                           Defining all Vertices can be tricky since it will color the whole brain
%
% VARARGIN:
%
%   Amplitude:  Cut off of Values to show; 0 = show all, 1 = show highest value only
%   Colormap:   Colormap name, or single color (rgb or single color letter)
%                       for a gradiant, give a color map name ('hot'[DEFAULT],'gray','jet',etc)
%                       for a threshold/single color, use either an rgb value or the color-letter (e.g. 'r','g')
%
%   Viewpoint:  Camera position [x y], can be string: top [DEFAULT], back, left, right, front
%
%
% 2014-01-27 Foldes
% UPDATES:
% 2014-02-04 Foldes: Values or Vertices can be left out.
%

%% Parameters

% figure parameters
parms.Viewpoint =       []; % default is to not move the underlay

% Colors to use
parms.Colormap =        'jet';
parms.Transp =          0; % transparency
parms.Amplitude =       0;
parms.Abs =             1; % do by default
parms.BackgroundColor = 'k'; % REMOVE SOME TIME
parms = varargin_extraction(parms,varargin);

%% Setup

% Start underlay if there is no figure or the handel is dead
if isempty(obj.fig) || ~ishandle(obj.fig)
    % warning('Initalizing underlay. Consider running Plot_Underlay first')
    
    obj = Plot_Underlay(obj);
end
% Access figure
figure(obj.fig);hold all


% if no Vertices are given, See if Values are defined for all Underlay Vertices
if ~isfield(NewOverlay,'Vertices') || isempty(NewOverlay.Vertices)
    if ~isfield(NewOverlay,'Values') || isempty(NewOverlay.Values)
        error('You have to have some input, man')
    elseif length(NewOverlay.Values) == length(obj.Vertices)
        % No vertices were given b/c it wants you to use all
        NewOverlay.Vertices = obj.Vertices;
    else
        error('Vertices need to be provided. The number of Values does not match the Underlay Vertices')
    end
end

% if no values are given, make 1 (useful for threholded data)
if ~isfield(NewOverlay,'Values') || isempty(NewOverlay.Values)
    NewOverlay.Values = ones(size(NewOverlay.Vertices,1),1);
end

% Make sure the dims are right
if size(NewOverlay.Values,1) < size(NewOverlay.Values,2)
    NewOverlay.Values = NewOverlay.Values';
end
if size(NewOverlay.Vertices,1) < size(NewOverlay.Vertices,2)
    NewOverlay.Vertices = NewOverlay.Vertices';
end

%% Rectify (should be done by default
if parms.Abs == 1
    NewOverlay.Values = abs(NewOverlay.Values);
else
    warning('It is not recommended to remove the absolute value')
end

%% Coloring

% if the map is a color-letter, make it into RGB
if length(parms.Colormap) == 1 && ischar(parms.Colormap)
    parms.Colormap = color_name2rgb(parms.Colormap);
end

% Map the overlay values to the color map
if isnumeric(parms.Colormap)
    % if the map is a single rgb (or just was a color-letter), the colors should just be the rbg
    NewOverlay.VerticesColor = repmat(parms.Colormap, [length(NewOverlay.Values),1]);
else
    % use the color map to find the colors
    NewOverlay.VerticesColor = color_values(NewOverlay.Values,'colormap_name',parms.Colormap);
end

%% Apply Amplutude Cut off

% Normalize 0-1
norm_values =   (NewOverlay.Values - min(NewOverlay.Values))./abs(max(NewOverlay.Values) - min(NewOverlay.Values));

% Only plot vertices that have a normalized value over parms.Amplitude
above_thres_vrt =           find(norm_values >= parms.Amplitude);
NewOverlay.Values =         NewOverlay.Values(above_thres_vrt,:);
NewOverlay.Vertices =       NewOverlay.Vertices(above_thres_vrt,:);
NewOverlay.VerticesColor =	NewOverlay.VerticesColor(above_thres_vrt,:);


%% Add new overlay to list of overlays

% Get information to the figure handel
Overlay =   getappdata(obj.fig,'Overlay');

% ***DISABLED***
% % check that the data matches the expected num overlays
% if length(Overlay) ~= obj.nOverlays
%     warning('Number of Overlay Issue')
% end

NewOverlay.underlay_vertex = []; %needs to be initalized

% Put new overlay in the list of overlays
if ~isempty(Overlay) % add current overlay to the list
    Overlay(end+1) = NewOverlay;
else % no previous overlay
    Overlay = NewOverlay;
end


%% Add up overlays
nOverlay =  length(Overlay);
nVertices = size(obj.Vertices,1);

for ioverlay = 1:length(Overlay)
    for ivert = 1:size(Overlay(ioverlay).Vertices,1) % assumes [nVert x 3]
        
        % find vertex that matchs this one
        clear vert_dim_mask
        for idim = 1:3 % 3D
            vert_dim_mask(:,idim)=Overlay(ioverlay).Vertices(ivert,idim)==obj.Vertices(:,idim);
        end
        Overlay(ioverlay).underlay_vertex(ivert,:) = find(sum(vert_dim_mask,2)==3);
    end
end

% Overwrite obj.VerticesColor with new color
for ivert = 1:nVertices
    colors_4_vert = [];
    for ioverlay = 1:nOverlay
        current_overlay_vert_idx = find(Overlay(ioverlay).underlay_vertex == ivert);
        if ~isempty(current_overlay_vert_idx)
            colors_4_vert = [colors_4_vert; Overlay(ioverlay).VerticesColor(current_overlay_vert_idx,:)];
        end
    end
    if ~isempty(colors_4_vert)
        obj.VerticesColor(ivert,:) = mean(colors_4_vert,1);
    end
end


%% Plot brain surface
obj = Update_Surf(obj,parms);


%% Write Overlay to the figure

setappdata(obj.fig,'Overlay',Overlay);

obj.nOverlays = length(Overlay);


















