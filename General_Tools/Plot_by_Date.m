function h = Plot_by_Date(date_list,y,varargin)
% Plots y on a date scale
% Should add date-spacing option if you have closely spaced
%
% VARARGIN:
%     .date_list_format = 'yyyymmdd';
%     .date_plot_format = 'mm-dd-yyyy';
%     .LineSpec='k.';
%     .fig = [];
%
% 2013-10-08 Foldes
% UPDATES:


defaults.date_list_format = 'yyyymmdd';
defaults.date_plot_format = 'mm/dd/yy';
defaults.LineSpec='k.';
defaults.fig = [];
parms = varargin_extraction(defaults,varargin);

date_list_num=datenum(date_list,parms.date_list_format);

if isempty(parms.fig)
    parms.fig = figure;
end

figure(parms.fig);hold all
plot(date_list_num,y,parms.LineSpec)
set(gca,'XTick',unique(date_list_num))
set(gca,'XTickLabel',datestr(unique(date_list_num),parms.date_plot_format))

try
    xlabel_rotate(90)
end
