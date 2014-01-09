% fig = moving_avg_plot(data,x_data,window_size,variance_method,patch_color,fig);
% Stephen Foldes 01-09-2012
% 
% Sliding window that performs a variance and mean calculation and plots w/ Variance_Patch_Plot
% Window slide at 1 sample rate
% Despite the name, this can do any of Variance_Patch_Plot varibility measures (0=std=default)
% Currently this is slow b/c it doesn't pre-allocate memory (i.e. I'm lazy)
%
% data: (x-axis x samples)
% x_data: (x-axis x 1) = labels that correspond to the x-axis. If empty [], sets to 1:size of data
% window_size: number of samples for moving-window
% variance_method: 
%       0 = mean+-std, 
%       1 = 1st & 3rd Quantiles, 
%       2 = 5% and 95%
%       3 = min and max
% patch_color: color string (e.g. 'k') or 1x3 RGB vector for the color. If empty, grey is used
% fig: figure handle or empty for a new figure. Either way, the figure handle is output
%
% Uses default 'alpha' (i.e. transparency level) of 0.6 so you can see overlaps
% Uses default of no edges
% These options could be included in the 
%

function fig = moving_avg_plot(data,x_data,window_size,variance_method,patch_color,fig)


%% Set Defaults if needed
    if isempty(variance_method)
        variance_method = 0; %default is mean+-STD
    end

    if isempty(fig)
        fig = figure;
    end 
    figure(fig);hold all
    
    if isempty(x_data)
        x_data = 1:size(data,1);
    end
    
    if size(x_data,2)>1 % flip x_data around if wrong format
        x_data = x_data';
    end
    
    if isempty(patch_color) % default is grey
        patch_color = 0.6*[1 1 1];
    end
    
%%  Plot

    clear smooth_data
    for itime=1+window_size:size(data,1)
        smooth_data(itime,:) = (data(itime-window_size:itime,:));
    end
    Variance_Patch_Plot(smooth_data,x_data,variance_method,patch_color,fig);

