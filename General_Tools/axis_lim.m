function  axis_lim(lim,dim,maxmin,ax_handle)
% axis_lim(lim,dim,maxmin[OPTIONAL],ax_handle[OPTIONAL])
% Helps xlim/ylim by allowing single values if you don't want to set both
% Will automatically set the height/width dimension that is closest to the input value unless maxmin entered
%
% lim:          value of how you want given axis limited 
%               (can be 2 numbers, then its just normal xlim() or ylim(), 1 number will try to set smart )
% dim:          str of 'x' or 'y' of the dimension of interest
% maxmin:       [OPTIONAL] str of 'min' or 'max' to force which dimension to adjust (default is to try to do it automatically)
% ax_handle:    [OPTIONAL] handle for axis, defaults to gca
%
% SEE: Figure_Subplot_Same_Axes('y') 
%
% Foldes 2012-10-07
% UPDATES:
% 2012-11-14 Foldes: Added maxmin option to force which dimension it adjusted
% 2013-10-23 Foldes: Added ax handle

if ~exist('maxmin')
    maxmin = [];
end

if ~exist('ax_handle') || isempty(ax_handle)
    ax_handle = gca;
end

% if you enter two limites, just use like normal axis limit
if max(size(lim))>1
    switch lower(dim)
        case 'x'
            xlim(ax_handle,lim);
        case 'y'
            ylim(ax_handle,lim);
    end
    
    % Do the fancy stuff
else
    switch lower(dim)
        case 'x'
            
            % try to figure out automatically if maxmin wasn't defined
            if ( ~strcmp(maxmin,'min') && ~strcmp(maxmin,'max') )
                [~,closest_dim] = min(abs(lim-xlim));
                maxmin_mask=[1;1];
                maxmin_mask(closest_dim)=0;
            % Force if maxmin was defined
            elseif strcmp(maxmin,'max')
                maxmin_mask = [1;0];
            elseif strcmp(maxmin,'min')
                maxmin_mask = [0;1];
            end
            
            xlim(ax_handle,sort([lim xlim*maxmin_mask]))
        case 'y'
            
            % try to figure out automatically if maxmin wasn't defined
            if ( ~strcmp(maxmin,'min') && ~strcmp(maxmin,'max') )
                [~,closest_dim] = min(abs(lim-ylim));
                maxmin_mask=[1;1];
                maxmin_mask(closest_dim)=0;
            % Force if maxmin was defined
            elseif strcmp(maxmin,'max')
                maxmin_mask = [1;0];
            elseif strcmp(maxmin,'min')
                maxmin_mask = [0;1];
            end
            
            ylim(ax_handle,sort([lim ylim*maxmin_mask]))
    end
end
