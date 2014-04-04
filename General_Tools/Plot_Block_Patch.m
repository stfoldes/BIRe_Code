function fig_out=Plot_Block_Patch(block_pos,varargin)%height,Color,Alpha,patch_type,fig)
%function fig_out=Plot_Block_Patch(x_axis,block_pos,varargin)%height,Color,Alpha,patch_type,fig)
% Make patches of blocks/rectangles. Useful for highlighting (or hiding) parts of time-plots or showing where targets are in time (at the right relative size)
% Will do filled in blocks OR dotted block outline (see 'patch_type')
%
% x_axis:       [samples x 1] vector of x axis (usually time)
% block_pos:    [samples x 1] vector of 0 and 1 where 1 is the time points that should be in the block
%
% VARARGIN:
%     FaceColor:        color of box-fill (RBG or char code), 'none' for transparent [DEFAULT: Grey]
%     EdgeColor:        color of -- outline (RBG or char code), 'none' for no outline [DEFAULT: none]
%     Alpha:        transparency of box-fill (0-1) [DEFAULT: 0.6]
%     height:       [bottom, top] positions of each block [DEFAULT: ylim of current axis]
%     fig:          figure handle
%
% EXAMPLE:
%     Plot_Block_Patch([DEF_freq_bands('beta');DEF_freq_bands('gamma')],'EdgeColor','r','FaceColor','none')
%
% 2011-04-01 Foldes
% UPDATES:
% 2013-10-25 Foldes: MAJOR

%% Defaults

defaults.FaceColor = 0.6*[1 1 1];
defaults.EdgeColor = 'none';
defaults.LineWidth = 1.5;
defaults.Alpha = 0.4;
defaults.height = [];
defaults.fig = [];
parms=varargin_extraction(defaults,varargin);

%% Setup

if isempty(parms.fig)
    parms.fig=gcf;
end
figure(parms.fig);hold all;

if isempty(parms.height)
    parms.height = get(gca,'YLim');
end

%% Plot

clear fill_x fill_y
% for iblock = 1:size(block_pos,2)
%     fill_x = [block_pos(1,iblock),block_pos(1,iblock),block_pos(2,iblock),block_pos(2,iblock),]';
for iblock = 1:size(block_pos,1)
    fill_x = [block_pos(iblock,1),block_pos(iblock,1),block_pos(iblock,2),block_pos(iblock,2),]';
    fill_y = [min(parms.height),max(parms.height),max(parms.height),min(parms.height)]';
    zdata = ones(size(fill_y));
    
    patch(fill_x,fill_y,zdata,...
        'FaceColor',parms.FaceColor,'EdgeColor',parms.EdgeColor,'FaceAlpha',parms.Alpha,...
        'LineStyle','--','LineWidth',parms.LineWidth);
end

if nargout>0
    fig_out = parms.fig;
end
