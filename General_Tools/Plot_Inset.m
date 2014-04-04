% [final_fig]=Plot_inset(base_fig,inset_fig,inset_size_ratio[optional],horz_pos_ratio[optional],vert_pos_ratio[optional])
% Insets a figure inside another. Works with subplots
% 
% Inputs
% base_fig = figure handle for the larger, main figure (can be suplot handle)
% inset_fig = handle for the smaller inset figure
% inset_size_ratio[optional] = size for inset as a relative ratio to main figure (1=as big as main figure) [default = 0.1]
% horz_pos_ratio[optional] = horizonal location of inset as a relative ratio to main figure (0=left, 1=right) [default = 0 (i.e. left)]
% vert_pos_ratio[optional] = vertical location of inset as a relative ratio to main figure (0=bottom, 1=top) [default = 1 (i.e. top)]
% 
% Foldes [2012-09-17]
% UPDATES:
% 2012-09-17 Foldes: Now works with subplots

function Plot_inset(base_fig,inset_fig,inset_size_ratio,horz_pos_ratio,vert_pos_ratio)

%% Defaults
if ~exist('inset_size_ratio') || isempty(inset_size_ratio)
    inset_size_ratio=0.1;
end
if ~exist('horz_pos_ratio') || isempty(horz_pos_ratio)
    horz_pos_ratio=0;
end
if ~exist('vert_pos_ratio') || isempty(vert_pos_ratio)
    vert_pos_ratio=1;
end

%% Dealing with subplots

if get(base_fig,'Parent')~=0
    base_fig_handle = get(base_fig,'Parent');
    child_idx = find(base_fig==get(base_fig_handle,'Children'));
else
    base_fig_handle = base_fig;
    child_idx = 1;
end


%% Make new figure combining the two
figure(base_fig_handle); 
hold all

inset_fig_axis = findobj(inset_fig,'Type','axes');
final_fig_inset_handle = copyobj(inset_fig_axis,base_fig_handle);

%% Set inset position and size

base_fig_axis = findobj(base_fig_handle,'Type','axes');
% 'Position' = [left, bottom, width, height]
base_fig_axis_position=get(base_fig_axis(child_idx,:),'Position');
base_left = base_fig_axis_position(1);
base_bottom = base_fig_axis_position(2);
base_width = base_fig_axis_position(3);
base_height = base_fig_axis_position(4);

inset_width = base_width*(inset_size_ratio^.5);
inset_height = base_height*(inset_size_ratio^.5);

inset_left = base_left+horz_pos_ratio*(base_width-inset_width);
inset_bottom = base_bottom+vert_pos_ratio*(base_height-inset_height);

set(final_fig_inset_handle,'Position', [inset_left inset_bottom inset_width inset_height])


%% Clean up (not sure if you will want to keep these old figs

try; close(inset_fig); end
