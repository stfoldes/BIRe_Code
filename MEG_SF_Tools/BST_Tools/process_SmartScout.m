function varargout = process_SmartScout( varargin )
% PROCESS_SMARTSCOUT: Compute and apply scouts based on the surface-data.
%
% DESCRIPTION:
%       A set of tools for creating and using Scouts with more complexity
%       1) Create Scouts using data
%       2) Masking Scouts with ROIs
%       3) Compute information about scouts, e.g. CenterOfGravity, peak, etc.
%
%       Uses the data shown on an open surface figure to compute a scout
%       A variaty of methods are avalible, including making a scout just from what you see
%       Can also limit this scout creation w/ other scout-masks (e.g. ROIs)
%       This ScoutInfo is saved in the /anat/ folder and uses a ScoutID to link to Scouts
%       Generates an Atlas called "SmartScout_PROTOCOLNAME".
%
% @=============================================================================
% This software is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
%
% See BST Copyright info somewhere else, not here.
% FOR RESEARCH PURPOSES ONLY.
% For more information type "brainstorm license" at command prompt.
% =============================================================================@
%
% Authors: Stephen Foldes, 2014-03-05
%
% BUGS AND IMPROVEMENTS:
%   ScoutInfo should be in bst-db and integrated w/ Scout/Atlas
%   Need a better unique identifier to relate ScoutInfo w/ Scouts (integrate)
%   kknnsearch - replace with norm find thing
%   More scout-methods (always)
%     
%
% BUG OBSERVATIONS TO CONCIDER FROM BST:
%   Fatal error if no Vertices are defined (e.g. SetScoutsSeed) Should still save w/ empty
%   Some BST-naming has hard coded slashes (not architecture specific)
%   Scout seeds are necessary to be set before using 'SetScouts' (seeds don't seem critial
%   theoretically)
%   .Vertices must be [1xnVertices] or will recieve an error (since its 1D always, should)

macro_methodcall;
end

%% ===== GET DESCRIPTION =====
function sProcess = GetDescription()
% Description the process
sProcess.Comment     = 'SmartScout';
sProcess.FileTag     = '| SmartScout';
sProcess.Category    = 'Custom';
sProcess.SubGroup    = 'Scout';
sProcess.Index       = 1000; % ? 
% Definition of the input accepted by this process
sProcess.InputTypes  = {'results'};
sProcess.OutputTypes = {'results'};
sProcess.nInputs     = 1;
sProcess.nMinFiles   = 0;
% Default values for some options
sProcess.isSourceAbsolute = 0;
sProcess.processDim       = [];

% Definition of the options
% === Scout Method ===
sProcess.options.scoutmethod.Comment = 'Calculation Method [View (or Threshold or MaxPoint)]: ';
sProcess.options.scoutmethod.Type    = 'text'; % 'radio' would be better +++IMPROVE+++
sProcess.options.scoutmethod.Value   = 'View';

% === Mask ===
sProcess.options.MaskAtlas.Comment = '[OPTIONAL] Scout MaskAtlas (e.g. Desikan-Killiany): ';
sProcess.options.MaskAtlas.Type    = 'text';
sProcess.options.MaskAtlas.Value   = 'Desikan-Killiany';

sProcess.options.MaskScouts.Comment = '[OPTIONAL] Scout MaskScouts (e.g. precentral L|postcentral L): ';
sProcess.options.MaskScouts.Type    = 'text';
sProcess.options.MaskScouts.Value   = 'precentral L|postcentral L';

% === Display ===
sProcess.options.NameDesign.Comment = '[OPTIONAL] Scout Name (can be design or empty): ';
sProcess.options.NameDesign.Type    = 'text';
sProcess.options.NameDesign.Value   = '[subject]_[condition]_[scout_method]';

sProcess.options.Color.Comment = '[OPTIONAL] Color for scout (color-letter or RGB): ';
sProcess.options.Color.Type    = 'text';
sProcess.options.Color.Value   = 'b';

% === Threshold ===
sProcess.options.DataThresholdValue.Comment = '[OPTIONAL] Threshold number (must use Threshold method): ';
sProcess.options.DataThresholdValue.Type    = 'text';
sProcess.options.DataThresholdValue.Value   = '';

end

%% ===== FORMAT COMMENT =====
function Comment = FormatComment(sProcess)
Comment = 'Smart research requires SmartScouts.';
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
% disp_struct(sInput);
% disp_struct(sProcess);

if isempty(sProcess.options.scoutmethod.Value)
    bst_report('Error', sProcess, [], 'Invalid SmartScout Method.');
    sInput = [];
    return;
end

% Open the figure automatically? +++IMPROVE+++

DataThresholdValue = str2num(sProcess.options.DataThresholdValue.Value); % Lazy +++IMPROVE+++

% Compute
[ScoutInfo,AtlasFile] = Compute(sInput, sProcess.options.scoutmethod.Value,...
    'MaskAtlas',sProcess.options.MaskAtlas.Value,'MaskScouts',sProcess.options.MaskScouts.Value,...
    'NameDesign',sProcess.options.NameDesign.Value,'Color',sProcess.options.Color.Value,...
    'DataThresholdValue',DataThresholdValue);

sInput.A = ScoutInfo;
% Move data to the base workspace
assignin('base', 'ScoutInfo', ScoutInfo);
assignin('base', 'AtlasFile', AtlasFile);

end % Run

%% ==================================================================================
%% ===COMPUTE (MAIN)=================================================================
%% ==================================================================================
function [ScoutInfo,AtlasFile] = Compute(sInput, scout_method, varargin)
% [ScoutInfo,AtlasFile] = process_SmartScout('Compute',sInput/hFig, scout_method, varargin)
%
% Creates a scout using a variaty of data-based methods using open source figure(s)
% Generates an Atlas called "SmartScout_PROTOCOLNAME". Scouts are added to the existing
% atlas (if it exists).
% Will apply an ROI-mask before calculating the scout (see info below).
%
% INPUTS:
%   sInput (or hFig): Either the sInput from "Matlab Run" OR a list of figure handles that the
%       scout calculation is to be performed on OR [] (empty) to get all 3DViz figures open
%       Of sInput, only .SubjectName and .Condition are used to find the figure by name
%       get(gcf,'Name') => 'MEG/3D: [sInput.SubjectName]/[sInput.Condition]';
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
%   AtlasFile:  File which Scouts and ScoutInfo is saved
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
%     % ---DATA-RELATED---
%     DataThreshold =       Threshold as % (same as 'Amplitude' in BST)
%     DataThresholdValue =  Threshold as value
%     SizeThreshold =       Number of vertices for clustering limit (same as 'Min size')
%     TimeS =               Can change the displayed time to TimeS (in seconds)
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
%   import_label will kick out an error if there are no vertices
%
% 2014-02-25 Foldes
% UPDATES:
% 2014-03-03 Foldes: Fully integrated into BST as process

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

% ---DATA---
parms.DataThreshold =       []; % Threshold as % (same as 'Amplitude' in BST)
parms.SizeThreshold =       []; % Number of sources
parms.DataLimitValue =      []; %
parms.DataThresholdValue =  []; % Threshold as value
parms.TimeS =               []; % Change data to TimeS (seconds)

%---OVERLAP---
parms.MaskAtlas =           []; % atlas name for scouts to mask e.g. 'Desikan-Killiany'; ONLY works for one atlas now
parms.MaskScouts =          []; % scout list separated by '|' e.g. 'postcentral L|precentral L|precentral R';

% ---Parse varargin---
parms = varargin_extraction(parms,varargin);

%% Get Surface Figure (this could be fancier one day)

if isstruct(sInput) % input is a sInput, get figure-name from sInput structure
    % The target figure's name should start w/ this string
    fig_name = ['MEG/3D: '  sInput.SubjectName filesep sInput.Condition];
    
    % Get all 3DViz figure handles
    % Find which of the possible figures has a name like the desired
    h3DViz = findobj('Type','figure','Tag','3DViz');
    name_match_idx = [];
    for ifig = 1:length(h3DViz)
        if findstr(get(h3DViz(ifig),'Name'),fig_name) == 1
            name_match_idx = [name_match_idx ifig];
        end
    end
    if isempty(name_match_idx)
        error('Surface-figure you want scouts on must be open')
    end
    hFig = h3DViz(name_match_idx(1)); % There better be only one
    
elseif ishandle(sInput) == 1 % handles are valid inputs, esp. for mass running on all open figures w/o panel
    hFig = sInput;
elseif isempty(sInput) % No input, get all valid figures
    hFig = findobj('Type','figure','Tag','3DViz');
end

if isempty(hFig)
    error('Surface-figure you want scouts on must be open')
end
if length(hFig)>1 % more than one figure found, loop through all (RECURSIVE)
    for ifig = 1:length(hFig)
        ScoutInfo(ifig) = process_SmartScout('Compute',hFig(ifig),scout_method,varargin{:});
    end
    warning('***More than 1 surface-figure possible: Doing on all***')
    return
end
fig_name = get(hFig,'Name');
disp(['Building SmartScout on: ' fig_name])

%% Get info from figure

% Set current time
if ~isempty(parms.TimeS)
    panel_time('SetCurrentTime',parms.TimeS);
end

TessInfo = getappdata(hFig,'Surface');
% Get surface
sSurf = bst_memory('GetSurface', TessInfo.SurfaceFile);

%% Get info for the new scout, including naming and parameters

% parse DataSource name for info (this is not great, maybe look at GlobalData +++IMPROVE+++)
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

eval(['[sScout, ScoutInfo] = ' scout_method '(TessInfo,sSurf,parms);']);

if isempty(sScout.Vertices) % SetScoutsSeed crashes if no Vertices +++BST-BUG+++
    warning(['No vertices found for ' sScout.Label '. This will cause an error in import_label'])
    ScoutInfo = NaN; AtlasFile = NaN;
    return
end

% ---Inflate the scout by 1 vertex to be inclusive---
% (SEE: panel_scout('EditScoutsSize','Grow'))
if ScoutInfo.parms.Conservative == false % (defined in scout_method)
    sScout.Vertices = sort([sScout.Vertices; tess_scout_swell(sScout.Vertices, sSurf.VertConn)']);
end

% to be safe, make sure .Vertices are [1xnVertices] otherwise BST will kick out error in
% panel_scout>UpdateScoutProperties (line 759) +++BST-BUG+++
if size(sScout.Vertices,1)>1
    sScout.Vertices = sScout.Vertices';
end

sScout.Function = parms.TimeSeries_Function; % Only maters if you want timeseries (main options: 'Mean','Power','PCA')
% Seeds must be pre-calculated b/c required for 'SetScouts' (though this shouldn't be +++BST-BUG+++)
sScout = panel_scout('SetScoutsSeed', sScout, sSurf.Vertices);

%% Populate ScoutInfo
% ScoutInfo should be added to bst-db AND should have template (or class!) +++IMPROVE+++

% Some info is in Global, like current time
global GlobalData

% Add basic info to ScoutInfo
ScoutInfo.ScoutID =         MakeScoutID(sScout); % 'unique' identifier to link scouts w/ scoutinfo
ScoutInfo.Label =           sScout.Label;
ScoutInfo.fig_name =        fig_name;
ScoutInfo.scout_method =    scout_method;
ScoutInfo.subject =         NamingInfo.subject; % where the Data comes from
ScoutInfo.condition =       NamingInfo.condition; % where the Data comes from
ScoutInfo.surface =         NamingInfo.surface;
ScoutInfo.Data =            TessInfo.Data(sScout.Vertices); % Save out Data
ScoutInfo.TimeS =           GlobalData.UserTimeWindow.CurrentTime;
ScoutInfo.parms_in =        parms; % parms that we desired, not necessarly the parms that were used
ScoutInfo.date_generated =  datestr(now,'yyyy-mm-dd HH:MM');

% More info is added later with AtlasReport


%% Push new scout to the atlas
% Originally intended to be able to make more than one scout at a time, removed this functionality (2014-03-03)

% Empty atlas structure
sAtlas = db_template('Atlas');

% Go desired atlas ('SmartScout_PROTOCOL')
ProtocolInfo = bst_get('ProtocolInfo');
sAtlas.Name = ['SmartScout_' ProtocolInfo.Comment]; % Name of Atlas; Could use 'User scouts';
iAtlas = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas,'Name'),sAtlas.Name);
if ~isempty(iAtlas) % atlas already exists, go to it
    panel_scout('SetCurrentAtlas',iAtlas);
else
    iAtlas = panel_scout('SetAtlas',TessInfo.SurfaceFile, 'Add',  sAtlas);
end

% ---Set Scout to Atlas---
%  Preventing the overwriting
if parms.BYPASSOVERWRITE
    ScoutInfo.parms.OVERWRITE = false;
end

% New or Overwrite a scout (you don't want them to build up)
new_scout_flag = true; % assume new
if ScoutInfo.parms.OVERWRITE
    if length(sSurf.Atlas) >= iAtlas % atlas exist, look for a scout match
        iScout = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas(iAtlas).Scouts,'Label'),sScout.Label);
        if ~isempty(iScout) % if there is a match, overwrite it
            iScout = panel_scout('SetScouts',[], iScout, sScout);
            new_scout_flag = false;
        end
    end
end
if new_scout_flag
    iScout = panel_scout('SetScouts',[], 'Add', sScout);
end

% Display new scout (MUST PLOT OR WILL GET ERROR WITH .Handels not being set +++BST-BUG+++)
panel_scout('PlotScouts',iScout);
% Update "Scouts Manager" panel
panel_scout('UpdateScoutsList');
% Select last scout in list (new scout)
panel_scout('SetSelectedScouts',iScout);


%% Custom viewing 
% could be parms one day +++IMPROVE+++

% % Turn border on (1) and off (0) (you will want 1 for non-face points)
% panel_scout('SetScoutContourVisible',1);
% Turn text on (1) and off (0)
panel_scout('SetScoutTextVisible',0);
% % Adjust the transparency (0-1) [DEFAULT: 0.7] (ONLY WORKS FOR TRANSPARENT VIEW)
transp = 0.5;
panel_scout('SetScoutTransparency',transp);
% save
panel_scout('SaveModifications');

% % Change source-patch to discrete
% TessInfo = getappdata(gcf,'Surface');
% set(TessInfo.hPatch,'FaceColor','flat')


%% Save and compute AtlasReport

FLAG_SAVENEW = false;% Save over old atlas file
AtlasFile = Save_Atlas_and_ScoutInfo(sAtlas.Name,ScoutInfo,FLAG_SAVENEW);

% Compute advanced information on the Atlas (w/ the new scout)
[AtlasInfo,AtlasFile] = AtlasReport(sAtlas.Name);

ScoutInfo = AtlasInfo(iScout);
% disp_struct(ScoutInfo);

% Hide progress bar (sometimes things get stuck)
bst_progress('stop');

end % Compute
% ===================================================================================


%% ==================================================================================
%% ===CALCULATIONS FOR SCOUT METHODS=================================================
%% ==================================================================================
% How to calculate scouts from the data, given TessInfo, sSurf, and parms
%
% All methods must make the following Scout structure and start w/ sScout = db_template('scout');
%       Scouts:
%           Vertices: [1x438 double]
%           Color: [1 1 0]    % I will translate single-letter colors
%           Label: '3'        % Name of scout
%
%       ScoutInfo:
%           All information is optional except: .OVERWRITE, .Conservative
%
% Inputs are: (TessInfo,sSurf,parms)
%
% 'Threshold' is a complicated example, but very thourough

%% ===Threshold===
function [sScout, ScoutInfo] = Threshold(TessInfo,sSurf,parms)
%  Calculate scout using thresholds
%  This includes the settings for amplitude and cluster size
%  Will limit search to given MaskScout
%  2014-02-22 Foldes
%  UPDATES:
%

sScout =    db_template('scout');
ScoutInfo = template_ScoutInfo;

%% Set display info
sScout.Label =                  parms.NameStr; % Name that will be use
sScout.Color =                  color_name2rgb(parms.Color); % Can be matlab letter or RGB
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
sScout.Vertices = find(DataSurf>0); % Defining vertices (This is vertex number, not location)

end % THRESHOLD

%% ===View===
function [sScout, ScoutInfo] = View(TessInfo,sSurf,parms)
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
[sScout, ScoutInfo] =      	Threshold(TessInfo,sSurf,parms);

% Overwrite overwrite flag (Only one of these at a time, or you will forget the settings)
ScoutInfo.parms.OVERWRITE =       true; % Do you want the scout to be overwriten when you run this? [default = true]
ScoutInfo.parms.Conservative =    parms.Conservative; % pass (probably should be true)

end % VIEW     

%% ===MaxPoint===
function [sScout, ScoutInfo] = MaxPoint(TessInfo,sSurf,parms)
%  Scout is just the largest amplitude within the ROI
%  Can be more than one point
%  Will limit search to given MaskScout
%  2014-02-24 Foldes
%  UPDATES:

sScout =    db_template('scout');
ScoutInfo = template_ScoutInfo;

%% Set display info
sScout.Label =               	parms.NameStr; % Name that will be use
sScout.Color =              	color_name2rgb(parms.Color); % Can be matlab letter or RGB
ScoutInfo.parms.OVERWRITE =     true; % Do you want the scout to be overwriten when you run this? [default = true]
ScoutInfo.parms.Conservative =  parms.Conservative; % pass (probably should be true)

% Limit data to only vert in the MaskScouts
[ScoutInfo.Vertices_ROI,ROI_Mask] = Limit_Vertices_with_Scouts([],sSurf,parms.MaskAtlas,parms.MaskScouts);
Data_from_ROI =TessInfo.Data .* ROI_Mask;

parms.DataThresholdValue =  max(Data_from_ROI);

% Use a value instead of relative
sScout.Vertices = find(Data_from_ROI>=parms.DataThresholdValue); % Defining vertices (This is vertex number, not location)
end % Max
% ===================================================================================



%% ==================================================================================
%% ===HELPER FUNCTIONS===============================================================
%% ==================================================================================

%% ===Load existing Scout and ScoutInfo===
function [ScoutInfo,Scouts,AtlasFile,iAtlas] = Load_Scout_and_ScoutInfo(AtlasName,sSurf)
% Gets scouts from the AtlasName, also gets ScoutInfo from standard-named saved file
% sSurf and AtlasName are optional. If left out, will use GlobalData to find the currenly used Surface
% One day ScoutInfo needs to be added to the BST-db
%
% EXAMPLE:
%   Load ScoutInfo for the atlas, assuming you are selected on the atlas
%       ScoutInfo = process_SmartScout('Load_Scout_and_ScoutInfo');
%
% 2014-02-28 Foldes
% UPDATES:
% 2014-03-05 Foldes: sSurf optional

global GlobalData
% If no AtlasName given, use the current one via GlobalData
if ~exist('AtlasName') || isempty(AtlasName)
    AtlasName = GlobalData.Surface.Atlas(GlobalData.Surface.iAtlas).Name ;
end
% If no sSurf given, use the current one via GlobalData
if ~exist('sSurf') || isempty(sSurf)
    sSurf = GlobalData.Surface;
end

% ---Load existing Scouts---
% Get desired atlas number (for 'SmartScout_PROTOCOL')
iAtlas = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas,'Name'),AtlasName);
% Pull the existing scouts (you will add to existing)
if ~isempty(iAtlas)
    Scouts = sSurf.Atlas(iAtlas).Scouts;
else % no atlas exists, start it
    Scouts = [];
end

% ---Load existing ScoutInfo into ScoutInfo (BST should save this in DB one day)---
% This is done differently from loading scouts b/c ScoutInfo is not part of BST-db

% Build Smart-atlas file name (anat/subject folder in BST-db)
ProtocolInfo =  bst_get('ProtocolInfo');
AtlasFile =     fullfile(ProtocolInfo.SUBJECTS,['scout_' AtlasName '.mat']);
% Load ScoutInfo from file if there there are even scouts and if there is a file
% Sometimes the atlas can be deleted, so you don't want to try to load ScoutInfo from file
if ~isempty(Scouts) && exist(AtlasFile,'file')==2
    loaded_scout_file = load(AtlasFile);
    ScoutInfo = loaded_scout_file.ScoutInfo;
    clear loaded_scout_file
else
    ScoutInfo = [];
end

end % Load Scout and ScoutInfo

%% ===Save Scouts and ScoutInfo===
function [AtlasFile] = Save_Atlas_and_ScoutInfo(AtlasName,ScoutInfo_in,FLAG_SAVENEW)
% Save AtlasFile to standard place (ProtocolInfo.SUBJECTS)
% Saves ALL scouts in the atlas
% Will get ScoutInfo for each scouts either from input or from file
% Any ScoutInfo from file that does not have a matching scout will be removed!! (maybe deactivate?) 
% This code can be a lot better, but it should be handeled by BST-db in the future +++IMPROVE+++
%
% sScout .Name .TessNbVertices .Scouts
% ScoutInfo_in .ScoutID needed (see MakeScoutID())
% AtlasFile is the file name, but if FLAG_SAVENEW == true, a new file name will be picked.
%
% 2014-02-28 Foldes
% UPDATES:
% 2014-03-05 Foldes: New way to put scouts to bst

global GlobalData % Global is updated automatically!

% Get current atlas for saving
iAtlas = find_lists_overlap_idx(struct_field2cell(GlobalData.Surface.Atlas,'Name'),AtlasName);
sAtlas = GlobalData.Surface.Atlas(iAtlas);
sAtlas.TessNbVertices = length(GlobalData.Surface.Vertices);

% ---Build Atlas file name (anat/subject folder in BST-db)---
ProtocolInfo =  bst_get('ProtocolInfo');
AtlasFile =     fullfile(ProtocolInfo.SUBJECTS,['scout_' AtlasName '.mat']); % +++IMPROVE+++
% Get a new file name if you want to save a new file
if FLAG_SAVENEW == true % save new
    % get a new name
    n = 0;
    while exist(AtlasFile,'file') == 2
        n = n + 1;
        if n==1
            AtlasFile = [AtlasFile '_' num2str(n)];
        else
            AtlasFile = [AtlasFile(1:end-2) num2str(n)];
        end
    end
end

% ---Load ScoutInfo from File (if it fits the current Scouts) ---
% Load existing ScoutInfo (that are valid for this atlas)
if exist(AtlasFile,'file') == 2 % file exists?
    AtlasFile_existing = load(AtlasFile);
    
    % File-ScoutInfo that match current Scouts (using ScoutID)
    scouts_from_file_idx = find_lists_overlap_idx(struct_field2cell(AtlasFile_existing.ScoutInfo,'ScoutID'),...
        MakeScoutID(sAtlas.Scouts));
    
    if ~isempty(scouts_from_file_idx) % some file-info fit the current scouts, add those to list
        % Add valid ScoutInfo to the list of those to save
        for iscout = 1:length(scouts_from_file_idx)
            ScoutInfo(iscout) = AtlasFile_existing.ScoutInfo(scouts_from_file_idx(iscout));
        end
    else % no file-info fits current scouts, just start an empty ScoutInfo-list
        ScoutInfo = template_ScoutInfo;
    end
else % no file-info fits current scouts, just start an empty ScoutInfo-list
    ScoutInfo = template_ScoutInfo;
    
end

% --- Combine ScoutInfo_in with existing valid-ScoutInfo (from file)  ---
% go thru all new scoutinfo and see if it should overwrite an old one or just be added
for iinfo = 1:length(ScoutInfo_in)
    % Which of the info-from-file need to be overwritten w/ the current new-scoutinfo
    info2overwrite_idx = find_lists_overlap_idx(struct_field2cell(ScoutInfo,'ScoutID'),...
        ScoutInfo_in(iinfo).ScoutID);
    
    if ~isempty(info2overwrite_idx) % yes, overwrite something
        if length(info2overwrite_idx) > 1
            error('crap, you have more than one match...ScoutID is not unique enough OR you have doubles some how')
        end
        % Overwrite previous
        ScoutInfo(info2overwrite_idx) = ScoutInfo_in(iinfo);
    else % no overwrite, just add to list
        if isempty(ScoutInfo(1).ScoutID)
            % ScoutInfo was initalized, overwrite the empty first entry
            ScoutInfo(1) = ScoutInfo_in(iinfo);
        else
            ScoutInfo(end+1) = ScoutInfo_in(iinfo);
        end
    end
end % Add in new info




% --- Save ---
sAtlas.ScoutInfo = ScoutInfo;
save(AtlasFile,'-struct','sAtlas','Name','TessNbVertices','Scouts','ScoutInfo'); % Also saves ScoutInfo
% disp(['Atlas file saved as ' AtlasFile])

end % Save_Atlas_and_ScoutInfo

%% ===MakeScoutID===
function ScoutID = MakeScoutID(Scouts)
% Generate a 'unique' identifier from a scout
% ScoutID = 'Label_nVertices_min(Vert)_median(Vert)_max(Vert)'
% IT IS POSSIBLE THAT THIS IS NOT UNIQUE
% BST should put a unique identifier in the scout +++IMPROVE+++

for iscout = 1:length(Scouts)
    current_ScoutID = [];
    current_ScoutID = [current_ScoutID Scouts(iscout).Label];
    current_ScoutID = [current_ScoutID '_'];
    current_ScoutID = [current_ScoutID num2str(length(Scouts(iscout).Vertices))];
    current_ScoutID = [current_ScoutID '_'];
    current_ScoutID = [current_ScoutID num2str(min(Scouts(iscout).Vertices))];
    current_ScoutID = [current_ScoutID '_'];
    current_ScoutID = [current_ScoutID num2str(median(Scouts(iscout).Vertices))];
    current_ScoutID = [current_ScoutID '_'];
    current_ScoutID = [current_ScoutID num2str(max(Scouts(iscout).Vertices))];
    ScoutID{iscout} = current_ScoutID;
end % loop

% you don't want a cell for single inputs...probably should use cellfun or something
if length(ScoutID) == 1
    ScoutID = cell2mat(ScoutID);
end

end % MakeScoutID

%% ===Limit_Vertices_with_Scouts===
function [Vertices_idx, Vertices_mask] = Limit_Vertices_with_Scouts(OrgVertices,sSurf,MaskAtlas,MaskScouts)
% Returns Vertices of OrgVertices that are in ROIs defined by MaskAtlas and MaskScouts.
% Vertices are really indicies (i.e. [1 x nVertices])
%
% Returns Vertices_idx (vertex numbers, related to OrgVertices) and Vertices_mask (nVertices x 1)
% EXAMPLE:
%   MaskAtlas = 'Desikan-Killiany';
%   MaskScouts = 'postcentral L'|precentral L|precentral R';
%
% Might be fun to use:
%   iAtlas = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas,'Name'),Projection.Atlas);
%   iScout = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas(iAtlas).Scouts,'Label'),Projection.Scout);
%
% BUGS:
%   Some BST function require vertices to be [1 x nVertices], might need to flip after this (+++BST-BUG+++)
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
    iAtlas = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas,'Name'),MaskAtlas);
    % load existing Scouts in User scouts atlas (you are going to add to the existing)
    if isempty(iAtlas)
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
        iScout = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas(iAtlas).Scouts,'Label'),MaskScouts_list{iscout});
        ROI_vertices = [ROI_vertices sSurf.Atlas(iAtlas).Scouts(iScout).Vertices];
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

% ---Plotting---
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

%% ===ScoutInfo Template===
function template = template_ScoutInfo
% Define ScoutInfo so you don't have to suffer w/ cells
% This code needs more class...as in object-class
% This should be integrated w/ db_template (really it should be with Scout) +++IMPROVE+++
%
% 2014-03-05 Foldes

template = struct(...
    'ScoutID',      [], ...
    'Vertices',     [], ... % Index of vertices
    'Seed',         [], ... % Initial vertex of the scout area
    'Color',        [], ...
    'Label',        '', ...
    'Function',     'Mean', ... % Scout function: PCA, FastPCA, Mean, Mean_norm, Max, Power, All
    'Region',       'UU', ...      % 1st letter: Left/Right/Unknown,  2nd letter: Frontal/Parietal/Temporal/Occipital/Central/Unkown
    'Handles',      [], ...
    'parms',        [], ...
    'Vertices_ROI', [], ...
    'fig_name',     [], ...
    'scout_method', [], ...
    'subject',      [], ...
    'condition',    [], ...
    'surface',      [], ...
    'Data',         [], ...
    'TimeS',        [], ...
    'parms_in',     [], ...
    'date_generated',   [], ...
    'VerticesXYZ',      [], ...
    'totalArea',        [], ...
    'DataMean',         [], ...
    'DataMedian',       [], ...
    'Max',              [], ...
    'Centroid',         [], ...
    'CenterOfMass',     []);

end

%% ==================================================================================
%% ===BONUS FEATURES=================================================================
%% ==================================================================================
% Functions that are designed to be easily used outside of process_SmartScout
% i.e. they are can be used on any scouts and atlases, not just SmartScouts

%% ===AtlasReport===
function [AtlasInfo,AtlasFile] = AtlasReport(AtlasName,SurfaceFile,varargin)
% Populates AtlasInfo with a lot if info about each scout within an Atlas
% Information include totalArea, VerticesXYZ, Max MRI coordinate, etc.
% Reports are done on whole Atlases
%
% AtlasName and SurfaceFile are optional. If left out, will use GlobalData to find the currenly activated
%
% Will compute information about the data with scouts, e.g. MRI coordiantes for the max point in the scout
% The data used for this must be either in a saved ScoutInfo.Data (see Load_Scout_and_ScoutInfo)
% OR 
% The data can be defined in varargin as ...'NewData',Data);
% Using 'NewData' will perform calculations on all scouts in the atlas w/ the data and save a new scout
% Useful for reporting activity in an ROI that was previously defined (e.g. via a localizer)
% 'NewTimeS' should be included also, otherwise no time will be recorded
%
% EXAMPLE:
%   Report on currentlly open Atlas
%       AtlasInfo = process_SmartScout('AtlasReport');
%
% BUGS:
%   If vertices are change in GUI they will have a different ScoutID and not be overwritten (need
%   bst-db link!)
%
% 2014-02-27 Foldes
% UPDATES:
% 2014-03-03 Foldes: Added TimeS

parms.FLAG_SAVENEW =    false; % overwrite old scouts, you now have new data
parms.NewData =         []; % Use this new data for the calculation (will not overwrite atlas)
parms.NewTimeS =        []; % empty
parms = varargin_extraction(parms,varargin);

%% Load all Scouts and ScoutInfo from Atlas

global GlobalData
% If no AtlasName given, use the current one via GlobalData
if ~exist('AtlasName') || isempty(AtlasName)
    AtlasName = GlobalData.Surface.Atlas(GlobalData.Surface.iAtlas).Name ;
end
% If no SurfaceFile given, use the current one via GlobalData
if ~exist('SurfaceFile') || isempty(SurfaceFile)
    SurfaceFile = GlobalData.Surface.FileName;
end

sSurf = bst_memory('GetSurface', SurfaceFile);
[sAtlas.ScoutInfo,sAtlas.Scouts,AtlasFile,iAtlas] = Load_Scout_and_ScoutInfo(AtlasName,sSurf);

%% Go through each scout
for iscout = 1:length(sAtlas.Scouts)
    clear current_ScoutInfo
    % For each scout, find a match with ScoutInfo (using ScoutID)
    current_ScoutID = MakeScoutID(sAtlas.Scouts(iscout));
    iscoutinfo = find(ismember(struct_field2cell(sAtlas.ScoutInfo,'ScoutID'),current_ScoutID));
    
    % Load existing ScoutInfo OR start a new entry
    if isempty(iscoutinfo) % No existing ScoutInfo, so add a new ScoutInfo
        iscoutinfo = length(sAtlas.ScoutInfo)+1;
        current_ScoutInfo.ScoutID = current_ScoutID; % start ScoutInfo w/ the ID
        
    else % there is a match w/ an existing scoutinfo, load the existing scoutinfo
        % What if ScoutID isn't unique? screw that!
        if length(iscoutinfo) > 1
            error(['Conflicting ScoutID: ' current_ScoutID])
        end % more than one match...problem
        current_ScoutInfo = sAtlas.ScoutInfo(iscoutinfo);
    end % load previous ScoutInfo or make new
    
    % Make sure Scout is copied to ScoutInfo
    current_ScoutInfo = copy_fields(sAtlas.Scouts(iscout),current_ScoutInfo);
    % Basic info that will always be wanted
    current_ScoutInfo.surface =     sSurf.FileName;
    current_ScoutInfo.VerticesXYZ = sSurf.Vertices(current_ScoutInfo.Vertices,:); % actual xyz coordanates
    current_ScoutInfo.totalArea =   sum(sSurf.VertArea(current_ScoutInfo.Vertices)) * 100 * 100; % cm^2
    
    %% Data-related info
    
    % You have defined NewData at the input, set it as 'data'
    if ~isempty(parms.NewData)
        % force the data to be the function input's NewData
        current_ScoutInfo.Data =    parms.NewData;
        current_ScoutInfo.TimeS =   parms.NewTimeS; % defaults to empty
        parms.FLAG_SAVENEW = true; % dont overwrite old scouts, you now have new data
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
        [~,max_idx] = max(current_ScoutInfo.Data);
        current_ScoutInfo.Max = Vertex2Coord(current_ScoutInfo.Vertices(max_idx),...
            current_ScoutInfo.VerticesXYZ(max_idx,:),current_ScoutInfo.surface);
        current_ScoutInfo.Max.value =   current_ScoutInfo.Data(current_ScoutInfo.Vertices==current_ScoutInfo.Max.vertex); % value must be after Vertex2Coord or will be overwritten
        % project the location onto the ROI space
        current_ScoutInfo.Max.prinprj = ROIPrincipalProjection((current_ScoutInfo.Max.scsLoc/1000),ROI_VerticesXYZ) * 1000; % turn to mm
        
        if length(current_ScoutInfo.Vertices)>1 % Doesn't work for single vertex
            % ---Centroid Info---
            centroid_value =    mean(current_ScoutInfo.VerticesXYZ);
            centroid_idx =      knnsearch(current_ScoutInfo.VerticesXYZ,centroid_value); % NOTE: uses stats tool box (easy to replace)
            current_ScoutInfo.Centroid =  Vertex2Coord(current_ScoutInfo.Vertices(centroid_idx),...
                current_ScoutInfo.VerticesXYZ(centroid_idx,:),current_ScoutInfo.surface);
            current_ScoutInfo.Centroid.value = current_ScoutInfo.Data(current_ScoutInfo.Vertices==current_ScoutInfo.Centroid.vertex);
            % project the location onto the ROI space
            current_ScoutInfo.Centroid.prinprj = ROIPrincipalProjection((current_ScoutInfo.Centroid.scsLoc/1000),ROI_VerticesXYZ) * 1000; % turn to mm
            
            % ---CenterOfMass Info---
            % data-weighted centroid
            data_norm = ( current_ScoutInfo.Data - min(current_ScoutInfo.Data) )./abs(max(current_ScoutInfo.Data) - min(current_ScoutInfo.Data));
            CenterOfMass_value =    mean(current_ScoutInfo.VerticesXYZ.*[data_norm,data_norm,data_norm]);
            CenterOfMass_idx =      knnsearch(current_ScoutInfo.VerticesXYZ,CenterOfMass_value); % NOTE: uses stats tool box (easy to replace)
            current_ScoutInfo.CenterOfMass = Vertex2Coord(current_ScoutInfo.Vertices(CenterOfMass_idx),...
                current_ScoutInfo.VerticesXYZ(CenterOfMass_idx,:),current_ScoutInfo.surface);
            current_ScoutInfo.CenterOfMass.value = current_ScoutInfo.Data(current_ScoutInfo.Vertices==current_ScoutInfo.CenterOfMass.vertex);
            % project the location onto the ROI space
            current_ScoutInfo.CenterOfMass.prinprj = ROIPrincipalProjection((current_ScoutInfo.CenterOfMass.scsLoc/1000),ROI_VerticesXYZ) * 1000; % turn to mm
        end
        
    end % Is there data?
    
    %%  Write ScoutInfo back to it's structure
    sAtlas.ScoutInfo(iscoutinfo) = current_ScoutInfo;
    
end % Scout Loop

% Save
AtlasFile =     Save_Atlas_and_ScoutInfo(AtlasName,sAtlas.ScoutInfo,parms.FLAG_SAVENEW);
AtlasInfo =     sAtlas.ScoutInfo;

end % AtlasReport


%% ===MaskSelectedScouts===
function sAtlas = MaskSelectedScouts(MaskAtlas,MaskScouts,AtlasName,Scouts,SurfaceFile)
% Masks an existing scouts with other scouts.
% Original scouts are masked by scouts defined in 'MaskAtlas' and 'MaskScouts'
% Original scouts are either selected in the scout panel, or defined by 'AtlasName' and 'Scouts'
%
% Allows for multiple Scouts or MaskScouts if names are separated by |
% For multiple Atlases, copy multiple scouts to a single atlas first
% Masked-scouts are saved as a new scout in the original atlas (w/ the same color)
% Really this is just a standalone wrapper for Limit_Vertices_with_Scouts (above)
%
% WARNING: Does NOT save scout file, only deals w/ bst-db (also doesn't do anything with ScoutInfo)
%
% EXAMPLE:
%   Make new scout which is a masked version of the one selected in the GUI
%   Will mask to pre and post central left hemisphere
%       Select scout from GUI
%       process_SmartScout('MaskSelectedScouts','Desikan-Killiany','postcentral L|precentral L');
%
% 2014-03-02 Foldes
% UPDATES:

% SurfaceFile not needed if using current surface
if ~exist('SurfaceFile')
    SurfaceFile = [];
end

% Load scouts
[sScouts, sSurf] = panel_scout('GetScouts',SurfaceFile);

% Get selected scouts from GUI
if ~exist('AtlasName') || isempty(AtlasName) || ~exist('Scouts') || isempty(Scouts)
    [~, iScout] =  panel_scout('GetSelectedScouts');
    [~, iAtlas] =  panel_scout('GetAtlas');
    
else % Get scouts from function input
    iAtlas = find_lists_overlap_idx(struct_field2cell(sSurf.Atlas,'Name'),AtlasName);
    % Pull the existing scouts (you will add to existing)
    if ~isempty(iAtlas)
        sScouts = sSurf.Atlas(iAtlas).Scouts;
        % parse Scouts name (separated by '|')
        remain = Scouts;
        iscout = 0;
        while ~isempty(remain)
            iscout = iscout + 1;
            [Scouts_list{iscout} remain] = strtok(remain,'|');
            iScout = find_lists_overlap_idx(struct_field2cell(sScouts,'Label'),Scouts_list{iscout});
        end
    else
        error('Atlas does not exist')
    end
end

% For each scout, limit the existing vertices
clear sScouts_new
for iscout = 1:length(iScout)
    current_scout_num = iScout(iscout);
    sScouts_new(iscout) =           sScouts(current_scout_num);
    sScouts_new(iscout).Label =     [sScouts_new(iscout).Label '_MASKED_' MaskScouts];
    sScouts_new(iscout).Vertices =  Limit_Vertices_with_Scouts(sScouts(current_scout_num).Vertices,sSurf,MaskAtlas,MaskScouts);
    sScouts_new(iscout) =           panel_scout('SetScoutsSeed', sScouts_new(iscout), sSurf.Vertices); % +++BST-BUG+++ input of Vertices' is really VerticesXYZ (no documentaion)
end

% Now add the scouts to the atlas
sAtlas = sSurf.Atlas(iAtlas);
for iscout = 1:length(sScouts_new)
    sAtlas.Scouts(end+1) = sScouts_new(iscout);
end
panel_scout('SetAtlas', sSurf.FileName, iAtlas, sAtlas);
panel_scout('UpdateScoutsList');
panel_scout('UpdatePanel')
panel_scout('SaveModifications')

% might have to plot the new scout to get handels
% panel_scout('PlotScouts',iScout);

end % MaskSelectedScouts


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