% DEF_MEG_sensors_Occipital
% Foldes [2012-09-17]
% 
% Define the list of occipital cortex MEG sensors (MIGHT INCLUDE MORE THAN LISTED HERE)
% UPDATES:
% 2013-07-30 Foldes: Removed 2 sets (i.e. 4)

function sensor_list = DEF_MEG_sensors_Occipital
    
    sensor_list = [187 193 196 211 214 217 220 229 232 235 238 241 244 259 262 265 268 283 289 292];    
    sensor_list = unique(sort([sensor_list sensor_list+1]));  
    
%     figure;hold all
%     Plot_MEG_chan_locations(sensor_list,3,'r')
%     Plot_MEG_Helmet