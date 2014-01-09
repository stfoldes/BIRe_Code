% Most basic loading of data
% Quickly plot some raw data, the target code, histogram of trial-target code counts, and histogram of trial durations
% Stephen Foldes (2012-02-07)

Extract.file_name{1}='BMI01s01r011.fif';
Extract.file_path='C:\Data\MEG\BMI01\20111130\';
Extract.chan2use = 1; % Channels to extract (e.g. [1:1:306], DEF_best_left_hemi_sma_MEG_sensors)
Extract.decimation_factor=1; % "down sampling" if desired (else =1)
Extract.base_sample_rate=1000;
Extract.sample_rate = Extract.base_sample_rate/Extract.decimation_factor;

% Get the data
target_code=Load_from_FIF(Extract,'STI');
raw_data=Load_from_FIF(Extract,'MEG');
timeS=[0:size(target_code,1)-1]*(1/Extract.sample_rate);

% Plot the first channel
figure;hold all
plot(timeS,zscore(raw_data(:,1)),'k')
plot(timeS,target_code,'r','LineWidth',2)
ylim([-4 4])
xlabel('Time [S]');ylabel('zscore(raw data)')

trial_change_idx =TrialTransitions(target_code);
target_code_by_trial = target_code(trial_change_idx(1:end-1));
target_code_by_trial(target_code_by_trial==255)=[]; %remove 255 
% STI_data = remove_pport_trigger_from_CRX_startstop(TimeVecs.target_code_org); % 2013-07-03


figure;hist(target_code_by_trial,length(unique(target_code_by_trial)))
ylabel('Number of Trials');xlabel('Target Code')
title('Histogram of Trial-Target Codes')

figure;hist(diff(trial_change_idx)*(1/Extract.sample_rate))
ylabel('Number of Trials');xlabel('Trial Duration [S]')
title('Histogram of Trial Durations')

disp(['Total Run Time = ' num2str(max(timeS)/60) ' minutes'])