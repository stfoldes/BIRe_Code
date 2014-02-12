function hFig = BST_Set_Sources(hFig,SourceData)
% Applies SourceData (nSources x 1) to an already open BST figure
% hFig = view_surface(Inverse.SurfaceFile);
% 
% 2014-01-31 Foldes

% check
if ~strcmpi(get(gcf,'Tag'),'3DViz')
    error('Figure is NOT BST surface figure @BST_Set_Sources')
    return
end

%% ===Load and Set Info to BST figure===

% Get data from figure
Surface = getappdata(hFig,'Surface');

% Overwrite figure data
Surface.Data =              SourceData; 

Surface.DataMinMax =        [min(Surface.Data) max(Surface.Data)]; 
Surface.DataLimitValue =    [0 max(Surface.Data)]; % might be for color bar

% % Unknown parameters
% Surface.DataSource.Type =   'Source';
% Surface.ColormapType =      'source';

% Options
% Surface.SurfShowSulci =     1;

% Maybe, just maybe, you can add 2 Surface structs (there is also an iSurface variable)

% send data to figure
setappdata(hFig,'Surface',Surface);

% Color Map
% ColormapInfo = getappdata(hFig, 'Colormap');
% ColormapInfo.AllTypes =     {'source'};
% ColormapInfo.Type =         'source';
% setappdata(hFig, 'Colormap',ColormapInfo);

% FigureId
% FigureId = getappdata(hFig, 'FigureId');
% FigureId.Modality = 'MEG GRAD';
% setappdata(hFig, 'FigureId',FigureId);


%% Update the figure
figure_3d('UpdateSurfaceColor', hFig, 1); % line 1854
panel_surface('UpdateSurfaceProperties'); % update the gui display


%%
%     % Update surfaces
%     panel_surface('UpdateSurfaceColormap', hFig);
%                 % Update "Surfaces" panel
%                 panel_surface('UpdateSurfaceProperties');       
% 
% Surface.DataSource.Type = 'Source';
% 
% panel_surface('AddSurface', hFig, SurfaceFile);


% DEFAULT STRUCTURE
%
%  getappdata(hFig)
%                       Surface: [1x1 struct]
%                      iSurface: 1
%                     StudyFile: []     <--- 'Subject01_copy/1/brainstormstudy.mat'
%                   SubjectFile: 'Subject01_copy/brainstormsubject.mat'
%                      DataFile: []     <--- 'Subject01_copy/1/data_1_average_140128_1525.mat'  
%                   ResultsFile: []     <--- 'link|Subject01_copy/1/results_wMNE_MEG_GRAD_KERNEL_140124_1807.mat|Subject01_copy/1/data_1_average_140128_1525.mat'
%       isSelectingCorticalSpot: 0
%        isSelectingCoordinates: 0
%              isControlKeyDown: 0
%                isShiftKeyDown: 0
%                      hasMoved: 0
%             isPlotEditToolbar: 0
%          AllChannelsDisplayed: 0
%              ChannelsToSelect: []
%                      FigureId: [1x1 struct]
%                                Type: '3DViz'
%                                SubType: ''
%                                Modality: '' <--- 'MEG GRAD'
%                      isStatic: 0
%                  isStaticFreq: 1
%                      Colormap: [1x1 struct]
%                                AllTypes: {} <--- {'source'}
%                                Type: ''     <--- 'source'
%     uitools_FigureToolManager: [1x1 uitools.FigureToolManager]
%
%
% Surface = 
%         SurfaceFile: 'Subject01_copy/tess_cortex_pial_low.mat'
%                Name: 'Cortex'
%          DataSource: [1x1 struct]
%                         Type: ''      <--- 'Source'
%                         FileName: ''  <--- 'link|Subject01_copy/1/results_wMNE_MEG_GRAD_KERNEL_140124_1807.mat|Subject01_copy/1/data_1_average_140128_1525.mat'
%                         Atlas: []
%        ColormapType: ''               <--- 'source'
%              hPatch: 10.002
%           nVertices: 15002
%              nFaces: 29986
%           SurfAlpha: 0
%       SurfShowSulci: 0
%       SurfShowEdges: 0
%        AnatomyColor: [2x3 double]
%     SurfSmoothValue: 0
%                Data: []               <--- [15002x1]
%          DataMinMax: []               <--- [1x2]
%            DataWmat: []
%         OverlayCube: []
%           DataAlpha: 0
%       DataThreshold: 0.5
%       SizeThreshold: 1
%      DataLimitValue: []               <--- [1x2]
%        CutsPosition: [0 0 0]
%              Resect: 'none'
%          MipAnatomy: {3x1 cell}
%       MipFunctional: {3x1 cell}


% panel_surface
%     % Get surface list
%     TessInfo = getappdata(hFig, 'Surface');
%     % Add surface to the figure
%     iTess = AddSurface(hFig, SurfaceFile);
%     % 3D MRI: Update Colormap
%     if strcmpi(surfaceType, 'Anatomy')
%         % Get figure
%         [hFig,iFig,iDS] = bst_figures('GetFigure', hFig);
%         % Update colormap
%         figure_3d('ColormapChangedCallback', iDS, iFig);
%     end
%     % Reload scouts (only if new surface was added)
%     if (iTess > length(TessInfo))
%         panel_scouts('ReloadScouts', hFig);
%     end


%   % Get panel controls
%   panelSurfacesCtrl = bst_get('PanelControls', 'Surface');
% %   gui_enable(panelSurfacesCtrl.jToolbar, 1);
%   gui_enable(panelSurfacesCtrl.jPanelDataOptions, 1);
%   jSliderDataThresh
% (panelSurfacesCtrl.jPanelDataOptions); class thing
% 
% 
% 
% I'm trying to figure out how to turn on the DataOptions Panel
% Might have to be done when the figure is initially open
% Might just load MNE figure and remove the .Data? Probably easier








