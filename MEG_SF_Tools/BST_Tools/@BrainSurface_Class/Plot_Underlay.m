function obj = Plot_Underlay(obj,varargin) %'Viewpoint',Color','Transp'
% Surface plot of the brain.
% The data can be generated in Brainstorm (/brainstorm_db/Test/anat/Subject01_copy/tess_cortex_pial_low.mat)
%
% INPUTS:
%   obj.Faces:      [~(2*nverticies) x 3]
%   obj.Vertices:   [nverticies x 3]
%   obj.fig:        handle, can be empty
%
% VARARGIN:
%   % figure parameters
%   Viewpoint:      camera position [x y], can be string: top [DEFAULT], back, left, right, front
%
%   % surface parameters
%   Color:          color of the brain surface, [DEFAULT = light grey .7*[1 1 1]]
%   Transp:          Transparency [DEFAULT = 0.2] DONT THINK THIS WORKS
%
%
% Output figure will have data attached (getappdata)
%   Faces,Vertices,VerticesColor
%
% Some inspiration came from here: http://www.mathworks.com/matlabcentral/fileexchange/35496-electrocorticography-intracranial-eeg-visualizer
%
% 2014-01-27 Foldes
% UPDATES:
%

%% Parameters

% figure parameters
parms.Viewpoint =       'top'; % starting view (Top w/ nose to left)

% surface parameters
parms.Color =           .7*[1 1 1]; % light grey % pinkish [0.9 0.62 0.46];%
parms.Transp =           []; % transparency
parms.BackgroundColor = 'k';

parms = varargin_extraction(parms,varargin);

%% Setup

% Start figure if there is no figure or the handel is dead
if isempty(obj.fig) || ~ishandle(obj.fig)
    obj.fig = figure;
end
figure(obj.fig);hold all


%% Coloring

% if the map is a color-letter, make it into RGB
if ischar(parms.Color) && length(parms.Color) == 1
    parms.Color = color_name2rgb(parms.Color);
end

% Color for each face of the brain surface
obj.VerticesColor = repmat(parms.Color, [size(obj.Vertices, 1) 1]);

% Sulci Color (see BST: figure_3d line 1984)
% if ~isempty(obj.SulciMap) %&& obj.SulciOn == 1
%     parms.Color(2-obj.SulciMap,:);
% 
% end


%% Plot brain surface
obj = Update_Surf(obj,parms);

%% Outputs

% % Store the faces and vertices information to the figure handel
% setappdata(obj.fig,'Faces',Faces);
% setappdata(obj.fig,'Vertices',Vertices);
% setappdata(obj.fig,'VerticesColor',VerticesColor);
