% sensor_group_pos = sensorgroup2pos(sensor_group_list);
% 
% Translates sensor-group number to sensor positions
% All this does is:
%     1) Load NeuromagSensorInfo
%     2) NeuromagSensorInfo(sensor_list).pos
%
% This is really just b/c my DEF_MEG_sensors lists don't work as easily as 2) above.
%
% 2013-06-13 Foldes
% UPDATES:
% 

function  sensor_group_pos = sensorgroup2pos(sensor_group_list)

    load DEF_NeuromagSensorInfo;
    for isensor = 1:102
        sensor_group_pos_ALL(isensor,:) = NeuromagSensorInfo(isensor*3).pos;
    end
    if exist('sensor_group_list') && ~isempty(sensor_group_list)
        sensor_group_pos=sensor_group_pos_ALL(sensor_group_list,:);
    else
        sensor_group_pos=sensor_group_pos_ALL;
    end
    