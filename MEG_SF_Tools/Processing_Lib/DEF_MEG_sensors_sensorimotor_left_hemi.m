function sensor_list = DEF_MEG_sensors_sensorimotor_left_hemi
%
% Define the list of my standard left hemisphere sensorimotor MEG sensors
%
% Defined for EMBC 2011 paper sensor_list = [13 16 37 40 67 28 31 70 64 22 19 46 43 73 178 199 202 82]
%
% Stephen Foldes 2012-01-30
% UPDATES
% 2013-07-30: Trimmed

neuromagCode_list=[];
neuromagCode_list = [neuromagCode_list 0332 0643 0623]; % Row 1 (PreCentral?)
neuromagCode_list = [neuromagCode_list 0223 0412 0423 0632]; % Row 2 (PostCentral?)
neuromagCode_list = [neuromagCode_list 0442 0433 0712]; % Row 3
neuromagCode_list = [neuromagCode_list 1812 1823 0742]; % Row 4
sensor_list = NeuromagCode2ChanNum(neuromagCode_list);
sensor_list = unique(sort([sensor_list sensor_list-1]));

%     figure;hold all
%     Plot_MEG_chan_locations(sensor_list,3,'r')
%     Plot_MEG_Helmet


%     % OLD, pre 2013-07-30
%     sensor_list = [13 16 37 40 67 28 31 70 64 22 19 46 43 73 178 199 202 82];
%     sensor_list = unique(sort([sensor_list sensor_list+1]));
%
