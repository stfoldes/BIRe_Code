% [chan_num_vec] = NeuromagCode2ChanNum(NeuromagCode_list);
% Translate Neuromag 306 sensor Neuromag Channel Code numbers to Channel number
%
% THIS DOES NOT MATCH BRAINSTORM (still need to check this 2012-11-18...seems okay)
%
% UPDATES:
% 2012-11-18 Foldes: Now works with cell array of names.
% 2013-02-21 Foldes: Uses NeuromagSensorInfo structure
% 2013-08-13 Foldes: Returns empty if no input

function [chan_num_vec] = NeuromagCode2ChanNum(NeuromagCode_list)

% return empty if didn't get anything
if isempty(NeuromagCode_list)
    chan_num_vec = [];
    return
end

load DEF_NeuromagSensorInfo; % loads ch_names

% This should be smarter, but what eves - 2013-02-21 Foldes
for ichan = 1:size(NeuromagSensorInfo,2)
    NeuromagCode_chan_names{ichan}=NeuromagSensorInfo(ichan).code;
end
    
for idsp = 1:length(NeuromagCode_list)
    
    if ~iscell(NeuromagCode_list) % if it is a cell, no need to do this translation
    dsp_num_str = num2str(NeuromagCode_list(idsp));
    % make sure its the right number of prepended 0s
    while size(dsp_num_str,2)<4
        dsp_num_str = ['0' dsp_num_str];
    end
    dsp_name_str = ['MEG' dsp_num_str];
    else
        dsp_name_str = NeuromagCode_list{idsp};
    end    
    
    ichan = 0; match_found_flag = 0;
    while ichan < size(NeuromagCode_chan_names,2) && match_found_flag == 0
        ichan = ichan+1;
        if strcmp(NeuromagCode_chan_names(ichan),dsp_name_str)
            chan_num_vec(idsp) = ichan;
            dsp_name_vec(idsp) = NeuromagCode_chan_names(ichan);
            match_found_flag = 1;
        end
    end
end

