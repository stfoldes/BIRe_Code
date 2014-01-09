% caxis_center
% Stephen Foldes (2012-01-26)
%
% Forces current color plot to have a range centered around zero. Simple.
% Uses input value lim_value or current axis limit max(abs()) if lim_value is missing or empty
%
% EXAMPLE: pcolor(someshit);caxis_center;
% UPDATES: 
% 2012-05-23 SF: Changed name from center_caxis.m

function caxis_center(lim_value)

if ~exist('lim_value') || isempty(lim_value)
    caxis 'auto'
    color_limit = get(gca,'CLim');
    set(gca,'CLim',[-max(abs(color_limit)) max(abs(color_limit))]);
else
    set(gca,'CLim',[-abs(lim_value) abs(lim_value)]);
end

