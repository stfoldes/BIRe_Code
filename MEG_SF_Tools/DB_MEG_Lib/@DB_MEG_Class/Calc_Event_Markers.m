function Events = Calc_Event_Markers(obj,event_name,TimeVecs,overwrite_flag)
% Calculates the events for a given event type
% current options: photodiode, ACC, EMG, blink, cadiac
% Saves the pointer back out
%
% 2013-10-07 Foldes
% UPDATES
%

if ~exist('overwrite_flag') || isempty(overwrite_flag)
    overwrite_flag = 0;
end

% Load processed_data
obj.load_pointer('Preproc.Pointer_processed_data_for_events');

% Extract TimeVecs (if needed)
if ~exist('TimeVecs') || isempty(TimeVecs)
    clear Extract
    Extract.file_name        = obj.entry_id;
    Extract.file_path        = obj.file_path('local');
    Extract.base_sample_rate =1000;
    
    % Load data
    clear TimeVecs
    TimeVecs.data_rate = Extract.base_sample_rate;
    [TimeVecs.target_code_org,TimeVecs.timeS] = Load_from_FIF(Extract,'STI');
end
% Get TimeVecs.target_code
ExpDefs.paradigm_type =obj.run_type;
ExpDefs=Prep_ExpDefs(ExpDefs);
TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);

% Load Events (just so you dont over write)
obj.load_pointer('Preproc.Pointer_Events');


%% Parameters for event type
switch event_name
    case 'photodiode'
        event_type = 'MISC';
    case 'ACC'
        event_type = event_name;
    case 'EMG'
        event_type = event_name;
    case 'blink'
        event_type = event_name;
    case 'cardiac'
        event_type = event_name;
    case {'ParallelPort' 'ArtifactFreeMove' 'ParallelPort_Move_Good','ArtifactFreeRest'}
        % nothing
end

%%
h1 = msgbox_wPosition([0.55,0.8],['<--- ' event_name],obj.run_info);
switch event_name
    case {'photodiode','ACC','EMG','blink','cardiac'}
        event_data_str = [event_type '_data'];
        [Events.Original.(event_name),Events.Original.(['parms_' event_name])]= GUI_Auto_Event_Markers(processed_data.(event_data_str),TimeVecs.timeS,TimeVecs.target_code,event_type);        
        
    case 'ParallelPort'
        % go through each rest period and try to mark good times
        trial_start_idx = TrialTransitions(TimeVecs.target_code); % indicies in the 'raw' data (i.e. time series) where target_code changes happen (i.e. trial starting points)
        Events.Original.ParallelPort_Rest = trial_start_idx(TimeVecs.target_code(trial_start_idx)==ExpDefs.target_code.rest)';
        Events.Original.ParallelPort_BlockStart = trial_start_idx(TimeVecs.target_code(trial_start_idx)==ExpDefs.target_code.block_start)';
        Events.Original.ParallelPort_Move = trial_start_idx(TimeVecs.target_code(trial_start_idx)==ExpDefs.target_code.move)';
        
    case 'ArtifactFreeMove'
        [Events.Original.(event_name),Events.Original.(['parms_' event_name])] = GUI_Auto_Remove_Events_wArtifacts([processed_data.EMG_data processed_data.ACC_data],TimeVecs,TrialTransitions(TimeVecs.target_code,ExpDefs.target_code.move),'move');
       
    case 'ParallelPort_Move_Good'
        [~,Events.Original.(event_name)]= GUI_Edit_Event_Markers([TimeVecs.target_code processed_data.EMG_data processed_data.ACC_data],TimeVecs.timeS,Events.Original.ParallelPort_Move,event_name);
    
    case 'ArtifactFreeRest'
        [Events.Original.(event_name),Events.Original.(['parms_' event_name])] = GUI_Auto_Generate_ArtifactFree_Events([processed_data.EMG_data processed_data.ACC_data],TimeVecs,ExpDefs,'rest');

end
close(h1);

%% Save
obj.save_pointer(Events,'Preproc.Pointer_Events','mat',overwrite_flag);







