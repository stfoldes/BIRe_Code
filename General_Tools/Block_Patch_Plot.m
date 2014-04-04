% fig=Block_Patch_Plot(block_pos,x_axis,min_height,max_height,patch_color,fig)
% Stephen Foldes 04-01-11
%
% Used to make patches of blocks. Useful for highlighting (or hiding) parts of time-plots or showing where targets are in time (at the right relative size)
% block_pos: (samples x 1) = vector of 0 and 1 where 1 is the time points that should be in the block
% x_axis: (samples x 1) = vector of x axis (usually time)
% min_height/max_height = bottom and top positions of each block (default 0-1)
% patch_color = what color; RBG or char code (default grey)
% patch_type: 1=filled in block, 2=dotted block outline
% fig = figure handle (optional)

function fig=Block_Patch_Plot(block_pos,x_axis,min_height,max_height,patch_color,patch_type,fig)

%% Defaults
    if isempty(min_height)
        min_height = 0;
    end
    if isempty(max_height)
        max_height = 1;
    end    
    if isempty(patch_color)
        patch_color = 0.4*[1 1 1];
    end
    if isempty(patch_type)
        patch_type = 1;
    end
    
%%    
    change_idx=unique([1; find(abs(diff(block_pos))>0)+1; size(block_pos,1)]);

    block_pos_minus = zeros(size(block_pos,1),1);
    block_pos_plus = zeros(size(block_pos,1),1);
    block_pos_minus(block_pos==1)=min_height;
    block_pos_plus(block_pos==1)=max_height;
    
    clear fill_x fill_y
    for isample =1:length(change_idx)-1
        fill_x(:,isample) = [x_axis(change_idx(isample)), x_axis(change_idx(isample)), x_axis(change_idx(isample+1)), x_axis(change_idx(isample+1))]';
        fill_y(:,isample) = [block_pos_minus(change_idx(isample)), block_pos_plus(change_idx(isample)), block_pos_plus(change_idx(isample)), block_pos_minus(change_idx(isample))]';
    end    
    zdata = ones(size(fill_y));
    
    if isempty(fig)
        fig=figure;
    else
        figure(fig);
    end
    
    hold all;
    
    if patch_type == 1
        patch(fill_x,fill_y,zdata,patch_color,'FaceAlpha',0.6,'EdgeColor','none')
    elseif patch_type == 2
        patch(fill_x,fill_y,zdata,'FaceColor','none','EdgeColor',patch_color,'LineStyle','--','LineWidth',2)
    end