% Calc_Sensor_Masked_by_pValue(data2mask,feature_data_move,feature_data_rest,sensor_list,FeatureParms,freq_range,p_thres)
% Calculates a masked set of values by thresholing p-values for each sensor-group
% Can use inline!
%
% SEE: Calc_Sensor_pValues.m
%
% feature_data_move
% feature_data_rest
% sensor_list (Extract.chan_list)
% FeatureParms
% freq_range range of frequencies to plot over
%
% 2013-07-01 Foldes
% UPDATES:
% 2013-07-15 Foldes: mask apply split off as function

function masked_data = Calc_Sensor_Masked_by_pValue(data2mask,feature_data_move,feature_data_rest,sensor_list,FeatureParms,freq_range,p_thres)

[~,sig_by_group]=Calc_Sensor_pValues(feature_data_move,feature_data_rest,sensor_list,FeatureParms,freq_range);


masked_data = Calc_Sensor_Mask_Apply(data2mask,sig_by_group,p_thres);
% 
% % Set sensor-groups that are NOT sig (.05) to zero for plotting
% if p_thres>0
%     non_sig_sensor_groups = find(sig_by_group>=p_thres);
% else
%     non_sig_sensor_groups = [];
% end
% 
% masked_data = data2mask;
% for isensor_group =non_sig_sensor_groups
%     masked_data(:,isensor_group,:) = data2mask(:,isensor_group,:).*0;
% end