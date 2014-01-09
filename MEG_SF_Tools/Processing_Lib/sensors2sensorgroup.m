% sensor_group_list = sensors2sensorgroup(sensor_list);
% 
% Translates sensor numbers to group numbers
% All this does is:
%     1) Load NeuromagSensorInfo
%     2) NeuromagSensorInfo(sensor_list).sensor_group_num
%
% This is really just b/c my DEF_MEG_sensors lists don't work as easily as 2) above.
%
% sensor_list = DEF_MEG_sensors_sensorimotor_right_hemi;    
%
% unique(sensors2sensorgroup(sensor_list)) might be needed for you
%
% 2013-03-28 Foldes
% UPDATES:
% 

function sensor_group_list = sensors2sensorgroup(sensor_list)

    load DEF_NeuromagSensorInfo;
    for isensor = 1:length(sensor_list)
        sensor_group_list(isensor) = NeuromagSensorInfo(sensor_list(isensor)).sensor_group_num;
    end
