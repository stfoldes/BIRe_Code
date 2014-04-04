function Figure_Subplot_Same_Axes(dim,lim,fig)
% Makes all subplots have the same axis-limits
%
% dim: 'x' or 'y' (SEE: axis_lim)
% lim: [OPTIONAL] normal [* *] or single value (see axis_lim), if empty will use max-min
% fig: [OPTIONAL] figure handle, defaul gcf
%
% EXAMPLE:
%     All subplots have the same y limit and its the max/min over all
%     Figure_Subplot_Same_Axes('y') 
%
% 2013-10-23 Foldes
% UPDATES:
%

if ~exist('fig') || isempty(fig)
    fig = gcf;
end

if ~exist('lim')
    lim = [];
end

% get children for subplots
child_list = get(fig,'Children');


if ~isempty(lim) % normal
    for ichild=1:length(child_list)
        % Only do for axes
        if strcmp(get(child_list(ichild),'Type'),'axes')
            % don't do for legends (will have Orientation)
            if ~isprop(child_list(ichild),'Orientation')
                % Now you have an axis that is not a legend, do the change
                axis_lim(lim,dim,[],child_list(ichild));
            end % legend
        end % axes
    end % child
    
    %%
else % no lim given, find max/mins
    axes_list = [];
    axes_limit_list = [];
    
    for ichild=1:length(child_list)
        % Only do for axes
        if strcmp(get(child_list(ichild),'Type'),'axes')
            % don't do for legends (will have Orientation)
            if ~isprop(child_list(ichild),'Orientation')
                % Now you have an axis that is not a legend, do the change
                
                % Collect the handles and limits to all plots
                axes_list = [axes_list; child_list(ichild)];
                
                switch lower(dim)
                    case 'x'
                        axes_limit_list = [axes_limit_list; get(child_list(ichild),'XLim')];
                    case 'y'
                        axes_limit_list = [axes_limit_list; get(child_list(ichild),'YLim')];
                end
                
            end % legend
        end % axes
    end % child
    
    % find max/min over all plots
    maxmin_lim = [min(axes_limit_list(:,1)) max(axes_limit_list(:,2))];
    
    % Go thru all axes and set
    for iax=1:length(axes_list)
        axis_lim(maxmin_lim,dim,[],axes_list(iax));
    end
    
end % lim