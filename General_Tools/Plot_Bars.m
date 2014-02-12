function fig_out = Plot_Bars(x_data,y_data,varargin) % OPTIONS: error_method, Color, bar_names, Color_line, fig
% Plot bar(s) graph w/ error bars
% Many options including error bar methods, Colors (for each bar!),
% easy x-axis labeling and manipulation, and allows for unequal groups
%
% OPTIONS: 
%     error_method: 'std' = error bars are mean+-std
%                   'quantile' = median+-25|75 percentile [DEFAULT]
%                   'confidence','95%' = 5-95%
%                   'maxmin','minmax' = max and min
%     Color: single RGB or Color-letter (e.g. 'r') for all bars [DEFAULT = grey]
%            OR a list of Colors for different bars (will repeat Color set given)
%               e.g. [0 1 0;1 0 0] OR {'g','r'} (Color-letters must be cell
%               a blank Color-letter will be grey (e.g. {'','r'} ...my favorite)
%     Color_line: single RGB or Color-letter for the error bars [DEFAULT = black]
%     bar_names: cell array of labels (this can be placed in x_data, see below)
%     fig: figure handle
%
% x_data: can be numbers or cell of XTickLabels (i.e. bar_names). [] is valid and needed to add varargins
% y_data: matrix OR cells. [bars x samples] OR {samples4bar#1, samples4bar#2, ...}
%         Entries of NaN will give a spacing between sets of bars (do not include blank labels)
%         Single values will not have error bars
%
% EXAMPLES:
%     % Example data (1 per bar)
%     data1 = [0.84615 0.38462  1 0.038462  1 0.96154 1];  
%     data2 = [0.96154 0.5 0.80769 0.61538 0.23077  1 0.96154];
% 
%     % Simple 1 bar w/ errors (interquartile range)
%     % data = [1xsamples]
%     Plot_Bars(data1)
% 
%     % Simple 2 bars w/ error bars
%     Plot_Bars([data1;data2])
% 
%     % Simple, 2 bars for unequal groups
%     Plot_Bars({data1, data2})
% 
%     % Reorder on x-axis (reverse)
%     Plot_Bars([2 1],{data1, data2})
% 
%     % Put Labels
%     Plot_Bars({'Data1','bar 2'},{data1, data2})
% 
%     % Reorder on x-axis w/ labels
%     Plot_Bars([2 1],{data1, data2},'bar_names',{'bar 2','Data1'})
% 
%     % STD instead of interquarile range, on a given figure handle
%     h = figure;
%     Plot_Bars([],{data1, data2},'error_method','std','fig','h')
% 
%     % w/ alternating bar Colors btw black red, and grey
%     Plot_Bars({'Data1','bar 2','Data 3'},{data1, data2, data1, data2, data1, data2},'Color',{'k','r',''})
%
%     % 1st bar is a single number (no error bar) followed by a space (b/c of NaN), space has no label
%     Plot_Bars({'Just a Number','Data1','bar 2'},{0.5, NaN, data1, data2})
%
% 2013-09-15 Foldes [branched from Plot_QuantileBar 2010-03-17]
% UPDATES:
% 2013-09-24 Foldes: Finished commenting, fixed bugs
% 2014-01-27 Foldes: color_name2rgb.m 

% Unpack varargin
defaults.error_method = 'quantile';
defaults.Color = 0.6*[1 1 1]; % grey
defaults.Color_line = 0*[1 1 1]; % Black
defaults.bar_names = [];
% defaults.alpha = 0.4;
defaults.fig = [];
parms = varargin_extraction(defaults,varargin); % load inputs into default parameters

% If you don't give an x_data, then your first input was the data to plot
if ~exist('y_data') || isempty(y_data) || ischar(y_data) % char = varargin start
    y_data = x_data;
    x_data = [];
end

% x data is the labels
if ischar(x_data) || iscell(x_data)
    parms.bar_names = x_data;
    x_data = [];
end

if size(x_data,2)>1 % flip x_data around if wrong format
    x_data = x_data';
end

% Open a new figure if none was given
if isempty(parms.fig)
    parms.fig = figure;
end
figure(parms.fig);hold all

%%

if iscell(y_data)
    % FOR CELLS WITH DIFFERENT NUMBER OF POINTS
    for iclass = 1:size(y_data,2)
        switch lower(parms.error_method)
            case 'std'
                var_type_str = ['Mean' char(177) 'SD']; % if you ever wanted to print out the error method (char(177) = +- symbol)
                minus_std(:,iclass)=min( [nanmean(y_data{iclass},2)-nanstd(y_data{iclass},[],2), nanmean(y_data{iclass},2)+nanstd(y_data{iclass},[],2)],[],2);
                plus_std(:,iclass)=max( [nanmean(y_data{iclass},2)-nanstd(y_data{iclass},[],2), nanmean(y_data{iclass},2)+nanstd(y_data{iclass},[],2)],[],2);
                mean_val(:,iclass) = nanmean(y_data{iclass},2);
            case {'quantile','interquantile'}
                var_type_str = ['Interquantile Range'];
                minus_std(:,iclass)=quantile(y_data{iclass},.25)';
                plus_std(:,iclass)=quantile(y_data{iclass},.75)';
                mean_val(:,iclass) = nanmedian(y_data{iclass},2);
            case {'confidence','95%'}
                var_type_str = ['5% - 95% Range'];
                minus_std(:,iclass)=quantile(y_data{iclass},.05)';
                plus_std(:,iclass)=quantile(y_data{iclass},.95)';
                mean_val(:,iclass) = nanmedian(y_data{iclass},2);
            case {'minmax','maxmin'}
                var_type_str = ['MIN to MAX'];
                minus_std(:,iclass) = min(y_data{iclass},[],2);
                plus_std(:,iclass) = max(y_data{iclass},[],2);
                mean_val(:,iclass) = nanmean(y_data{iclass},2);
        end
    end % doing iterative
    
else % NOT a cell
    switch lower(parms.error_method)
        case {'std'}
            var_type_str = ['Mean' char(177) 'SD'];
            minus_std = min( [nanmean(y_data,2)-nanstd(y_data,[],2), nanmean(y_data,2)+nanstd(y_data,[],2)],[],2);
            plus_std = max( [nanmean(y_data,2)-nanstd(y_data,[],2), nanmean(y_data,2)+nanstd(y_data,[],2)],[],2);
            mean_val = nanmean(y_data,2);
        case {'quantile','interquantile'}
            var_type_str = ['Interquantile Range'];            
            minus_std = quantile((y_data'),.25)';
            plus_std = quantile((y_data'),.75)';
            mean_val = nanmedian(y_data,2);
        case {'confidence','95%'}
            var_type_str = ['5% - 95% Range'];
            minus_std = quantile((y_data'),.05)';
            plus_std = quantile((y_data'),.95)';
            mean_val = nanmedian(y_data,2);
        case {'minmax','maxmin'}
            var_type_str = ['MIN to MAX'];
            minus_std = min(y_data,[],2);
            plus_std = max(y_data,[],2);
            mean_val = nanmean(y_data,2);
    end
end

if isempty(x_data)
    x_data = 1:length(mean_val);
end

non_Nan_idx = find(isnan(mean_val)~=1); % if you have a NaN input, don't plot the bar, just leave a space

hold all
% bar_h=bar(x_data(non_Nan_idx),mean_val(:,non_Nan_idx),'FaceColor',parms.Color,'EdgeColor',parms.Color_line,'LineWidth',2);

bar_h=bar(x_data(non_Nan_idx),mean_val(non_Nan_idx),'EdgeColor',parms.Color_line,'LineWidth',2);

% ===Change the Colors of each bar===
%   This is very hard (stupid Matlab)
%   http://www.mathworks.com/support/solutions/en/data/1-4LDEEP/index.html?solution=1-4LDEEP

num_bars = length(x_data(non_Nan_idx));
if ischar(parms.Color)% single char --> cell
    parms.Color={parms.Color};
end

% Turn Color strs into RGB
if iscell(parms.Color)
    cell_Color = parms.Color;
    parms.Color = [];
    for iColor = 1:length(cell_Color)
        if length(cell_Color{iColor})==1
            parms.Color(iColor,:) = color_name2rgb(cell_Color{iColor}); % 2014-01-27            
        else % set as default b/c can't interperet Color-str
            parms.Color(iColor,:) = defaults.Color;
        end
            
    end
end
colorm

%  Make the Color list the same length as the number of bars
parms.Color=repmat(parms.Color,ceil(num_bars/size(parms.Color,1)),1);

bar_child = get(bar_h,'Children'); %get children of the bar group
fvd = get(bar_child,'Faces'); %get faces data
fvcd = get(bar_child,'FaceVertexCData'); %get face vertex cdata

new_face_Colors = zeros(length(fvcd),3);
for ibars = 1:num_bars
    for irgb = 1:3 % do for r,g,b seprately
        new_face_Colors(fvd(ibars,:),irgb) = parms.Color(ibars,irgb); %adjust the face vertex cdata to be that of the row
    end
end
set(bar_child,'FaceVertexCData',new_face_Colors) %set to new face vertex cdata

% ====

if length(x_data)==length(plus_std) % Make shift: So if y_data is  [n x 1] it won't plot error bars
    var_idx = find((plus_std - minus_std)~=0); % indices where there is varance, otherwise don't plot an error bar
    
    errorbar(x_data(var_idx),mean_val(var_idx),minus_std(var_idx)-mean_val(var_idx),plus_std(var_idx)-mean_val(var_idx),...
        '.','Color',parms.Color_line,'LineWidth',2)
end

% X labels if desired
if ~isempty(parms.bar_names)
    set(gca,'XTick',sort(x_data(non_Nan_idx)))
    
    % replicate the x-labels if there aren't enough
    parms.bar_names = repmat(parms.bar_names,1,ceil(num_bars/length(parms.bar_names)));
    
    set(gca,'XTickLabel',parms.bar_names)
end

set(gca,'FontSize',12)

%% Outputs if needed
if nargout>0
    fig_out = parms.fig;
end