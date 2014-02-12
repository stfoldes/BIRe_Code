% Load and plot surface w/ brodmann's area
% 2014-01-31 Foldes

%% Load BST info
global BST_DB_PATH

BST_DB_PATH = '/home/foldes/Data/brainstorm_db/';

Extract.project =           'Test';
Extract.subject_id =        'Subject01_copy';
Extract.stim_name =         '1'; % name of stimulus
Extract.inverse_method =    'wMNE'; % 'dSPM' % The name of the method used

[Inverse,Surface,HeadModel] = BST_Load_Inverse_Data(Extract);

brod_area_name =    'BA1 L';
brod_area_color =   'g';

% function BRAIN = SCRIPT_BST_Plot_BrodmannArea(Surface,brod_area_name,brod_area_color)

%% Plot atlas
Brain = BrainSurface_Class;
Brain.Faces =       Surface.Faces;
Brain.Vertices =    Surface.Vertices;
%Brain.SulciMap =    Surface.SulciMap;

Brain = Brain.Plot_Underlay;

Scouts_Brod = Surface.Atlas(DB_find_idx(Surface.Atlas,'Name','Brodmann')).Scouts;

% DB_lookup_unique_entries(Scouts_Brod,'Label')
ROI_Vert = Scouts_Brod(DB_find_idx(Scouts_Brod,'Label',brod_area_name)).Vertices;

clear NewOverlay
NewOverlay.Vertices = Brain.Vertices(ROI_Vert,:);

Brain = Brain.Plot_Overlay(NewOverlay,'Colormap',brod_area_color);
