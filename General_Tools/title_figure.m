% title_figure(title_text,fig_handle)
% 
% Puts a title at the top of the main figure.
% Useful when there are subplots
% uses "annotation"
% 
% 2012-09-24 Foldes & Wodlinger

function title_figure(title_text,fig_handle)

if ~exist('fig_handle') || isempty(fig_handle)
    fig_handle = gcf;
end

annotation(fig_handle,'textbox',[0 0.9 1 0.1],...
    'String',title_text,...
    'HorizontalAlignment','center',...
    'FitBoxToText','on',...
    'FontWeight','bold',...
    'LineStyle','none');

%     'FontSize',12,...
%     'FontName','Times New Roman',...

