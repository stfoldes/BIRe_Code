function fig_out = Plot_Variance_as_Patch(x_data,y_data,varargin) % variance_method,patch_color,patch_alpha,fig
% Patch plot with given variance method. Use instead of a bunch of lines
%
% INPUTS:
% x_data: (x-axis x 1) [OPTIONAL]= labels that correspond to the x-axis. If empty or missing, sets to 1:size of data
% y_data: (x-axis x samples) (can be first input if x_data isn't given, not sure varargin will work then though)
%
% OPTIONAL (varargin):
% 'variance_method':
%       'STD' or 0 = mean+-std,
%       'quantile' or 1 = 1st & 3rd Quantiles,
%       'confidence' or 2 = 5% and 95%
%       'minmax' 3 = min and max
%       4 = makes a sorta histogram by ploting multiple ranges on top of each other ([0 1],[.1 .9],[.2 .8],[.3 .7],[.4 .6])
%       [* *] = Given Quantile Range
% 'patch_color': color string (e.g. 'k') or 1x3 RGB vector for the color. If empty, grey is used
% 'fig': figure handle or empty for a new figure. Either way, the figure handle is output
% 'patch_alpha': transparency [default 'alpha' (i.e. transparency level) of 0.6 so you can see overlaps]
%
% Uses default of no edges
%
% Stephen Foldes (2011-03-18)
% UPDATES:
% 2011-06-27 SF: Makes sure data with only one sample doesn't crash the system. For data of one sample/one dimension it just plots a line
% 2012-03-31 SF: Renamed from Variance_Patch_Plot
% 2012-05-24 SF: Added option to have quantile input range
% 2012-09-06 Foldes: Added option for ploting "histogram patch"
% 2012-10-05 Foldes: variance method can now be a string name
% 2012-10-07 Foldes: Alpha value option added
% 2013-08-09 Foldes: MAJOR Varargin method for inputs...go crazy Stephen

%% DEFAULTS

% Unpack varargin
defaults.variance_method = 0; %default is mean+-STD
defaults.patch_color = 0.6*[1 1 1]; % grey
defaults.patch_alpha = 0.4;
defaults.fig = [];
parms = varargin_extraction(defaults,varargin); % load inputs into default parameters

% If you don't give an x_data, then your first input was the data to plot
if ~exist('y_data') || isempty(y_data) || ischar(y_data)
    y_data = x_data;
    x_data = 1:size(y_data,1);
end
if size(x_data,2)>1 % flip x_data around if wrong format
    x_data = x_data';
end

% Open a new figure if none was given
if isempty(parms.fig)
    parms.fig = figure;
end
figure(parms.fig);hold all

%% Calculate 'variance'

% for ranges
if max(size(parms.variance_method))>1 && ~ischar(parms.variance_method)
    variance_method_code = 100;
else
    variance_method_code = parms.variance_method;
end

switch lower(variance_method_code)
    
    case {0,'std'}
        var_type_str = ['Mean' plusminus_char 'SD'];
        minus_std = min( [nanmean(y_data,2)-nanstd(y_data,[],2), nanmean(y_data,2)+nanstd(y_data,[],2)],[],2);
        plus_std = max( [nanmean(y_data,2)-nanstd(y_data,[],2), nanmean(y_data,2)+nanstd(y_data,[],2)],[],2);
        
    case {1,'quantile','interquantile'}
        var_type_str = ['Interquantile Range'];
        clear quantile_data
        quantile_data(:,:)=quantile((y_data'),[.25 .75]);
        
        minus_std = min(quantile_data,[],1)';
        plus_std = max(quantile_data,[],1)';
    case {2,'confidence'}
        var_type_str = ['5% - 95% Range'];
        clear quantile_data
        quantile_data(:,:)=quantile((y_data'),[.05 .95]);
        
        minus_std = min(quantile_data,[],1)';
        plus_std = max(quantile_data,[],1)';
    case {3,'minmax','maxmin'}
        var_type_str = ['MIN to MAX'];
        minus_std = min((y_data'),[],1)';
        plus_std = max((y_data'),[],1)';
    case 100
        var_type_str = [num2str(min(parms.variance_method)) '% - ' num2str(max(parms.variance_method)) '% Range'];
        clear quantile_data
        quantile_data(:,:)=quantile((y_data'),[min(parms.variance_method) max(parms.variance_method)]);
        
        minus_std = min(quantile_data,[],1)';
        plus_std = max(quantile_data,[],1)';
        
    case 4
        var_type_str = ['Histogram Patch Thing'];
        clear quantile_data
        
        quantile_range(:,1)=[0:0.05:0.4];
        quantile_range(:,2)=[1:-0.05:0.6];
        
        for iquantile=1:size(quantile_range,1)-1
            Plot_Variance_as_Patch(y_data,x_data,quantile_range(iquantile,:),parms.patch_color,parms.fig,0.2);
        end
        
        quantile_data(:,:)=quantile((y_data'),[quantile_range(end,:)]);
        minus_std = min(quantile_data,[],1)';
        plus_std = max(quantile_data,[],1)';
        
    otherwise
        error('Unsupported variance type @Plot_Variance_as_Patch');
        
end

%% Patch-it!
if size(y_data,2)>1 % only do if you are given more than one dimension
    patch([x_data; x_data(end:-1:1)],[minus_std; plus_std(end:-1:1)],parms.patch_color,'FaceAlpha',parms.patch_alpha,'EdgeColor','none')
    title(var_type_str)
else % just plot the normal line if only one sample is given
    plot(x_data,y_data,'Color',parms.patch_color,'LineWidth',3);
    disp('Plot_Variance_as_Patch.m was given only one sample, just ploting a line')
end

%% Outputs if needed
if nargout>0
    fig_out = parms.fig;
end