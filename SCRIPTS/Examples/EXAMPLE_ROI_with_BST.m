% EXAMPLE: ROI manually in BST
% 2014-03-28 Foldes
%
% Open up cortex.
% Manually make Scout w/ Scout tool (inflate larger than size)
% You can merge multiple scouts
% Select scout to mask w/ atlas
% Choose atlas-scouts to mask
% 
% process_SmartScout('MaskSelectedScouts','Desikan-Killiany','postcentral L|precentral L');
% 
% Will create a new scout, rename.
% 
% Repeat for multiple sub-ROIs or whatever
% 
% Might want to change the colors
% If you are using User Scouts, the name of the atlas will need to be renamed (BST has a bug that
% changes the  name)
% 
% EXAMPLES
% process_SmartScout('MaskSelectedScouts','Desikan-Killiany','postcentral L');
% process_SmartScout('MaskSelectedScouts','Desikan-Killiany','precentral L');
% process_SmartScout('MaskSelectedScouts','Desikan-Killiany','superiorfrontal L');
% process_SmartScout('MaskSelectedScouts','Destrieux','S_central L');
%
% ====================================================================================================
% Help from process_SmartScout (as of 2014-03-28)
%     Masks an existing scouts with other scouts.
%     Original scouts are masked by scouts defined in 'MaskAtlas' and 'MaskScouts'
%     Original scouts are either selected in the scout panel, or defined by 'AtlasName' and 'Scouts'
% 
%     Allows for multiple Scouts or MaskScouts if names are separated by |
%     For multiple Atlases, copy multiple scouts to a single atlas first
%     Masked-scouts are saved as a new scout in the original atlas (w/ the same color)
%     Really this is just a standalone wrapper for Limit_Vertices_with_Scouts (above)
% 
%     WARNING: Does NOT save scout file, only deals w/ bst-db (also doesn't do anything with ScoutInfo)
% 
%     EXAMPLE:
%       Make new scout which is a masked version of the one selected in the GUI
%       Will mask to pre and post central left hemisphere
%           Select scout from GUI
%           process_SmartScout('MaskSelectedScouts','Desikan-Killiany','postcentral L|precentral L');




