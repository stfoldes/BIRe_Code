function sensor_list = DEF_MEG_sensors_sensorimotor_right_hemi
%
% Define the list of my standard right hemisphere sensorimotor MEG sensors
%
% Stephen Foldes 2012-04-06
% UPDATES:
% 2012-05-23 SF: Whoops, there were some doubles.
% 2013-07-30: Trimmed

neuromagCode_list=[];
neuromagCode_list = [neuromagCode_list 0623 1033 1242]; % Row 1 (PreCentral?) 
neuromagCode_list = [neuromagCode_list 1042 1113 1122 1313]; % Row 2 (PostCentral?)
neuromagCode_list = [neuromagCode_list 0722 1143 1132]; % Row 3
    neuromagCode_list = [neuromagCode_list 0732 2213 2222]; % Row 4
sensor_list = NeuromagCode2ChanNum(neuromagCode_list);
sensor_list = unique(sort([sensor_list sensor_list-1]));

% figure;hold all
% Plot_MEG_chan_locations(sensor_list,3,'r')
% Plot_MEG_Helmet

% OLD, pre 2013-07-30
% sensor_list = [64 76 79 109 112 115 118 121 124 133 136 139 142 145 148 247 250 271];
% sensor_list = unique(sort([sensor_list sensor_list+1]));


