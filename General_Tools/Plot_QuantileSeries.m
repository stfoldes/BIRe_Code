% fig_handle_out = QuantilePlot(plot_data,x_plot,fig_handle_in)
% Plots a line w/ 1st and 3rd quantile error bars
% 
% Input: plot_data (s x m) s=samples, m=measures
%        x_plot (X x 1) X=x-axis label (if [] then none are used)
%        fig_handle_in = handle of figure if want to plot on existing graph, [] will result in creation of handle
% Output: graph, fig_handle_out = handle of figure created (to address figure later)
%
% UPDATES:
% 2012-04-11 SF: renamed from QuantilePlot. Now only plot_data is needed to run.
%
% Stephen Foldes (2008-02-13)

function fig_handle_out = Plot_QuantileSeries(plot_data,x_plot,input_color,fig_handle_in)

quantile_data=quantile(plot_data,[.25 .50 .75]);

if ~isdefined('x_plot')
    x_plot=[1:size(quantile_data,2)];
end

if ~isdefined('fig_handle_in')
    fig_handle_out=figure;
else
    fig_handle_out=figure(fig_handle_in);
end

if ~isdefined('input_color')
   input_color = 'k';
end

hold all
errorbar(x_plot,quantile_data(2,:),quantile_data(1,:)-quantile_data(2,:),quantile_data(3,:)-quantile_data(2,:),'LineWidth',2,'Color',input_color)




