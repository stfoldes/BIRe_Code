% function dist_data = quick_distribution(data,dim)
% Stephen Foldes 01-25-2012
%
% Used to quickly look at the distribution of a data set
% Returns a vector of quantiles [min 25% 50% 75% max] and a summary distribution plot (i.e. histogram). 
% This is super simple, but quicker and has some smarts for 1D arrays.
% dim: the dimension to look over (can be absent)
%
% 01-25: NOT MADE FOR HIGHER DIMENSIONS, TEXT SPACING SHOULD BE BETTER

function dist_data = quick_distribution(data,dim)

% "dim" not required. this will be smart on 1D arrays.
if ~exist('dim') || isempty(dim)
    if size(data,2)==1
        dim = 1;
    elseif size(data,1)==1
        dim = 2;
    else
        dim = 1;
    end
end

dist_data = quantile(data,[0 .25 .50 .75 1],dim);

% [hist_data hist_bins]= hist(data);
[hist_data hist_bins]= hist(data,length(unique(data))/10);

%% Plot a histogram w/ info

figure;hold all
bar(hist_bins,hist_data,0.9,'FaceColor',0.9*[1 1 1],'EdgeColor',0.7*[1 1 1])
set(gca,'FontSize',12);
title('Histogram (quick distribution.m)');ylabel('Occurences');xlabel('Values')

text_spacing=max(hist_data)/20; % should be relative to hist_data range

text(dist_data(1),max(hist_data)-0*text_spacing,['Median' plusminus_char 'IQR: ' num2str(dist_data(3)) ' ' plusminus_char ' ' num2str(dist_data(4)-dist_data(2))],'FontSize',10);
text(dist_data(1),max(hist_data)-1*text_spacing,['Mean' plusminus_char 'SD   : ' num2str(mean(data,dim)) ' ' plusminus_char ' ' num2str(std(data,[],dim))],'FontSize',10);
text(dist_data(1),max(hist_data)-2*text_spacing,['Range        : ' num2str(dist_data(1)) ' - ' num2str(dist_data(5))],'FontSize',10);

% Addition info on the data
text(dist_data(1),max(hist_data)-3*text_spacing,['Count         : ' num2str(size(data,dim))],'FontSize',10);
% text(dist_data(:,1),max(hist_data)-4*text_spacing,['num unique : ' num2str(length(unique(data)))],'FontSize',10);



