function processed_data=Calc_Processed_EMGandACC(Extract,varargin)
% Calculates time series data that will be used for marking events
% Does stuff like rectify smoothing of EMG
% This is slow
%
% VARARGIN
%     Any combo of: 'emg','ecg_from_emg','misc','acc','eog'
%     if none given, does all
%
% OUTPUTS:
%     processed_data.EMG_data
%     .MISC_data (photodiode)
%     .ACC_data
%     .blink_data
%     .cardiac_data
%     .*_chan_list
%
% SEE: Batch_Process_EMGandAcc_to_File
%
% 2013-08-16 Foldes [Branched]
% UPDATES:
% 2013-10-10 Foldes: MISC now LP filtered to 60Hz
% 2013-12-09 Foldes: MAJOR, varargin options


type_list = varargin;

if isempty(type_list)
    type_list= {'emg','ecg_from_emg','misc','acc','eog'};
end

for itype = 1:length(type_list)
    
    type_option = type_list{itype};
    
    switch lower(type_option)
        
        case 'emg'
            % EMG
            [EMG_data,processed_data.timeS,EMG_chan_list] = Load_from_FIF(Extract,'EMG');
            [processed_data.EMG_data] = Calc_Rectify_Smooth(EMG_data,Extract.data_rate,1);
            
        case 'ecg_from_emg'
            % ECG (from EMG)
            
            if ~exist('EMG_data')
                [EMG_data,processed_data.timeS,EMG_chan_list] = Load_from_FIF(Extract,'EMG');
                [processed_data.EMG_data] = Calc_Rectify_Smooth(EMG_data,Extract.data_rate,1);
            end
            
            processed_data.cardiac_data = Calc_Rectify_Smooth(EMG_data,Extract.data_rate);
            processed_data.cardiac_chan_list=EMG_chan_list;
            
        case 'misc'
            % MISC
            [MISC_data,~,processed_data.MISC_chan_list] = Load_from_FIF(Extract,'MISC');
            processed_data.MISC_data=Calc_Filter_Freq_SimpleButter(MISC_data,60,Extract.base_sample_rate);
            
        case 'acc'
            % Accelermeter (from MISC)
            if ~exist('MISC_data')
                [MISC_data,~,processed_data.MISC_chan_list] = Load_from_FIF(Extract,'MISC');
                processed_data.MISC_data=Calc_Filter_Freq_SimpleButter(MISC_data,60,Extract.base_sample_rate);
            end
            
            [processed_data.ACC_data] = Calc_Rectify_Smooth(MISC_data,Extract.data_rate,1);
            for ichan =1:size(processed_data.MISC_chan_list,1)
                processed_data.ACC_chan_list(ichan,:)=[processed_data.MISC_chan_list(ichan,:) '_diff'];
            end
            
        case 'eog'
            % EOG
            [blink_data,~,processed_data.blink_chan_list]=Load_from_FIF(Extract,'EOG');
            processed_data.blink_data = Calc_Rectify_Smooth(blink_data,Extract.data_rate);
    end
end

% clean up
switch lower(type_option)
    case 'emg'
        for ichan =1:size(EMG_chan_list,1) % not pretty, but adds _diff to the channel name
            processed_data.EMG_chan_list(ichan,:)=[EMG_chan_list(ichan,:) '_diff'];
        end
end
