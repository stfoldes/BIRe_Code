function Plot_VerticalMarkers(marker_locations,varargin)
%function Plot_VerticalMarkers(marker_locations,varargin)
% Plots a vertical line on the current plot
% You can specifiy the color and even give some text label the line.
%
% VARARGIN:
%     Color
%     MarkerText
%     MarkerTextDir: 'horizontal'(on top of line, default) OR 'vertical' (along line)
%     LineWidth
%
% Foldes [<2012-09-01]
% UPDATES:
% 2012-09-13 Foldes: Added the text thing
% 2013-04-18 Foldes: Added parms.LineWidth option
% 2013-10-10 Foldes: varargin
% 2013-12-18 Foldes: Horizontal option added

defaults.Color          = 0.4*[1 1 1];
defaults.MarkerText     = [];
defaults.MarkerTextDir  = 'horizontal';
defaults.LineWidth      = 2;
parms=varargin_extraction(defaults,varargin);

line_lims = get(gca,'YLim');
hold all

for isample = 1:length(marker_locations)
    plot([marker_locations(isample) marker_locations(isample)],line_lims,'--','LineWidth',parms.LineWidth,'Color',parms.Color)
    if ~isempty(parms.MarkerText)
        
        switch lower(parms.MarkerTextDir)
            case {'vertical','vert','ver','v'}
                text(marker_locations(isample),max(line_lims),parms.MarkerText,'FontSize',12,...
                    'HorizontalAlignment','center','VerticalAlignment','bottom');
            case {'horizontal','hor','horz','h'}
                text(marker_locations(isample),max(line_lims),parms.MarkerText,'FontSize',12,...
                    'HorizontalAlignment','right','VerticalAlignment','bottom','Rotation',90);
        end
        
    end
end


