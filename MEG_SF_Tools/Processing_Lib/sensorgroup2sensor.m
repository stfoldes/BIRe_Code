% sensor = sensorgroup2sensor(sensor_group_list);
% 
% Translates sensor-group number to sensor number.
% sensor_type = which sensor type to return
%         1: Longitudinal Grads (Default - if no sensor_type given)
%         2: Latitudinal Grads 
%         3: Magnetometers
%         All: Return all 3 numbers
%
% EXAMPLE:
% [[1:length(sensor_group_list)]' sensorgroup2sensor(sensor_group_list)]
%
% 2013-06-25 Foldes
% UPDATES:
% 2013-06-27 Foldes: Default now returns Longitudinal Grad number

function  sensor = sensorgroup2sensor(sensor_group_list,sensor_type)

    load DEF_NeuromagSensorInfo;
    for isensor = 1:306
        sensor_group_ALL(isensor,:) = NeuromagSensorInfo(isensor).sensor_group_num;
    end
    
    for igroup = 1:length(sensor_group_list)
        sensor(igroup,:) = sort(find(sensor_group_ALL == sensor_group_list(igroup)));
    end
    
    % Which sensor type to return
    if exist('sensor_type') && ~isempty('sensor_type')
        switch sensor_type
            case {'all','All'}
                sensor = sensor; % return all 3
            otherwise
                sensor = sensor(:,sensor_type);
        end
    else
        sensor = sensor(:,1); % just return the first in the set if no sensor type given
    end