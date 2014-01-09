% Making NeuromagSensorInfo Structure
% 2013-02-21 Foldes
% UPDATES
% 2013-07-30 Foldes: MAJOR Found that inherited sensor locations were flawed (not even centered)! Now based on FieldTrip

% load('sensors102.mat') % OMG, this is not centered FUCK IT

% load('DEF_Neuromag_chan_names')

clear NeuromagSensorInfo
for ichan = 1:306
    NeuromagSensorInfo(ichan).code = cell2mat(NeuromagCode_chan_names(ichan));
    NeuromagSensorInfo(ichan).code_number = str2num(NeuromagSensorInfo(ichan).code(4:end));
    NeuromagSensorInfo(ichan).sensor_code = NeuromagSensorInfo(ichan).code(4:6);
    NeuromagSensorInfo(ichan).sensor_group_num = find(round(c102(:,1)/10) == str2num(NeuromagSensorInfo(ichan).code(4:6)));
    NeuromagSensorInfo(ichan).pos=c102(NeuromagSensorInfo(ichan).sensor_group_num,2:3);
end


Who cares
% % Load data from FieldTrip .lay file
% fid=fopen('neuromag306all.txt');
% raw=textscan(fid,'%f %f %f %f %f %s');
% fclose(fid)
% 
% % raw{1} % channel #, should be 1:306
% % [raw{2} raw{3}] % This is the x and y pos for each sensor...but each sensor type has a differen pos, which doesn't make sense
% % raw{6} % This is the Sensor Name = NeuromagCode_chan_names
% 
% % Sensor Names
% NeuromagCode_chan_names = raw{6};
% 
% % Find Centroid locations for each sensor set
% for isensor_set = 1:102
%     centroid(isensor_set,:)=[sum(raw{2}(isensor_set*3-2:isensor_set*3))/3,sum(raw{3}(isensor_set*3-2:isensor_set*3))/3];
% end
% 
% 
% figure;hold all
% plot(centroid(:,1)/2,centroid(:,2)/2,'.')
% % plot(raw{2}(1:3:306)./2,raw{3}(1:3:306)./2,'.')
% % plot(raw{2}(2:3:306)./2,raw{3}(2:3:306)./2,'.')
% % plot(raw{2}(3:3:306)./2,raw{3}(3:3:306)./2,'.')
% plot(c102(:,2),c102(:,3),'.')
% axis 'square'
