% Calculate delay between photodiode and triggers (via STI)
% Uses a user interface to help mark photodiode events
% Auto-marks STI-triggers (must provide STI values that are inteneded to match the photodiode)
%
% Requires tools from Stephen (sorry)
% 
% 2013-10-10 Foldes
% UPDATES:
% 
Calc_Filter_Freq_SimpleButter
Figure_Annotate
GUI_Auto_Event_Markers
Load_from_FIF
Plot_Inspect_TimeSeries_Signals
TrialTransitions
round_sig
varargin_extraction

clear

%% PARAMETERS

% File name and path
Extract.full_file_name = '/home/foldes/Data/MEG/Test/TEST_movementcue_timing_w_photodiode.fif';
% Extract.full_file_name = '/home/foldes/Data/MEG//NS10/S01/ns10s01r13.fif';
% Sampling rate
Extract.base_sample_rate=1000;

% MISC channel =-for the photodiode
photodiode_chan_name='MISC007';
% List of parallel port codes that should have photodiode events associated with it
parallel_port_codes = {4 2}; % a cell array will do an OR between different codes

%% LOAD

% Get MISC channel
[MISC_data,timeS,MISC_chan_list] = Load_from_FIF(Extract,'MISC');
for ichan =1:size(MISC_chan_list,1)
    chan_match(ichan)=strcmpi(MISC_chan_list(ichan,:),photodiode_chan_name);
end
photodiode_chan = find(chan_match==1);

% LP filter noise
photodiode_data=Calc_Filter_Freq_SimpleButter(MISC_data(:,photodiode_chan),60,Extract.base_sample_rate);

% Get STI (i.e. parallel port)
[STI_data] = Load_from_FIF(Extract,'STI');

% ===PUT OPTIONAL STI PROCESSING CODE HERE===
% Remove pport on/off signals
% STI_data = remove_pport_trigger_from_CRX_startstop(STI_data);

% % Check out the data
% Plot_Inspect_TimeSeries_Signals(timeS,[STI_data MISC_data])

%%  MAKE EVENTS

% Auto detect photodiode changes
[Events.photodiode,Events.photodiode_parms]= GUI_Auto_Event_Markers(photodiode_data,timeS,STI_data);

% Mark parallel port transitions
trial_start_idx = TrialTransitions(STI_data);
% Get trial indicies that are one of the parallel_port_codes (OR)
trials_match = zeros(size(trial_start_idx));
for icode = 1:length(parallel_port_codes)
    trials_match = [trials_match | STI_data(trial_start_idx)==parallel_port_codes{icode}];
end
Events.ParallelPort = trial_start_idx(trials_match==1)';

% Edit Events
org_events{1} = Events.photodiode;
org_events{2} = Events.ParallelPort;
[Marks,save_flag]=Plot_Inspect_TimeSeries_Signals(timeS,[STI_data photodiode_data],'premarked_events',org_events);
Events.photodiode = Marks.events_idx{1};
Events.ParallelPort = Marks.events_idx{2};

%% CALCULATE DELAY
% assumes each photodiode trigger has a corresponding parallelport trigger

clear closest_cue delay_list
for ievent = 1:length(Events.photodiode)
    % find the closest parallel port trigger
    closest_cue(ievent) = Events.ParallelPort(find(Events.ParallelPort<Events.photodiode(ievent),1,'last'));
    % delay = photodiode - parallel port
    delay_list(ievent) = (timeS(Events.photodiode(ievent)) - timeS(closest_cue(ievent)));
end

%% PLOT
figure
boxplot(delay_list)
ylabel('Presentation Delay [S]')
text_str = {['Mean: ' num2str(round_sig(mean(delay_list),-3)) char(177) num2str(round_sig(std(delay_list),-3)) 'S'],...
    ['Num of events: ' num2str(length(delay_list))]};
Figure_Annotate(text_str,'Location','NorthWest')






