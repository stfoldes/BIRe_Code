% center_yaxis
% Stephen Foldes (2012-02-20)
%
% Forces current plot to have a yaxis range centered around zero. Simple.
% Uses input value lim_value or current axis limit max(abs()) if lim_value is missing or empty
%

function center_yaxis(lim_value)

y_limit = get(gca,'YLim');
if ~exist('lim_value') || isempty(lim_value)
    set(gca,'YLim',[-max(abs(y_limit)) max(abs(y_limit))]);
else
    set(gca,'YLim',[-lim_value lim_value]);
end

