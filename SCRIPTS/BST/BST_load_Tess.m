% Cheat to get some basic BST stuff from figure into the workspace
% makes: TessInfo, sSurf, hFig from gcf
% 2014-03-03

if ~exist('hFig') || ~ishandle(hFig)
    hFig = gcf;
end

% Get info from figure
TessInfo = getappdata(hFig,'Surface');
% Get surface
sSurf = bst_memory('GetSurface', TessInfo.SurfaceFile);












