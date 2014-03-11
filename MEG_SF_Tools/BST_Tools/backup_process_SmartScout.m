function varargout = process_SmartScout( varargin )

% http://neuroimage.usc.edu/brainstorm/Tutorials/TutUserProcess

macro_methodcall;
end


%% ===== GET DESCRIPTION =====
function sProcess = GetDescription()
% Description the process
sProcess.Comment     = 'SmartScout';
sProcess.FileTag     = '| SmartScout';
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'Scout';
sProcess.Index       = 1000; % ? Why isn't this defined elsewhere?
% Definition of the input accepted by this process
sProcess.InputTypes  = {'results'};
sProcess.OutputTypes = {'results'};
%sProcess.InputTypes  = {'data', 'results', 'timefreq', 'matrix'};
%sProcess.OutputTypes = {'data', 'results', 'timefreq', 'matrix'};
sProcess.nInputs     = 1;
sProcess.nMinFiles   = 0;
% Default values for some options
sProcess.isSourceAbsolute = 0;
sProcess.processDim       = [];

% Definition of the options
% === Scout Method ===
sProcess.options.scoutmethod.Comment = 'Scout calculation method: ';
sProcess.options.scoutmethod.Type    = 'text';
sProcess.options.scoutmethod.Value   = 'View, Threshold, MaxPoint';

% === MaskAtlas ===
sProcess.options.MaskAtlas.Comment = 'Optional Scout MaskAtlas: ';
sProcess.options.MaskAtlas.Type    = 'text';
sProcess.options.MaskAtlas.Value   = 'MaskAtlas';
% === MaskScouts ===
sProcess.options.MaskScouts.Comment = 'Optional Scout MaskScouts: ';
sProcess.options.MaskScouts.Type    = 'text';
sProcess.options.MaskScouts.Value   = 'MaskScouts';

% Display, nameing, color, threholds

end


%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess)
Comment = 'Scouts are great';
%     % Get frequency band
%     time = sProcess.options.baseline.Value{1};
%     % Add frequency band
%     if any(abs(time) > 2)
%         Comment = sprintf('Z-score normalization: [%1.3fs,%1.3fs]', time(1), time(2));
%     else
%         Comment = sprintf('Z-score normalization: [%dms,%dms]', round(time(1)*1000), round(time(2)*1000));
%     end
end


%% ===== RUN =====
function sInput = Run(sProcess, sInput)

% Get inputs from user input
scout_method =  sProcess.options.scoutmethod.Value{1};
MaskAtlas =     sProcess.options.MaskAtlas.Value{1};
MaskScouts =    sProcess.options.MaskScouts.Value{1};

if isempty(scout_method)
    bst_report('Error', sProcess, [], 'Invalid SmartScout Method.');
    sInput = [];
    return;
end

% Open figure, needs timing info, and maybe thresholds? or just pause to open? not sure will work

% Compute
sInput.A = Compute(sInput, scout_method,'MaskAtlas',MaskAtlas,'MaskScouts',MaskScouts);

end % Run

%% ===== COMPUTE =====
function ScoutInfo = Compute(sInput, scout_method, varargin)
% ScoutInfo = process_SmartScout('Compute',sInput/hFig, scout_method, varargin)
%
% Creates a scout using a variaty of methods based on the data of an open source figure
% Generates an Atlas called "SmartScout PROTOCOLNAME". Scouts are added to the existing
% atlas (if it exists).
% Will apply an ROI-mask before calculating the scout (see info below).
%
% INPUTS:
%   sInput (or hFig): Either the sInput from "Matlab Run" OR a list of figure handles that the
%       scout calculation is to be performed on OR [] (empty) to get all 3DViz figures open
%
%   scout_method: Method for calculating scouts (sub-functions at bottom of this program)
%       'View': Scout will include all the active vertices seen on the surface-figure
%       'Threshold': Define thresholds (see varargin info)
%       'MaxPoint': Scout is the maximum point (or points if tie)
%
% OUTPUTS:
%   ScoutInfo:  Struct full of information about what was performed and some analysis also
%               ScoutInfo is saved in the anat/subject folder of the protocol.
%               It would be good if this information was added to the surface file one day
%
% VARARGIN:
%     % ---DISPLAY---
%     Color =               RGB or color-letter for the scout [DEFAULT: Random]
%     NameStr =             Name for scout (see NameDesign)
%     NameDesign =          'Design' to build scout name. Designs programatically build a str
%                           [DEFAULT: '[subject]_[condition]_[scout_method]';]
%                           Avalible parameters: all parms, subject, condition, scout_method, surface
%
%     %---OVERLAP---
%     MaskAtlas =           Atlas name for scouts to mask e.g. 'Desikan-Killiany'; ONLY works for
%                           one atlas rigth now (you can  manually add scouts to a 'User scouts')
%     MaskScouts =          Scout list separated by '|' e.g. 'postcentral L|precentral L|precentral R';
%
%     % ---THRESHOLD---
%     DataThreshold =       Threshold as % (same as 'Amplitude' in BST)
%     DataThresholdValue =  Threshold as value
%     SizeThreshold =       Number of vertices for clustering limit (same as 'Min size')
%
%     % ---SAVING---
%     BYPASSOVERWRITE =     Some scout methods should overwrite itself upon a second creation,
%                           this flag will by pass this overwriting (so everything is saved)
%     TimeSeries_Function = How the single timeseries plot will be calculated (main options: 'Mean',
%                           'Power','PCA') (SEE: bst_scout_value)
%
%     % ---CALC---
%     Conservative =        If false, an 'inclusive' approach will be taken which will 'swell' the
%                           scout by 1 vertex in all directions to include neighboring vertices.
%                           This is useful to make sure your ROI is not constricting. [DEFAULT: true]
%
% EXAMPLE:
%   Build a scout from the data that is shown on EVERY open source-figure
%   The new scout will be named '[subject]_[condition]_[scout_method]' in the SmartScout atlas
%       process_SmartScout('Compute',[],'View');
%
%   Scout from the view of the current figure, but only in post-central area.
%       process_SmartScout('Compute',gcf,'View',...
%           'MaskAtlas','Desikan-Killiany','MaskScouts','postcentral L',...
%           'NameDesign','[condition]_[MaskScouts]');
%
%
% BUGS/IMPROVEMENTS:
%   ScoutInfo should be saved in the DB, now it is just in the Scout file
%   Atlas must be deleted before loading it again. Otherwise BST will erroneously rename the atlas
%   import_label will kick out an error if there are no vertices
%
% 2014-02-25 Foldes
% UPDATES:
%

%% VARARGIN DEFAULTS

% ---DISPLAY---
parms.Color =               rand(1,3); % random % Can be matlab letter or RGB
parms.NameDesign =          '[subject]_[condition]_[scout_method]'; % Avalible: all parms, subject, condition, scout_method, surface
parms.NameStr =             []; % Name for scout

% ---SAVING---
parms.BYPASSOVERWRITE =     false; % if true, will prevent overwriting of scouts (some scouts auto overwrite so you don't build up scouts)
parms.TimeSeries_Function = 'PCA'; % How the single timeseries plot will be calculated (main options: 'Mean','Power','PCA') (SEE: bst_scout_value)

% ---CALC---
parms.Conservative =        true; % Be conservative by default

% ---THRESHOLD---
parms.DataThreshold =       []; % Threshold as % (same as 'Amplitude' in BST)
parms.SizeThreshold =       []; % Number of sources
parms.DataLimitValue =      []; %
parms.DataThresholdValue =  []; % Threshold as value

%---OVERLAP---
parms.MaskAtlas =           []; % atlas name for scouts to mask e.g. 'Desikan-Killiany'; ONLY works for one atlas now
parms.MaskScouts =          []; % scout list separated by '|' e.g. 'postcentral L|precentral L|precentral R';

% ---Parse varargin---
parms = varargin_extraction(parms,varargin);

%% Get Surface Figure (this could be fancier one day)

if isstruct(sInput) % input is a sInput, get figure-name from sInput structure
    % Figure name should be this
    fig_name = ['MEG/3D: '  sInput.SubjectName filesep sInput.Condition];
    % Get all 3DViz figure handles
    hFig = findobj('Type','figure','Name',fig_name,'Tag','3DViz');
elseif ishandle == 1 % handles are valid inputs, esp. for mass running on all open figures w/o panel
    hFig = sInput;
elseif isempty(sInput) % No input, get all valid figures
    hFig = findobj('Type','figure','Tag','3DViz');
end

if isempty(hFig)
    error('Surface-figure you want scouts on must be open')
end
if length(hFig)>1 % more than one figure found, loop through all (RECURSIVE)
    for ifig = 1:length(hFig)
        % ScoutInfo{ifig} = BST_SmartScout(hFig(ifig),scout_method,varargin{:});
        ScoutInfo{ifig} = process_SmartScout('Compute',hFig(ifig),scout_method,varargin{:});
    end
    warning('***More than 1 surface-figure possible: Doing on all***')
    return
end
fig_name = get(hFig,'Name');
disp(['Building SmartScout on: ' fig_name])

% Get info from figure
TessInfo = getappdata(hFig,'Surface');
% Get surface
sSurf = bst_memory('GetSurface', TessInfo.SurfaceFile);

%% Get info for the new scout, including naming and parameters

% parse DataSource name for info
datasource_name = strrep(TessInfo.DataSource.FileName,'link|','');
[NamingInfo.subject remain] =   strtok(datasource_name,'/\'); % can't be just filesep b/c +++BST-BUG+++
[NamingInfo.condition remain] = strtok(remain,'/\');
NamingInfo.surface =            TessInfo.SurfaceFile;
NamingInfo.scout_method =       scout_method;
NamingInfo =                    copy_fields(parms,NamingInfo);

if isempty(parms.NameStr)
    % Creates a string based on a design which can input properties of the NamingInfo
    parms.NameStr = str_from_design(NamingInfo,parms.NameDesign);
end

%% Build new scouts with subfunctions

eval(['[Scout, ScoutInfo] = ' scout_method '(TessInfo,sSurf,parms);']);

% ---Inflate the scout by 1 vertex to be inclusive---
% (SEE: panel_scout('EditScoutsSize','Grow'))
if ScoutInfo.parms.Conservative == false % (defined in scout_method)
    Scout.Vertices = sort([Scout.Vertices; tess_scout_swell(Scout.Vertices, sSurf.VertConn)']);
end

% AUTO
Scout.Seed =     []; % BST will recalculate for you later (plus doesn't matter)
Scout.Function = parms.TimeSeries_Function; % Only maters if you want timeseries (main options: 'Mean','Power','PCA')
Scout.Region =   []; % does this matter?
Scout.Handles =  []; % don't think this matters

%% Populate ScoutInfo

% Add basic info to ScoutInfo
ScoutInfo.fig_name =        fig_name;
ScoutInfo.scout_method =    scout_method;
ScoutInfo.subject =         NamingInfo.subject; % where the Data comes from
ScoutInfo.condition =       NamingInfo.condition; % where the Data comes from
ScoutInfo.surface =         NamingInfo.surface;
ScoutInfo.parms_in =        parms; % parms that we desired, not necessarly the parms that were used
ScoutInfo.date_generated =  datestr(now,'yyyy-mm-dd HH:MM');

% More info is added later

%% Add new scout to the existing list (move Scout and ScoutInfo to SmartScout.*)

%  Preventing the overwriting
if parms.BYPASSOVERWRITE
    ScoutInfo.parms.OVERWRITE = false;
end

ProtocolInfo = bst_get('ProtocolInfo');
SmartScout.Name = ['SmartScout ' ProtocolInfo.Comment]; % Name of Atlas; Could use 'User scouts';

% Load existing Scout and ScoutInfo
[SmartScout.Scouts,SmartScout.ScoutInfo,ScoutFiles,selected_iAtlas] = Load_Scout_and_ScoutInfo(sSurf,SmartScout.Name);

% Add scout to the list by default
scout_num = length(SmartScout.Scouts)+1; % add to end, unless...
% Overwrite existing if there are scouts w/ the same name AND you want them overwritten
if ~isempty(SmartScout.Scouts) % need some scouts to check against
    % Find any scouts w/ the same name and replace them
    existing_scout_idx = find_lists_overlap_idx(struct_field2cell(SmartScout.Scouts,'Label'),Scout.Label);
    if ~isempty(existing_scout_idx) && ScoutInfo.parms.OVERWRITE
        scout_num = existing_scout_idx; % Write over
    end
end

% Add scout to atlas
if ~isempty(SmartScout.Scouts)
    Scout = orderfields(Scout,SmartScout.Scouts); % Matlab is dumb, you have to ensure the correct field order to add
    SmartScout.Scouts(scout_num) = Scout; % Add scout
    SmartScout.ScoutInfo{scout_num} = ScoutInfo; % Add ScoutInfo
else % first entry
    SmartScout.Scouts = Scout;
    SmartScout.ScoutInfo{1} = ScoutInfo;
end
SmartScout.TessNbVertices = TessInfo.nVertices; % a bit of basic info needed

%% Save atlas file and Import

save(ScoutFiles,'-struct','SmartScout','Name','TessNbVertices','Scouts','ScoutInfo'); % Also saves ScoutInfo

% Load all files selected by user
if ~isempty(Scout.Vertices) % import_label crashes if no Vertices +++BST-BUG+++
    % Remove existing scout (b/c of +++BST-BUG+++)
    if ~isempty(selected_iAtlas) % only if there is an existing atlas
        panel_scout('SetCurrentAtlas',selected_iAtlas); % Set current atlas
        panel_scout('RemoveAtlas'); % Removes the current Atlas
    end
    
    [sAtlas, Messages] = import_label(sSurf.FileName, ScoutFiles, 1); % should use isNewAtlas = 0 to overwrite previous, but there is a +++BST-BUG+++
    % This activates the new atlas (the last scout)
    panel_scout('SetSelectedScouts',scout_num);
else
    warning([Scout.Label ' is empty!'])
end

% Add advanced information to ScoutInfo (scout must be saved first)
ScoutInfo = ScoutReport(ScoutInfo);

%% Custom viewing (could be parms one day)

% % Turn border on (1) and off (0) (you will want 1 for non-face points)
% panel_scout('SetScoutContourVisible',1);
% Turn text on (1) and off (0)
panel_scout('SetScoutTextVisible',0);
% % Adjust the transparency (0-1) [DEFAULT: 0.7] (ONLY WORKS FOR TRANSPARENT VIEW)
% transp = 0.7;
% panel_scout('SetScoutTransparency',transp);
%
% save
panel_scout('SaveModifications');
% Hide progress bar (sometimes things get stuck)
bst_progress('stop');

% % Change source-patch to discrete
% TessInfo = getappdata(gcf,'Surface');
% set(TessInfo.hPatch,'FaceColor','flat')

end % Compute
% ===================================================================================





%% ==================================================================================
%  ===METHODS FOR CALCULATING SCOUTS=================================================
%% ==================================================================================
% All methods must make the following Scout structure
%       Scouts:
%           Vertices: [1x438 double]
%           Color: [1 1 0]    % I will translate single-letter colors
%           Label: '3'        % Name of scout
%
%       ScoutInfo:
%           All information is optional except: .OVERWRITE, .Conservative, .Data
%
% Inputs are: (TessInfo,sSurf,parms)
%
% 'Threshold' is a complicated example, but very thourough

%% ===Threshold===
function [Scout, ScoutInfo] = Threshold(TessInfo,sSurf,parms)
%  Calculate scout using thresholds
%  This includes the settings for amplitude and cluster size
%  Will limit search to given MaskScout
%  2014-02-22 Foldes
%  UPDATES:
%

%% Set display info
Scout.Label =                   parms.NameStr; % Name that will be use
Scout.Color =                   color_name2rgb(parms.Color); % Can be matlab letter or RGB
ScoutInfo.parms.OVERWRITE =     true; % Do you want the scout to be overwriten when you run this? [default = true]
ScoutInfo.parms.Conservative =  parms.Conservative; % for saving

%% CALCULATE SCOUT VERTICES

% Limit data to only vert in the MaskScouts
[ScoutInfo.Vertices_ROI,ROI_Mask] = Limit_Vertices_with_Scouts([],sSurf,parms.MaskAtlas,parms.MaskScouts);
Data_from_ROI = TessInfo.Data .* ROI_Mask;

% Define data limits (this is usually govenered by other funtions that call 'Threshold', like 'View')
if ~isempty(parms.DataLimitValue)
    % Use the data limit if given (usually TessInfo.DataLimitValue)
    ScoutInfo.parms.DataLimitValue =  parms.DataLimitValue;
else
    % Data limit is now defined only by the ROI
    ScoutInfo.parms.DataLimitValue =  [0,max(Data_from_ROI)];
end

% Use given threshold if possible
if ~isempty(parms.DataThreshold)
    ScoutInfo.parms.DataThreshold =   parms.DataThreshold;
else
    ScoutInfo.parms.DataThreshold =   TessInfo.DataThreshold;
end
if ~isempty(parms.SizeThreshold)
    ScoutInfo.parms.SizeThreshold =   parms.SizeThreshold;
else
    ScoutInfo.parms.SizeThreshold =   TessInfo.SizeThreshold;
end

% Set threshold (as a value OR as a %)
if ~isempty(parms.DataThresholdValue)
    % Use a value instead of relative
    DataSurf = Data_from_ROI;
    DataSurf(DataSurf < parms.DataThresholdValue) = 0;
else
    % This uses the threshold and clustering done in figure_3d
    sColormap = bst_colormaps('GetColormap', 'source');
    % Threshold and cluster data w/ BST function
    [DataSurf, ThreshBar] = figure_3d('ThresholdSurfaceData',Data_from_ROI, ScoutInfo.parms.DataLimitValue, ScoutInfo.parms.DataThreshold, sColormap);
end
% Get clusters that are above the threshold
iVertOk = bst_cluster_threshold(abs(DataSurf), ScoutInfo.parms.SizeThreshold, sSurf.VertConn);
DataSurf(~iVertOk) = 0;
Scout.Vertices = find(DataSurf>0); % Defining vertices (This is vertex number, not location)
ScoutInfo.Data = TessInfo.Data(Scout.Vertices); % Save out Data

end % THRESHOLD

%% ===View===
function [Scout, ScoutInfo] = View(TessInfo,sSurf,parms)
%  Calculate scout from the current view (just uses Threshold())
%  This includes the settings for amplitude and cluster size
%  Simply calls Threshold, but ensures the parameters are apporparte
%  2014-02-22 Foldes
%  UPDATES:
%

% Force parameters to be from the figure-view
parms.DataThreshold =       TessInfo.DataThreshold;
parms.SizeThreshold =       TessInfo.SizeThreshold;
parms.DataLimitValue =      TessInfo.DataLimitValue; % Set limit to what is seen
[Scout, ScoutInfo] =        Threshold(TessInfo,sSurf,parms);

% Overwrite overwrite flag (Only one of these at a time, or you will forget the settings)
ScoutInfo.parms.OVERWRITE =       true; % Do you want the scout to be overwriten when you run this? [default = true]
ScoutInfo.parms.Conservative =    parms.Conservative; % pass (probably should be true)

end % VIEW

%% ===MaxPoint===
function [Scout, ScoutInfo] = MaxPoint(TessInfo,sSurf,parms)
%  Scout is just the largest amplitude within the ROI
%  Can be more than one point
%  Will limit search to given MaskScout
%  2014-02-24 Foldes
%  UPDATES:

%% Set display info
Scout.Label =                   parms.NameStr; % Name that will be use
Scout.Color =                   color_name2rgb(parms.Color); % Can be matlab letter or RGB
ScoutInfo.parms.OVERWRITE =     true; % Do you want the scout to be overwriten when you run this? [default = true]
ScoutInfo.parms.Conservative =  true; % DON'T INFLATE, you just want one point

% Limit data to only vert in the MaskScouts
[ScoutInfo.Vertices_ROI,ROI_Mask] = Limit_Vertices_with_Scouts([],sSurf,parms.MaskAtlas,parms.MaskScouts);
Data_from_ROI =TessInfo.Data .* ROI_Mask;

parms.DataThresholdValue =  max(Data_from_ROI);

% Use a value instead of relative
Scout.Vertices = find(Data_from_ROI>=parms.DataThresholdValue); % Defining vertices (This is vertex number, not location)
ScoutInfo.Data = TessInfo.Data(Scout.Vertices); % Save out Data
end % Max
% ===================================================================================





%% ==================================================================================
%  ===HELPER FUNCTIONS===============================================================
%% ==================================================================================

%% Load existing Scout and ScoutInfo
function [Scouts,ScoutInfo,ScoutFiles,selected_iAtlas] = Load_Scout_and_ScoutInfo(sSurf,Atlas)
% Finds the desired 'Atlas' name-str in the sSurf structure
% Also returns the ScoutInfo for a file that is located in the anat/subject folder in BST-db
% One day ScoutInfo needs to be added to the BST-db
%
% 2014-02-28 Foldes
% UPDATES:
%

% ---Load existing Scouts into SmartScout.Scouts---
% Get desired atlas number (for 'SmartScout PROTOCOL')
selected_iAtlas = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas,'Name'),Atlas);
% Pull the existing scouts (you will add to existing)
if ~isempty(selected_iAtlas)
    Scouts = sSurf.Atlas(selected_iAtlas).Scouts;
else % no atlas exists, start it
    Scouts = [];
end

% ---Load existing ScoutInfo into ScoutInfo (BST should save this in DB one day)---
% This is done differently from loading scouts b/c ScoutInfo is not part of BST-db

% Build Smart-atlas file name (anat/subject folder in BST-db)
ProtocolInfo =  bst_get('ProtocolInfo');
ScoutFiles =    fullfile(ProtocolInfo.SUBJECTS,['scout_' Atlas '.mat']);
% Load ScoutInfo from file if there there are even scouts and if there is a file
% Sometimes the atlas can be deleted, so you don't want to try to load ScoutInfo from file
if ~isempty(Scouts) && exist(ScoutFiles,'file')
    loaded_scout_file = load(ScoutFiles);
    ScoutInfo = loaded_scout_file.ScoutInfo;
    clear loaded_scout_file
else
    ScoutInfo = [];
end

end % Load Scout and ScoutInfo

%% ===Limit_Vertices_with_Scouts===
function [Vertices_idx, Vertices_mask] = Limit_Vertices_with_Scouts(OrgVertices,sSurf,MaskAtlas,MaskScouts)
% Returns Vertices of OrgVertices that are in ROIs defined by MaskAtlas and MaskScouts.
% Vertices are really indicies (i.e. [nVertices x 1])
%
% Returns Vertices_idx (vertex numbers, related to OrgVertices) and Vertices_mask (nVertices x 1)
% EXAMPLE:
%   MaskAtlas = 'Desikan-Killiany';
%   MaskScouts = 'postcentral L|precentral L|precentral R';
%
% Might be fun to use:
%   selected_iAtlas = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas,'Name'),Projection.Atlas);
%   selected_iScout = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas(selected_iAtlas).Scouts,'Label'),Projection.Scout);
%
% 2014-02-24 Foldes
% UPDATES:

% Default to all vert
if isempty(OrgVertices)
    OrgVertices = [1:length(sSurf.Vertices)]';
end

% Check for whole number inputs (I accidently tried to add data, not indices)
if mod(OrgVertices,1); error('Vertices are indices; they can not be values'); end

if ~isempty(MaskAtlas) && ~isempty(MaskScouts)
    % which atlas is the user scouts? (this is easier than it looks)
    selected_iAtlas = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas,'Name'),MaskAtlas);
    % load existing Scouts in User scouts atlas (you are going to add to the existing)
    if isempty(selected_iAtlas)
        error(['Selected atlas ' MaskAtlas ' not found'])
    end
    
    % parse MaskScouts name (separated by '|')
    remain = MaskScouts;
    iscout = 0;
    while ~isempty(remain)
        iscout = iscout + 1;
        [MaskScouts_list{iscout} remain] = strtok(remain,'|');
    end
    
    % which atlas is the user scouts? (this is easier than it looks)
    ROI_vertices = [];
    for iscout = 1:length(MaskScouts_list)
        selected_iScout = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas(selected_iAtlas).Scouts,'Label'),MaskScouts_list{iscout});
        ROI_vertices = [ROI_vertices sSurf.Atlas(selected_iAtlas).Scouts(selected_iScout).Vertices];
    end
    % Scout is ONLY vertices in both lists
    Vertices_idx = OrgVertices(find_lists_overlap_idx(OrgVertices,sort(unique(ROI_vertices))));
    
else % no atlas or scouts provided, just return original
    Vertices_idx = OrgVertices;
end

% Just turn the indices into a mask, simple
Vertices_mask = zeros(length(sSurf.Vertices),1);
Vertices_mask(Vertices_idx) = 1;

end % Limit_Vertices_with_Scouts

%% ===Vertex2Coord===
function SelectedPoint = Vertex2Coord(vertex,vertexXYZ,SurfaceFile_name)
% Finds the MRI, MNI, and SCS coordanates given vertex info and SurfaceFile_name
% Generates SelectedPoint.XXX
%
% EXAMPLE:
%   [max_value,max_idx] =       max(ScoutInfo.Data);
%   ScoutInfo.Max = Vertex2Coord(ScoutInfo.Vertices(max_idx,:),ScoutInfo.VerticesXYZ(max_idx,:),TessInfo.SurfaceFile);
%   ScoutInfo.Max.value =       max_value;
%
% 2014-02-22 Foldes
% UPDATES:
%
if ~isempty(vertex)
    SelectedPoint.vertex =      vertex;
    SelectedPoint.scsLoc =      vertexXYZ' * 1000; % subject coord system
    % Get MRI info and convert
    SurfaceFile = bst_get('AnyFile',SurfaceFile_name);
    MRIFile = bst_memory('LoadMri', SurfaceFile.Anatomy.FileName);
    SelectedPoint.mriLoc =  cs_scs2mri(MRIFile, SelectedPoint.scsLoc);
    SelectedPoint.mniLoc =  cs_mri2mni(MRIFile, SelectedPoint.mriLoc); % Needs to be in MNI space
    
else % no points
    SelectedPoint.vertex =  NaN;
    SelectedPoint.scsLoc =  [NaN, NaN, NaN];
    SelectedPoint.mriLoc =  [NaN, NaN, NaN];
    SelectedPoint.mniLoc =  [NaN, NaN, NaN];
end
end % Vertex2Coord

%% ===ROIPrincipalProjection===
function [data2prj_1D,data2prj_pc_in_3D,ROI_pc_in_3D,pcaInfo] = ROIPrincipalProjection(data2prj,ROI_data,plot_flag)
% [data2prj_in_pc_space,data2prj_pc_in_3D,data2prj_pc_in_3D] = ROIPrincipalProjection(data2prj,ROI_data,plot_flag);
% Projects data2prj points on to the low dimensional space defined by ROI_data
% Used to put multiple points into the same space for comparision.
% Picks first PC.
%
% EXAMPLE:
%   Get a single measure of laterality along the precentral gyrus
%       Projection.Atlas =  'Destrieux';
%       Projection.Scouts = 'G_precentral L';
%       data2prj = (ScoutInfo.CenterOfMass.scsLoc/1000)';
%       sSurf = bst_memory('GetSurface', '@default_subject/tess_cortex_pial_low.mat'); % need sSurf some how
%       ROI_data = sSurf.Vertices(Limit_Vertices_with_Scouts([],sSurf,Projection.Atlas,Projection.Scouts));
%       [data2prj_1D] = ROIPrincipalProjection(data2prj,ROI_data);
%
% 2014-02-25 Foldes
% UPDATES:
%

if size(data2prj,2) ~= 3
    data2prj = data2prj';
end

% Do PCA
pcaInfo.mu = mean(ROI_data); % pca will remove the mean
pcaInfo.coeff = princomp(ROI_data); % http://www.mathworks.com/products/statistics/code-examples.html?file=/products/demos/shipping/stats/orthoregdemo.html#10

% project the data into pc space
ROI_in_pc_space =       ( ROI_data - repmat(pcaInfo.mu,size(ROI_data,1),1) ) * pcaInfo.coeff; % [data x pc]
% New data in PC
data2prj_in_pc_space =  ( data2prj - repmat(pcaInfo.mu,size(data2prj,1),1) ) * pcaInfo.coeff; % [data x pc]
data2prj_1D = data2prj_in_pc_space(:,1); % just first PC

% Change PC space back into cartesian
ipc = 1;
ROI_pc_in_3D = repmat(pcaInfo.mu,size(ROI_data,1),1) + ROI_in_pc_space(:,ipc)*pcaInfo.coeff(:,ipc)';
data2prj_pc_in_3D = repmat(pcaInfo.mu,size(data2prj,1),1) + data2prj_in_pc_space(:,ipc)*pcaInfo.coeff(:,ipc)';

%% Plotting
if exist('plot_flag') && (plot_flag==1)
    figure;hold all
    plot3(ROI_data(:,1),ROI_data(:,2),ROI_data(:,3),'.k','LineWidth',2);
    plot3(ROI_pc_in_3D(:,1),ROI_pc_in_3D(:,2),ROI_pc_in_3D(:,3),'-g','LineWidth',5);
    set(gca,'XTick',[],'YTick',[],'ZTick',[])
    box on
    axis equal
    
    plot3(data2prj(:,1),data2prj(:,2),data2prj(:,3),'ow','MarkerSize',15,'MarkerFaceColor','r');
    plot3(data2prj_pc_in_3D(:,1),data2prj_pc_in_3D(:,2),data2prj_pc_in_3D(:,3),'ow','MarkerSize',15,'MarkerFaceColor','c');
    
    % % % connecting lines
    % % X1 = [ROI_data(:,1) ROI_pc_in_3D(:,1)];
    % % X2 = [ROI_data(:,2) ROI_pc_in_3D(:,2)];
    % % X3 = [ROI_data(:,3) ROI_pc_in_3D(:,3)];
    % % plot3(X1',X2',X3','b-')
    % %
    % % % Show next 2 pcs
    % % ipc = 2;
    % % ROI_pc_in_3D2 = repmat(pcaInfo.mu,size(ROI_data,1),1) + ROI_in_pc_space(:,ipc)*pcaInfo.coeff(:,ipc)';
    % % plot3(ROI_pc_in_3D2(:,1),ROI_pc_in_3D2(:,2),ROI_pc_in_3D2(:,3),'-r','LineWidth',2);
    % % ipc = 3;
    % % ROI_pc_in_3D3 = repmat(pcaInfo.mu,size(ROI_data,1),1) + ROI_in_pc_space(:,ipc)*pcaInfo.coeff(:,ipc)';
    % % plot3(ROI_pc_in_3D3(:,1),ROI_pc_in_3D3(:,2),ROI_pc_in_3D3(:,3),'-r','LineWidth',2);
end

end % ROIPrincipalProjection

%% ===ScoutReport===
function [ScoutInfo,ScoutFiles] = ScoutReport(sSurf,Atlas,varargin)
% Populates ScoutInfo with a lot if info
% Intended to be stand-alone so reports can be done on whole atlases
% Needs TessInfo to get information about the data that was used?
%
% Includes:
%       Data, VerticesXYZ, totalArea,
%       Max.value, Max.vertex, Max.mriLoc, etc.
%       Centroid info, CenterOfMass info
%
% ScoutInfo. must have:
%       .surface (SurfaceFile_name), .Vertices (list of indices), .Data
%
% FROM process_SmartScout('Calculate')
%     ScoutInfo.fig_name =        fig_name;
%     ScoutInfo.scout_method =    scout_method;
%     ScoutInfo.subject =         NamingInfo.subject; % where the Data comes from
%     ScoutInfo.condition =       NamingInfo.condition; % where the Data comes from
%     ScoutInfo.surface =         NamingInfo.surface;
%     ScoutInfo.parms_in =        parms; % parms that we desired, not necessarly the parms that were used
%     ScoutInfo.date_generated =  datestr(now,'yyyy-mm-dd HH:MM');

% SmartScouts.Name = ['SmartScouts ' ProtocolInfo.Comment]; % Name of Atlas; Could use 'User scouts';

% 2014-02-27 Foldes
% UPDATES:
%

% ScoutInfo.subject =         NamingInfo.subject;
% ScoutInfo.condition =       NamingInfo.condition;
% ScoutInfo.surface =         NamingInfo.surface;
% ScoutInfo =                 copy_fields(Scout,ScoutInfo);
% ScoutInfo.Data =            TessInfo.Data(ScoutInfo.Vertices);


% % Get info from figure
% TessInfo = getappdata(hFig,'Surface');
% % Check surface match NOT SURE HOW TO DO THIS YET, PROBABLY SMARTER
% if ~strcmpi(TessInfo.SurfaceFile,ScoutInfo.surface)
%     error('Figure in surface does not match that of scout')
% end
% Get surface
% sSurf = bst_memory('GetSurface', ScoutInfo.surface);
% sSurf = bst_memory('GetSurface', TessInfo.SurfaceFile);

parms.FLAG_NewSave =    false; % overwrite old scouts, you now have new data
parms.NewData =         []; % Use this new data for the calculation (will not overwrite atlas)

parms = varargin_extraction(parms,varargin);

%% Load all Scouts and ScoutInfo from Atlas

[SmartScout.Scouts,SmartScout.ScoutInfo,ScoutFiles,selected_iAtlas] = Load_Scout_and_ScoutInfo(sSurf,Atlas);

%% Go through each scout
% COULD ALSO REMOVE SCOUTINFO THAT DOESNT HAVE A SCOUT

for iscout = 1:length(SmartScout.Scouts)
    % find idx of the the matching ScoutInfo
    iscoutinfo = ismember(SmartScout.Scouts(iscout).Label,struct_field2cell(SmartScout.ScoutInfo,'Label'));
    if isempty(iscoutinfo) % info doesn't exist, add it
        iscoutinfo = length(SmartScout.ScoutInfo)+1;
    end
    current_ScoutInfo = SmartScout.ScoutInfo{iscoutinfo};
    
    % Make sure Scout is copied to ScoutInfo
    current_ScoutInfo = copy_fields(SmartScout.Scout(iscout),current_ScoutInfo);
    
    current_ScoutInfo.VerticesXYZ = sSurf.Vertices(current_ScoutInfo.Vertices,:); % actual xyz coordanates
    current_ScoutInfo.totalArea =   sum(sSurf.VertArea(current_ScoutInfo.Vertices)) * 100 * 100; % cm^2
    
    %% Data-related info
    
    % You have defined NewData at the input, set it as 'data'
    if ~isempty(parms.NewData)
        % force the data to be the function input's NewData
        current_ScoutInfo.Data = parms.NewData;
        FLAG_NewSave = true; % dont overwrite old scouts, you now have new data
    end
    
    % only do these things if there is .Data
    if isfield(current_ScoutInfo,'Data') && ~isempty(current_ScoutInfo.Data)
        
        current_ScoutInfo.DataMean =    mean(current_ScoutInfo.Data);
        current_ScoutInfo.DataMedian =  median(current_ScoutInfo.Data);
        
        % Get the vertices for the MaskScout that may have been used
        % (used for PrincipalProjection below)
        if ~isempty(current_ScoutInfo.Vertices_ROI)
            ROI_VerticesXYZ = sSurf.Vertices(current_ScoutInfo.Vertices_ROI,:);
        else
            ROI_VerticesXYZ = [];
        end
        
        %% Compute single point info (e.g. max)
        % ---Max Info---
        [~,max_idx] =           max(current_ScoutInfo.Data);
        current_ScoutInfo.Max = Vertex2Coord(current_ScoutInfo.Vertices(max_idx,:),...
            current_ScoutInfo.VerticesXYZ(max_idx,:),current_ScoutInfo.surface);
        current_ScoutInfo.Max.value =   current_ScoutInfo.Data(current_ScoutInfo.Vertices==current_ScoutInfo.Max.vertex); % must be at end or will be overwritten
        % project the location onto the ROI space
        current_ScoutInfo.Max.prinprj = ROIPrincipalProjection((current_ScoutInfo.Max.scsLoc/1000),ROI_VerticesXYZ);
        
        if length(current_ScoutInfo.Vertices)>1 % Doesn't work for single vertex
            % ---Centroid Info---
            centroid_value =    mean(current_ScoutInfo.VerticesXYZ);
            centroid_idx =      knnsearch(current_ScoutInfo.VerticesXYZ,centroid_value); % NOTE: uses stats tool box (easy to replace)
            current_ScoutInfo.Centroid =  Vertex2Coord(current_ScoutInfo.Vertices(centroid_idx,:),...
                current_ScoutInfo.VerticesXYZ(centroid_idx,:),current_ScoutInfo.surface);
            current_ScoutInfo.Centroid.value = current_ScoutInfo.Data(current_ScoutInfo.Vertices==current_ScoutInfo.Centroid.vertex); % must be at end or will be overwritten
            % project the location onto the ROI space
            current_ScoutInfo.Centroid.prinprj = ROIPrincipalProjection((current_ScoutInfo.Centroid.scsLoc/1000),ROI_VerticesXYZ);
            
            % ---CenterOfMass Info---
            % data-weighted centroid
            data_norm = ( current_ScoutInfo.Data - min(current_ScoutInfo.Data) )./abs(max(current_ScoutInfo.Data) - min(current_ScoutInfo.Data));
            CenterOfMass_value =    mean(current_ScoutInfo.VerticesXYZ.*[data_norm,data_norm,data_norm]);
            CenterOfMass_idx =      knnsearch(current_ScoutInfo.VerticesXYZ,CenterOfMass_value); % NOTE: uses stats tool box (easy to replace)
            current_ScoutInfo.CenterOfMass = Vertex2Coord(current_ScoutInfo.Vertices(CenterOfMass_idx,:),...
                current_ScoutInfo.VerticesXYZ(CenterOfMass_idx,:),current_ScoutInfo.surface);
            current_ScoutInfo.CenterOfMass.value = current_ScoutInfo.Data(current_ScoutInfo.Vertices==current_ScoutInfo.CenterOfMass.vertex); % must be at end or will be overwritten
            % project the location onto the ROI space
            current_ScoutInfo.CenterOfMass.prinprj = ROIPrincipalProjection((current_ScoutInfo.CenterOfMass.scsLoc/1000),ROI_VerticesXYZ);
        end
        
    end % Is there data?
    
    %%  Write ScoutInfo back to it's structure
    SmartScout.ScoutInfo{iscoutinfo} = current_ScoutInfo;
    
end % Scout Loop

% a bit of basic info needed
SmartScout.Name = Atlas;
SmartScout.TessNbVertices = TessInfo.nVertices;

if parms.FLAG_NewSave % save new
    % get a new name
    n = 0;
    while exist(ScoutFiles,'file') ~= 1
        n = n + 1;
        if n==1
            ScoutFiles = [ScoutFiles '_' num2str(n)];
        else
            ScoutFiles = [ScoutFiles(1:end-2) num2str(n)];
        end
    end
end

save(ScoutFiles,'-struct','SmartScout','Name','TessNbVertices','Scouts','ScoutInfo'); % Also saves ScoutInfo
disp(['Scout file saved as ' ScoutFiles])

end % ScoutReport