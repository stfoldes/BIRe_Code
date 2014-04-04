% fig = Plot_MEG_Helmet(fig[optional],fill_flag[optional])
% Plots the outline of the MEG helemet
%
% fill_flag[optional] = if 'fill' or 1 (or anything but 0) will do a fill with the line
% 
% Foldes [2012-09-17]

function h = Plot_MEG_Helmet(fig,fill_flag)

% Load sensor location
load sensors102.mat
sensor_pos(:,1) = c102(:,2);
sensor_pos(:,2) = c102(:,3);

edge_sensor_nums = [4     1     2     9    17    18    29    31    32    43    51    52    53   100   101    97    98    81    82    66    63    57    58 4];

clear edge_sensor_pos
edge_sensor_pos(:,1) = sensor_pos(edge_sensor_nums,1);
edge_sensor_pos(:,2) = sensor_pos(edge_sensor_nums,2);

resolution = 10;

clear edge_sensor_pos_intp
edge_sensor_pos_intp(:,1) = interp(edge_sensor_pos(:,1),resolution);
edge_sensor_pos_intp(:,2) = interp(edge_sensor_pos(:,2),resolution);


%%

if ~exist('fig') || isempty(fig)
    fig = gcf;
end

figure(fig)
hold all


plot(edge_sensor_pos_intp(1:end-(resolution-1),1),edge_sensor_pos_intp(1:end-(resolution-1),2),'k','LineWidth',1)

if exist('fill_flag') & ~(fill_flag==0)
    fill(edge_sensor_pos_intp(1:end-(resolution-1),1),edge_sensor_pos_intp(1:end-(resolution-1),2),0.8*[1 1 1])
end

axis fill
axis tight
% set(gca,'Position',get(gca,'OuterPosition'))
axis equal

axis off
% scatter(edge_sensor_pos_intp(1:end-resolution,1),edge_sensor_pos_intp(1:end-resolution,2))

% Only send outputs if requested
if nargout
    h = fig;
end
