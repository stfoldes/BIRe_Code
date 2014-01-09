%   Normalize()
%   Stephen Foldes
%   11-07-05
%   updated: 031808
% 
%   Normalizes/scales vector of size (time x samples) between 0 and 1
%   Each column is normalized to itself (i.e. each sample is normalized over time)
%   Outpus scaled data, max val and min val vectors



function [scaled_data,max_val,min_val]=Normalize(data)

% initialize output variable
scaled_data=zeros(size(data));

for isample=1:size(data,2)
    max_val=max(data(:,isample));
    min_val=min(data(:,isample));
    scaled_data(:,isample)=(data(:,isample)-min_val)/(max_val-min_val);
end