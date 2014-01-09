% DEF_MEG_sensors_sensorimotor_left_hemi_BEST
%
% Define the list of my favorite left hemisphere sensorimotor MEG sensors
%
% Stephen Foldes 2012-01-30
% UPDATES
% 2013-07-05 Foldes: now can return just one of the sensor numbers

function sensor_list = DEF_MEG_sensors_sensorimotor_left_hemi_BEST(sensor_idx)

sensor_list = [37 40 67 70 43];
sensor_list = sort([sensor_list sensor_list+1]);

if exist('sensor_idx') && ~isempty(sensor_idx)
    sensor_list = sensor_list(sensor_idx);
end


%     figure;hold all
%     Plot_MEG_chan_locations(sensor_list,3,'r')
%     Plot_MEG_Helmet