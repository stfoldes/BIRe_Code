function [sensor_group_data sensor_group_list] = Calc_Sensor2SensorGroup(sensor_data,sensor_list,combo_method)
% THIS DOESN'T WORK WELL FOR EVERYTHING, LIKE MAXMAG, JUST SIMPLE STUFF LIKE sum,min,max
%
% Combine MEG sensor data into sensor-group data.
% sensor_data = trial x SENSOR x frequency (must be 3D with sensor as 2nd Dim)
% sensor_list = list of what sensor numbers correspond to sensor_data dim2
% combo_method[OPTIONAL] = string for math to do for each sensor group (DEFAULT = sum of power)
%   Can be any math string that is used like XXX(data,dim);
%
% EXAMPLES
%   'sum': total power under sensor location
%
% SEE:
% Calc_ModDepth.m
%
% 2013-07-17 Foldes
% UPDATES:
% 2013-07-18 Foldes: Revamped to do more than just 'sum' of powers...but won't work for MAXMAG

if ~exist('combo_method') || isempty(combo_method)
    combo_method = 'sum';
end

% Sensor Grouping Info
load DEF_NeuromagSensorInfo;
for ichan = 1:length(sensor_list)
    sensor_idx2group(ichan) = NeuromagSensorInfo(sensor_list(ichan)).sensor_group_num;
end
sensor_group_list=unique(sensor_idx2group);

% Combine sensor groups using the given method name
sensor_group_data = zeros(size(sensor_data,1),length(sensor_group_list),size(sensor_data,3));
for igroup = 1:length(sensor_group_list)
    eval(['sensor_group_data(:,igroup,:) = ' combo_method '(sensor_data(:,(sensor_idx2group==sensor_group_list(igroup)),:),2);']);
end

