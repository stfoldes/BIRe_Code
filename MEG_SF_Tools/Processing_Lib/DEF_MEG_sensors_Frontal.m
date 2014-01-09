% DEF_MEG_sensors_Frontal
% Stephen Foldes 2012-09-17
% 
% Define the list of my standard frontal MEG sensors (not overlapping with sensorimotor)
% UPDATES:
% 2013-07-30 Foldes: Confirmed

function sensor_list = DEF_MEG_sensors_Frontal

    sensor_list = [49 52 85 91 94 55 88 100 61 103 106 58 25 97 127];    
    sensor_list = unique(sort([sensor_list sensor_list+1]));  
    
    % Plot_MEG_chan_locations(sensor_list)
    