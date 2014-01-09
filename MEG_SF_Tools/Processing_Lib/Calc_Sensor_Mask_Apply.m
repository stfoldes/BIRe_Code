function masked_data = Calc_Sensor_Mask_Apply(data2mask,sig_by_group,p_thres)
% Applies a mask-set using a threshold
% Code Saver
% 
% SEE: Calc_Sensor_pValues.m, Calc_Sensor_Masked_by_pValue.m
%
% 2013-07-15 Foldes
% UPDATES:

% Set sensor-groups that are NOT sig (.05) to zero for plotting
if p_thres>0
    non_sig_sensor_groups = find(sig_by_group>=p_thres);
else
    non_sig_sensor_groups = [];
end

masked_data = data2mask;
for isensor_group =non_sig_sensor_groups
    masked_data(:,isensor_group,:) = data2mask(:,isensor_group,:).*0;
end