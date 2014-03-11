function obj = BST_Plot_Overlay(hFig,obj,varargin) % 'Amplitude','Colormap','Viewpoint'
%{
This plots on the figure, but some controls will re-overwrite it (since this is a link...hmmm)
    Amplitude is the main one.

For single overlay:
    It might be best to overwrite the AVG file for the power data (or any single overlays)
    OR it would be awesome if I could get a Data [15000 x 2] thing going (w/ multiple color maps)
%}
% Plot an overlay on a brain-surface figure.
% Multiple overlays will be additive
% Generate brain surface figure with Plot_Brain_Surface.m
% The data can be generated in Brainstorm (/brainstorm_db/Test/anat/Subject01_copy/tess_cortex_pial_low.mat)
%
% INPUTS:
%   obj.Values:      [nOverlay_Vertices x 1] Numbers corisponding to the Vertices that will have overlay
%                           If left out/empty, the Vertices can be used for discrete overlays (e.g. ROIs)
%   obj.Vertices:    [nOverlay_Vertices x 3] Vertices of the desired overlay
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
% 2014-02-17 Foldes: Sulci added (uses what ever is already pushed)

if ~ishandle(hFig)
    error('Figure dont exist')
end

%% Parameters

% figure parameters
parms.Viewpoint =       []; % default is to not move the underlay

% Colors to use
parms.Colormap =        'jet';
parms.Transp =          0; % transparency
parms.Amplitude =       0.5;
parms.Abs =             1; % do by default
parms.BackgroundColor = 'k'; % REMOVE SOME TIME
parms = varargin_extraction(parms,varargin);

%% Get info from figure

TessInfo = getappdata(hFig,'Surface');


%% Setup

% if no Vertices are given, See if Values are defined for all Underlay Vertices
if ~isfield(obj,'Vertices') || isempty(obj.Vertices)
    if ~isfield(obj,'Values') || isempty(obj.Values)
        error('You have to have some input, man')
    elseif length(obj.Values) == TessInfo.nVertices
        % No vertices were given b/c it wants you to use all
        obj.Vertices = get(TessInfo.hPatch,'Vertices');
    else
        error('Vertices need to be provided. The number of Values does not match the Underlay Vertices')
    end
end

% if no values are given, make 1 (useful for threholded data)
if ~isfield(obj,'Values') || isempty(obj.Values)
    obj.Values = ones(size(obj.Vertices,1),1);
end

% Make sure the dims are right
if size(obj.Values,1) < size(obj.Values,2)
    obj.Values = obj.Values';
end
if size(obj.Vertices,1) < size(obj.Vertices,2)
    obj.Vertices = obj.Vertices';
end

%% Rectify (should be done by default)
if parms.Abs == 1
    obj.Values = abs(obj.Values);
else
    warning('It is not recommended to remove the absolute value')
end

%% Coloring for Data

% if the map is a color-letter, make it into RGB
if length(parms.Colormap) == 1 && ischar(parms.Colormap)
    parms.Colormap = color_name2rgb(parms.Colormap);
end

% Map the overlay values to the color map
if isnumeric(parms.Colormap)
    % if the map is a single rgb (or just was a color-letter), the colors should just be the rbg
    obj.VerticesColor = repmat(parms.Colormap, [length(obj.Values),1]);
else
    % use the color map to find the colors
    obj.VerticesColor = color_values(obj.Values,'colormap_name',parms.Colormap);
end

%% Sulci (figure_3d line 1907)

if (TessInfo.SurfShowSulci == 1)
    % Get surface
    sSurf = bst_memory('GetSurface', TessInfo.SurfaceFile);
    SulciMap = sSurf.SulciMap;
else
    SulciMap = zeros(TessInfo.nVertices, 1);
end

% Create a background: light 1st color for gyri, 2nd color for sulci
naked_brain_VerticesColor = TessInfo.AnatomyColor(2-SulciMap, :);

% sColormap.CMap = parms.Colormap;
% % Make a ne
% mixedRGB = BlendAnatomyData(SulciMap, TessInfo.AnatomyColor, ...
%     obj.Values, [min(obj.Values) max(obj.Values)], TessInfo.DataAlpha, sColormap);


%% Apply Amplutude Cut off

% Normalize 0-1
norm_values =       (obj.Values - min(obj.Values))./abs(max(obj.Values) - min(obj.Values));

% Only COLOR vertices that have a normalized value over parms.Amplitude
below_thres_vrt =   find(norm_values < parms.Amplitude);
obj.VerticesColor(below_thres_vrt,:) = naked_brain_VerticesColor(below_thres_vrt,:);


%% Add new overlay to list of overlays

% Get information to the figure handel
Overlay =   getappdata(hFig,'Overlay');

% ***DISABLED***
% % check that the data matches the expected num overlays
% if length(Overlay) ~= obj.nOverlays
%     warning('Number of Overlay Issue')
% end

% obj.underlay_vertex = []; %needs to be initalized

% Put new overlay in the list of overlays
% if ~isempty(Overlay) % add current overlay to the list
%     Overlay(end+1) = obj;
% else % no previous overlay
%     Overlay = obj;
% end


%% Add up overlays ***WHY SO SLOW?***
% This is way too complicated for what is needed
% JUST MAKE SURE YOU HAVE ALL VERTICES DEFINED

%
% nOverlay =  length(Overlay);
% nVertices = size(obj.Vertices,1);
%
% I think this finds vertieces, not needed anymore
% for ioverlay = 1:length(Overlay)
%     for ivert = 1:size(Overlay(ioverlay).Vertices,1) % assumes [nVert x 3]
%
%         % find vertex that matchs this one
%         clear vert_dim_mask
%         for idim = 1:3 % 3D
%             vert_dim_mask(:,idim)=Overlay(ioverlay).Vertices(ivert,idim)==obj.Vertices(:,idim);
%         end
%         Overlay(ioverlay).underlay_vertex(ivert,:) = find(sum(vert_dim_mask,2)==3);
%     end
% end
%
% % Overwrite obj.VerticesColor with new color
% for ivert = 1:nVertices
%     colors_4_vert = [];
%     for ioverlay = 1:nOverlay
%         current_overlay_vert_idx = find(Overlay(ioverlay).underlay_vertex == ivert);
%         if ~isempty(current_overlay_vert_idx)
%             colors_4_vert = [colors_4_vert; Overlay(ioverlay).VerticesColor(current_overlay_vert_idx,:)];
%         end
%     end
%     if ~isempty(colors_4_vert)
%         obj.VerticesColor(ivert,:) = mean(colors_4_vert,1);
%     end
% end


%% NEW Add up Overlays

% nOverlay =  length(Overlay);
% nVertices = size(obj.Vertices,1);
%
% % Overwrite obj.VerticesColor with new color
% for ivert = 1:nVertices
%     colors_4_vert = [];
%     for ioverlay = 1:nOverlay
%         colors_4_vert = [colors_4_vert; Overlay(ioverlay).VerticesColor(current_overlay_vert_idx,:)];
%     end
%     if ~isempty(colors_4_vert)
%         obj.VerticesColor(ivert,:) = mean(colors_4_vert,1);
%     end
% end

%% Plot brain surface
% obj = Update_Surf(obj,parms);
% Create patch
% set(TessInfo.hPatch,'Faces',     obj.Faces, ...
%     'Vertices',         obj.Vertices,...
%     'FaceVertexCData',  obj.VerticesColor, ...
%     'FaceColor',        'interp', ...
%     'FaceAlpha',        1 - parms.Transp, ...
%     'AlphaDataMapping', 'none', ...
%     'EdgeColor',        'interp', ...
%     'BackfaceLighting', 'lit');

set(TessInfo.hPatch,...
    'Vertices',         obj.Vertices,...
    'FaceVertexCData',  obj.VerticesColor);

% set(TessInfo.hPatch,'Faces',     get(TessInfo.hPatch,'Faces'), ...
%     'Vertices',         obj.Vertices,...
%     'FaceVertexCData',  obj.VerticesColor, ...
%     'FaceColor',        'interp', ...
%     'FaceAlpha',        1 - parms.Transp, ...
%     'AlphaDataMapping', 'none', ...
%     'EdgeColor',        'interp', ...
%     'BackfaceLighting', 'lit');
%

% % Set viewing params
% shading interp;
% lighting gouraud;
% material dull;
%
% axis off
% axis equal;
% camproj('orthographic');
%
% % set background
% set(gcf, 'color',parms.BackgroundColor);

% % Update Light
% % remove last light
% delete(findobj(gca, 'type', 'light'));
% % add a new light
% camlight('headlight', 'infinite');


%% Write Overlay to the figure

setappdata(hFig,'Overlay',Overlay);

% obj.nOverlays = length(Overlay);




end


% %% ===== BLEND ANATOMY DATA =====
% % Compute the RGB color values for each vertex of an enveloppe.
% % INPUT:
% %    - SulciMap     : [nVertices] vector with 0 or 1 values (0=gyri, 1=sulci)
% %    - Data         : [nVertices] vector
% %    - DataLimit    : [absMaxVal] or [minVal, maxVal], or []
% %    - DataAlpha    : Transparency value for the data (if alpha=0, we only see the anatomy color)
% %    - AnatomyColor : [2x3] colors for anatomy (sulci / gyri)
% %    - sColormap    : Colormap for the data
% % OUTPUT:
% %    - mixedRGB     : [nVertices x 3] RGB color value for each vertex
% function mixedRGB = BlendAnatomyData(SulciMap, AnatomyColor, Data, DataLimit, DataAlpha, sColormap)
% % Create a background: light 1st color for gyri, 2nd color for sulci
% anatRGB = AnatomyColor(2-SulciMap, :);
% % === OVERLAY: DATA MAP ===
% if ~isempty(Data)
%     iDataCmap = round( ((size(sColormap.CMap,1)-1)/(DataLimit(2)-DataLimit(1))) * (Data - DataLimit(1))) + 1;
%     iDataCmap(iDataCmap <= 0) = 1;
%     iDataCmap(iDataCmap > size(sColormap.CMap,1)) = size(sColormap.CMap,1);
%     dataRGB = sColormap.CMap(iDataCmap, :);
% else
%     dataRGB = [];
% end
% % === MIX ANATOMY/DATA RGB ===
% mixedRGB = anatRGB;
% if ~isempty(dataRGB)
%     toBlend = find(Data ~= 0); % Find vertex indices holding non-zero activation (after thresholding)
%     mixedRGB(toBlend,:) = DataAlpha * anatRGB(toBlend,:) + (1-DataAlpha) * dataRGB(toBlend,:);
% end
% end










