function [power_data,FeatureParms]=Calc_PSD_TimeLocked(raw_data,event_idx,FeatureParms)
% 
% Calculates power spectrum (log10 of power) locked to a list of events
% 
% DEFAULT: Center on events: 
%     --------------
%     |---Window---|
%     --------------
%           ^
%           |
%         event
%
% For Window AFTER event (e.g. cue onset) event_list+(FeatureParms.window_length/2)
%     --------------
%     |---Window---|
%     --------------
%     ^
%     |
%   event
% 
%
% For Casual/pseudo-rt: event_list-(FeatureParms.window_length/2)
%     --------------
%     |---Window---|
%     --------------
%                  ^
%                  |
%                event
% 
% ---INPUTS---
% raw_data (samples x features)
% event_idx (events) list of samples to time lock power spectrum calculation
% FeatureParms struct: standard, can run PopulateFeatureParms.m to help build structure
%   Required FeatureParms Fields:
%   FeatureParms.feature_method = string for the method of power estimation ('FFT' or 'MEM' at this time)
%   FeatureParms.window_length = sample-length of ananlysis window
%   FeatureParms.sample_rate = sampling rate (Hz)
%   FeatureParms.freq_bins = the FFT bin numbers of the FFT you want
%   For FFT Specifically
%       FeatureParms.nfft = the size of the FFT you want (if using FFT)
%   For MEM Specifically (MEM is much slower)
%       FeatureParms.feature_resolution = for MEM
% 
% ---OUTPUTS---
% power_data = (samples x channels x freqbands)
% FeatureParms = the struct can be filled in in this function
%
% To calculate what frequencies these bins are:
%     Center Frequency = Frequency Bin Number * FeatureParms.sample_rate/FeatureParms.window_length;
% 
% Stephen Foldes [c.2008]
% UPDATES:
% 2012-08-29 Foldes: Created from Calc_PSD_PseudoRealTime.m
% 2012-08-30 Foldes: Added standard feature pareamter prep into this code
% 2012-09-25 Foldes: Added check for window being too big
% 2013-02-28 Foldes: Update documentation
% 2013-03-25 Foldes: Will not fail if analysis window is too big for last window (just warn)
% 2013-07-09 Foldes: actual_freq needed to be assigned here
% 2013-07-15 Foldes: Bug fix with freq_bins
% 2013-07-15 Foldes: MAJOR Default windowing changed to centered
% 2013-07-25 Foldes: MAJOR Power Calculated in FeatureParms.Calc_Features.m, MEM Parameters now set with another function and defaults changed

%% Run the standard FeatureParm setup
    FeatureParms=Prep_FeatureParms(FeatureParms);

    half_window_length = floor(FeatureParms.window_length/2); % used to center analyisis around cue
    
%% SETUP PSD PARAMETERS
    % Populate FeatureParms with less-standard parameters
    if strcmp(FeatureParms.feature_method,'FFT')
        if ~isfield(FeatureParms,'nfft') || (FeatureParms.nfft > FeatureParms.window_length)
            disp('Problem @Calc_PSD_TimeLocked: FFT size is bigger than window length. Setting nfft to window_length')
            FeatureParms.nfft=FeatureParms.window_length;
        end
        
        max_num_bins = FeatureParms.nfft;
        
    elseif strcmp(FeatureParms.feature_method,'MEM') % UPDATED 2013-07-25 Foldes
        % MEM_parms = [FeatureParms.order, FeatureParms.MEM_firstBinCenter, FeatureParms.MEM_lastBinCenter, FeatureParms.feature_resolution, FeatureParms.MEM_NumOfEvaluation, FeatureParms.MEM_Trend, FeatureParms.sample_rate];
        max_num_bins = round((FeatureParms.MEM_lastBinCenter-FeatureParms.MEM_firstBinCenter)/FeatureParms.feature_resolution); % helps to initilize sizes
    end
    
    % if you don't specify how many bins, use them all
    if ~isfield(FeatureParms,'freq_bins') || isempty(FeatureParms.freq_bins)
        FeatureParms.freq_bins = max_num_bins;
    end
    
    num_chan = size(raw_data,2);
    num_freq_bins = size(FeatureParms.freq_bins,2);

%% LOOP THRU EVENTS
    power_data=zeros(length(event_idx),num_chan,num_freq_bins);
        
    for ievent=1:length(event_idx) % go through event index given
        
        clear current_raw_data current_event_idx
        
        current_event_idx = event_idx(ievent);
        
        % don't do if the event is too close to the edges of the dataset
        if (current_event_idx+half_window_length>size(raw_data,1)) || (current_event_idx-half_window_length<1)
           warning('Error @Calc_PSD_TimeLocked: Window length too long for timelocking (will still return what I have)')
           return
        end
        current_raw_data=raw_data(current_event_idx-half_window_length:current_event_idx+half_window_length,:); % 2013-07-15 Foldes

        %% CALCULATE POWER
        [power_data(ievent,:,:), FeatureParms]=FeatureParms.Calc_Features(current_raw_data);
        
    end % time loop


% %% Standarizing power (zscore)
%     power_mean=mean(power_data);
%     power_sd=2*std(power_data);
%     norm_power=(power_data-ones(size(power_data,1),1)*power_mean)./ (ones(size(power_data,1),1)*(2*power_sd));


% figure;plot(power_data)
% max(isnan(power_data))

%% Display message box with completion note (SF 2012-01-26)
% completionmsgbox
