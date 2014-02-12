



%% Load BST info
global BST_DB_PATH

BST_DB_PATH = '/home/foldes/Data/brainstorm_db/';

Extract.project =           'Test';
Extract.subject_id =        'Subject01_copy';
Extract.stim_name =         '1'; % name of stimulus
Extract.inverse_method =    'wMNE'; % 'dSPM' % The name of the method used

[Inverse,Surface,HeadModel] = BST_Load_Inverse_Data(Extract);

%% Plot atlas
Brain = BrainSurface_Class;
Brain.Faces =       Surface.Faces;
Brain.Vertices =    Surface.Vertices;

Brain = Brain.Plot_Underlay;




%% ===== BLEND ANATOMY DATA =====
% Compute the RGB color values for each vertex of an enveloppe.
% INPUT:
%    - SulciMap     : [nVertices] vector with 0 or 1 values (0=gyri, 1=sulci)
%    - Data         : [nVertices] vector 
%    - DataLimit    : [absMaxVal] or [minVal, maxVal], or []
%    - DataAlpha    : Transpar

panel_surface('AddSurface', hFig, SurfaceFile);ency value for the data (if alpha=0, we only see the anatomy color)
%    - AnatomyColor : [2x3] colors for anatomy (sulci / gyri)
%    - sColormap    : Colormap for the data
% OUTPUT:
%    - mixedRGB     : [nVertices x 3] RGB color value for each vertex
function mixedRGB = BlendAnatomyData(SulciMap, AnatomyColor, Data, DataLimit, DataAlpha, sColormap)
    % Create a background: light 1st color for gyri, 2nd color for sulci
    anatRGB = AnatomyColor(2-SulciMap, :);
    % === OVERLAY: DATA MAP ===
    if ~isempty(Data)
        iDataCmap = round( ((size(sColormap.CMap,1)-1)/(DataLimit(2)-DataLimit(1))) * (Data - DataLimit(1))) + 1;
        iDataCmap(iDataCmap <= 0) = 1;
        iDataCmap(iDataCmap > size(sColormap.CMap,1)) = size(sColormap.CMap,1);
        dataRGB = sColormap.CMap(iDataCmap, :);
    else
        dataRGB = [];
    end
    % === MIX ANATOMY/DATA RGB ===
    mixedRGB = anatRGB;
    if ~isempty(dataRGB)
        toBlend = find(Data ~= 0); % Find vertex indices holding non-zero activation (after thresholding)
        mixedRGB(toBlend,:) = DataAlpha * anatRGB(toBlend,:) + (1-DataAlpha) * dataRGB(toBlend,:);
    end
end



%%




% I could just grap the BST functions.
% Must start BST, export something, then my programs take over

brainstorm;

% Parameters
bst_db_path =       '/home/foldes/Data/brainstorm_db/';
project =           'Test';
subject_id =        'Subject01_copy';
stim_name =         '1'; % name of stimulus
inverse_method =    'wMNE'; % 'dSPM' % The name of the method used

% Build the file path to the inverse kernel
% EXAMPLE: /home/foldes/Data/brainstorm_db/Test/data/Subject01_copy/1/results_wMNE_MEG_GRAD_KERNEL_140124_1807.mat

% Search for file (ASSUMES ONLY ONE FILE THAT MATCH THIS CRITERA; easy to update later)
inverse_fullfile = cell2mat(search_dir(fullfile(bst_db_path,project,'data',subject_id,stim_name),['results_' inverse_method '*']));

% Load inverse kernel
load(inverse_fullfile);
%     ImagingKernel: [Sources x Sensors] This is the translation between the two
%     SurfaceFile: File name of the surface file (relative path; in the anat folder)
%     HeadModelFile: File name of the head model file (relative path; in the data|stim folder)

% Load surface for the subject
load(fullfile(bst_db_path,project,'anat',SurfaceFile));

% % Load head model for this run
% load(fullfile(bst_db_path,project,'data',HeadModelFile));

% Open surface plot
hFig = view_surface(SurfaceFile);


clear NewOverlay
NewOverlay.Vertices =   Vertices([1:400],:);
NewOverlay.Color =      'b';
% Brain = Brain.Plot_Overlay(NewOverlay,'Colormap',NewOverlay.Color);

sensor_num = 1:306;
sensor_num(3:3:306) = [];
new_sensor_num = find(sensor_num==43);

Sensors = zeros(204,1);
Sensors(new_sensor_num) =   1;
Sensors(new_sensor_num+1) = 1;

Sources = ImagingKernel * Sensors;

%% ===Load and Set Info to BST figure===

% Get data from figure
Surface=getappdata(hFig,'Surface');

% Overwrite figure data
% Surface.Data =              Sources;%[1:Surface.nVertices]'./Surface.nVertices;
Surface.Data = MNE_data;

Surface.DataMinMax =        [min(Surface.Data) max(Surface.Data)]; 
Surface.DataLimitValue =    [0 max(Surface.Data)]; % might be for color bar
Surface.ColormapType =    'source';
Surface.SurfShowSulci =     1;
setappdata(hFig,'Surface',Surface);

ColormapInfo = getappdata(hFig, 'Colormap');
ColormapInfo.Type =         'source';
setappdata(hFig, 'Colormap',ColormapInfo);


% Update the figure
figure_3d('UpdateSurfaceColor', hFig, 1); % line 1854
panel_surface('UpdateSurfaceProperties'); % update the gui display


%%
    % Update surfaces
    panel_surface('UpdateSurfaceColormap', hFig);
                % Update "Surfaces" panel
                panel_surface('UpdateSurfaceProperties');       

Surface.DataSource.Type = 'Source';

panel_surface('AddSurface', hFig, SurfaceFile);

% Make figure update (not sure)


% Test this by getting the data from the mne figure and put it on the cortex figure

%%
% 
% figure;
% % plot3(Vertices(:,1),Vertices(:,2),Vertices(:,3),'.')
% surface(Vertices(:,1),Vertices(:,2),Vertices(:,3),ones(length(Vertices),1)')
% 
% anatomyColor = [.45*[1 1 1]; .6*[1 1 1]];
% SurfColor = anatomyColor(2,:);
% SurfAlpha = 0;
% % BST must be on ;(
% % view_surface_matrix(Vertices, Faces)%, SurfAlpha, SurfColor, hFig)
% hFig = figure; hold all
% %     - Vertices  : [Nvx3] matrix with vertices
% %     - Faces     : [Nfx3] matrix with faces description
% %     - SurfAlpha : value that indicates surface transparency (optional)
% %     - SurfColor : Surface color [r,g,b] or FaceVertexCData matrix (optional)
% %     - hFig      : Specify the figure in which to display the surface (optional)
% figure_3d('PlotSurface', hFig, Faces, Vertices, SurfColor, SurfAlpha);
% 
% figure_3d('SetStandardView', hFig, 'top');


%% ===== PLOT SURFACE =====
% From figure_3d.m
% Convenient function to consistently plot surfaces.
% USAGE : [hFig,hs] = PlotSurface(hFig, faces, verts, cdata, dataCMap, transparency)
% Parameters :
%     - hFig         : figure handle to use
%     - faces        : the triangle listing (array)
%     - verts        : the corresponding vertices (array)
%     - surfaceColor : color data used to display the surface itself (FaceVertexCData for each vertex, or a unique color for all vertices)
%     - dataColormap : colormap used to display the data on the surface
%     - transparency : surface transparency ([0,1])
% Returns :
%     - hFig : figure handle used
%     - hs   : handle to the surface
% function varargout = PlotSurface( hFig, faces, verts, surfaceColor, transparency) %#ok<DEFNU>
    % Check inputs
    if (nargin ~= 5)
        error('Invalid call to PlotSurface');
    end
    % If vertices are assumed transposed (if the assumption is wrong, will crash below anyway)
    if (size(verts,2) > 3)
        verts = verts';
    end
    % If vertices are assumed transposed (if the assumption is wrong, will crash below anyway)
    if (size(faces,2) > 3)
        faces = faces';  
    end
    % Surface color
    if (length(surfaceColor) == 3)
        FaceVertexCData = [];
        FaceColor = surfaceColor;
        EdgeColor = 'none';
    elseif (length(surfaceColor) == length(verts))
        FaceVertexCData = surfaceColor;
        FaceColor = 'interp';
        EdgeColor = 'interp';
    else
        error('Invalid surface color.');
    end
    % Set figure as current
    set(0, 'CurrentFigure', hFig);
    
    % Create patch
    hs = patch('Faces',            faces, ...
               'Vertices',         verts,...
               'FaceVertexCData',  FaceVertexCData, ...
               'FaceColor',        FaceColor, ...
               'FaceAlpha',        1 - transparency, ...
               'AlphaDataMapping', 'none', ...
               'EdgeColor',        EdgeColor, ...
               'BackfaceLighting', 'lit');
    % Configure patch material
    material([ 0.5 0.50 0.20 1.00 0.5 ])
    lighting phong
    
    % Set output variables
    if(nargout>0),
        varargout{1} = hFig;
        varargout{2} = hs;
    end
end