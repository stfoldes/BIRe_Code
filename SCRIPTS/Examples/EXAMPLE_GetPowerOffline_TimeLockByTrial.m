% Toy example of how to use GetPowerOffline_TimeLockByTrial.m
% Stephen Foldes 05-24-11
% Creates a noisy sine wave that changes its frequency 3 times
% Function will take signal and event index vector and return a cell array of power for each event (i.e. trial or transition)
% Power data is calculated X sec before each event and Y sec after the event using a sliding window of a given duration and step-duration
%
% power_data{trial}(time x channels x frequencies)
% event_idx(itrial) = sample that corresponds to where the event happend in the power_data cell array for each trial
%

    clear

%% Example Parameters

    % Four Frequencies to vary between (btw 0-120Hz for this example)
    f1=1; %Hz
    f2=80; %Hz
    f3=20; %Hz
    f4=70; %Hz

    trial_durationS = 2; % event happens in the middle of the trial

%% Additional Required Parameters for my GetPowerOffline_*.m functions
    sample_rate = 1000; %Hz

    % How much time before and after the event do you want to look at (is NOT limited to looking into previous trials, but is limited to going into next trial)
    FeatureParms.pre_event_timeS = 1; % (in seconds) 
    FeatureParms.post_event_timeS = 1; % (in seconds) 

    % Analysis Window Parameters
    FeatureParms.window_lengthS = 0.2; % (in seconds) For FFT, automatically limited to nfft samples (e.g. FeatureParms.window_lengthS = FeatureParms.nfft/sampling_rate;)
    FeatureParms.feature_update_rateS = 0.1; % (in seconds) progress at X second shifts    
    FeatureParms.ideal_freqs = [0:120]; % (in Hz) Pick frequencies to output
    
    % --- Pick from MEM or FFT for Power Estimation ---
    
    % For MEM
        FeatureParms.power_method='MEM';
        FeatureParms.feature_resolution=1;
    
    % For FFT
    %     FeatureParms.power_method='FFT';
    %     FeatureParms.nfft = 256; % must be less than window_length
    %     FeatureParms.feature_resolution=sample_rate/FeatureParms.nfft; % resolution of the features in Hz (just multiply by freq bin # to get freq in Hz)

    % Automatic Feature Extraction Parameters (no need to adjust)
    FeatureParms.freq_bins = unique(round(FeatureParms.ideal_freqs/FeatureParms.feature_resolution)); % pick freq bins that are close to ideal
    FeatureParms.freq_bins=FeatureParms.freq_bins(FeatureParms.freq_bins>0); % can't be <=0
    FeatureParms.actual_freqs =FeatureParms.feature_resolution*FeatureParms.freq_bins; % what frequencies actually used
    FeatureParms.sample_rate = sample_rate;
    FeatureParms.window_length = floor(FeatureParms.window_lengthS*FeatureParms.sample_rate); % in samples
    FeatureParms.feature_update_rate=floor(FeatureParms.feature_update_rateS*FeatureParms.sample_rate); % in samples

    disp(['Feature window is ' num2str(FeatureParms.window_length/FeatureParms.sample_rate*1000) 'ms long and slides at ' num2str(1000*FeatureParms.feature_update_rate/FeatureParms.sample_rate) 'ms.'])
    disp(['Processing ' num2str(size(FeatureParms.actual_freqs,2)) ' ' FeatureParms.power_method ' frequency bins: ' num2str(FeatureParms.actual_freqs)])


%% Create the toy sine example
    t=[0:1/sample_rate:round((trial_durationS/2)*sample_rate)];
    y=[sin(2*pi*f1*t) sin(2*pi*f2*t) sin(2*pi*f3*t) sin(2*pi*f4*t)]; % 3 example transitions
    y=y+1*((rand(1,size(y,2))*2)-1); % add some noise (can I get a what-what?)
    event_idx_vec = [size(t,2) 2*size(t,2) 3*size(t,2)]; % vector of transition points

%% Calculate power for each trial
    [power_data,event_loc]=GetPowerOffline_TimeLockByTrial(y',event_idx_vec',FeatureParms);
    % power_data{trial}(time x channels x frequencies)

%% Plot spectrogram for each trial/transition

    for itrial = 1:3
        time_axis = ([0:size(power_data{itrial},1)-1]-event_loc(itrial))*FeatureParms.feature_update_rateS;
        event_locS = min(time_axis) + event_loc(itrial)*FeatureParms.feature_update_rateS;
        freq_axis = FeatureParms.actual_freqs;
        color_scale_mag=2.5;

        figure;
        hold all
        pcolor(time_axis,freq_axis,squeeze(power_data{itrial})');
        shading interp
        stem(event_locS,max(FeatureParms.actual_freqs),'.k','LineWidth',2)
        set(gca,'FontSize',12)
        xlabel('Time (s)');
        ylabel('Frequency (Hz)');
        ylim([min(FeatureParms.actual_freqs) max(FeatureParms.actual_freqs)])
        %colorbar;
%         caxis(color_scale_mag*[-1 1])

        title(['Trial # ' num2str(itrial)])
    end

%     % organize by trial (remove cell structure since it is not necessary for this example)
%     clear org_power_data
%     for itrial = [1 3]
%         org_power_data(:,:,:,itrial)=power_data{itrial}; % org_power_data(time x channel x freq x trial)
%     end
    
   
    
    
    