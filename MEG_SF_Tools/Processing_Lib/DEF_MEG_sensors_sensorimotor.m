% DEF_sma_MEG_sensors
% Stephen Foldes 2012-04-06
% 
% Define the list of my standard sensorimotor MEG sensorsa across all hemispheres

function sensor_list = DEF_MEG_sensors_sensorimotor

    sensor_list = sort(unique([DEF_MEG_sensors_sensorimotor_left_hemi DEF_MEG_sensors_sensorimotor_right_hemi]));