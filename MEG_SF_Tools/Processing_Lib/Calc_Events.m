function [Events,varargout] = Calc_Events(event_type,varargin)
% Defines events into AnalysisParms.
% This is a generic holder of event methods. Each method should be documented independently
%
% ===METHODS===
%
% Cue - UNTESTED
% Batch_Preprocessing_wDB - UNTESTED
% gui - UNTESTED
% gui_wprocessed_data - UNTESTED
% load_wfilename - UNTESTED
% load_wdb - UNTESTED
%
% ===HELP===
%     % Get TimeVecs.target_code
%     ExpDefs.paradigm_type =obj.run_type;
%     ExpDefs=Prep_ExpDefs(ExpDefs);
%     TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
%
% remove 255 crx on-off signals [2013-08-06]
% TimeVecs.target_code_org = remove_pport_trigger_from_CRX_startstop(TimeVecs.target_code_org); % 2013-07-03
%
% SEE: DB_MEG_Class.Calc_Event_Markers
%
% 2013-12-09 Foldes
% UPDATES:
%

switch lower(event_type)
    
    case {'cue'}
        % INPUTS:  cue_vec,cue_code
        % EXAMPLE: AnalysisParms.events = Calc_Events('cue',TimeVecs.target_code_org,move_cue_code);
        %
        % 2013-12-09 Foldes
        cue_vec     = varargin{1};
        cue_code    = varargin{2};
        
        trial_change_idx=TrialTransitions(cue_vec);
        trial_target_code = cue_vec(trial_change_idx);
        event_trial_num = find(trial_target_code==cue_code);
        Events = trial_change_idx(event_trial_num); % base samples
        
    case {'gui'}
        %
        % 2013-12-09 Foldes
        Extract         = varargin{1};
        TimeVecs        = varargin{2};
        rem_varargin    = varargin{3:end};
        
        [Events,TimeVecs]=QuickMEG_Events(Extract,TimeVecs,rem_varargin);
        varargout = TimeVecs;
        
    case {'gui_wprocessed_data'}
        % SEE: DB_MEG_Class.Calc_Event_Markers
        % processed_data
        % TimeVecs
        % event_name: 'photodiode','ACC','EMG','blink','cardiac'
        %
        % EXAMPLE: 
        %   Events = Calc_Events('gui_wprocessed_data',processed_data,TimeVecs,event_name);
        
        processed_data  = varargin{1};
        TimeVecs        = varargin{2};
        event_name      = varargin{3};
        
        % Parameters for event type
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
            %case {'ParallelPort' 'ArtifactFreeMove' 'ParallelPort_Move_Good','ArtifactFreeRest'}
                % nothing
        end

        event_data_str = [event_type '_data'];
        [Events.Original.(event_name),Events.Original.(['parms_' event_name])]= GUI_Auto_Event_Markers(processed_data.(event_data_str),TimeVecs.timeS,TimeVecs.target_code,event_type);        

        
    case {'load_wfilename'}
        %
        % 2013-12-09 Foldes
        full_file_name  = varargin{1};
        name_ending     = varargin{2};
        
        [file_path,file_name]=fileparts(full_file_name);
        file_base_name = strtok(file_name,'_');
        load([file_path filesep file_base_name name_ending]);
        
    case {'load_wdb'}
        %
        %
        % EXAMPLE: Events = Calc_Events('load_wDB',DB_entry,Extract.data_rate);
        % 2013-12-09 Foldes
        
        DB_entry    = varargin{1};
        sample_rate = varargin{2};
        
        events_loaded_flag = DB_entry.load_pointer('Preproc.Pointer_Events');
        if events_loaded_flag == -1 % its not really a flag, but it will work like this
            warning(['NO EVENTS FILE for ' DB_entry.entry_id])
        end
        % make sure there aren't bad segments being used
        Events = Calc_Event_Removal_wBadSegments(Events,sample_rate);
        
    case {'batch_preprocessing_wdb'}
        % SEE: Batch_Preprocessing_MEG.m
        % INPUT: DB_entry
        % EXAMPLE: Events = Calc_Events('Batch_Preprocessing_wDB',DB_entry);
        %
        % 2013-12-09 Foldes
        
        DB_entry = varargin{1};
        
        clear Events processed_data
        pointer_name = 'Preproc.Pointer_Events';
        
        processed_loaded_flag = DB_entry.load_pointer('Preproc.Pointer_processed_data_for_events');
        
        % Marking
        if (write_flag == 1) % Do Events (as long as you haven't given up at this point)
            h = msgbox_wPosition([0.55,1],['<--- ' DB_entry.run_intention ' ' DB_entry.subject],DB_entry.entry_id);
            pause(2);
            
            Events = DB_entry.Calc_Event_Markers('ParallelPort',TimeVecs,1);
            switch lower(DB_entry.run_intention)
                case {'imagine','observe'}
                    Events = DB_entry.Calc_Event_Markers('ArtifactFreeMove',TimeVecs,1);
                case {'attempt','imitate'}
                    Events = DB_entry.Calc_Event_Markers('ParallelPort_Move_Good',TimeVecs,1);
            end
            Events = DB_entry.Calc_Event_Markers('ArtifactFreeRest',TimeVecs,1);
            
            %             Events = DB_entry.Calc_Event_Markers('photodiode',TimeVecs,1);
            %             Events = DB_entry.Calc_Event_Markers('EMG',TimeVecs,1);
            %             Events = DB_entry.Calc_Event_Markers('ACC',TimeVecs,1);
            
            % ===Bad MEG Segments===
            if ~isfield(Events,'bad_segments')
                warning('Whoops, forgot to mark bad segments with Mark_Bad_MEG: Doing now')
                [~, ~, Events.bad_segments] = Mark_Bad_MEG(Extract);
            end
            Events = Calc_Event_Removal_wBadSegments(Events,TimeVecs.data_rate);
            
        end % marking
        
end


% Plot events in time
% figure;hold all
% plot(TimeVecs.timeS,TimeVecs.target_code_org')
% stem(TimeVecs.timeS(AnalysisParms.events_move),5*ones(1,length(AnalysisParms.events_move))','g.-')
% stem(TimeVecs.timeS(AnalysisParms.events_rest),5*ones(1,length(AnalysisParms.events_rest))','r.-')
% Figure_Stretch(4)
% ylim([-1 6])
% Figure_TightFrame
% legend({'Cue','MoveUsed','Rest Used'},'Location','SouthEast')









function [Events,TimeVecs]=QuickMEG_Events(Extract,TimeVecs,varargin)
% This is used in QuickMEG_* files as a code-saver where events are defined
% This is NOT well defined intentionally. See comments on each method
% varargin is a bunch of methods you want, like 'GUIMove','GUIRest'
%
% METHOD OPTIONS (varargin)
%   'GUIMove','GUIRest'
%
% 2013-12-06 Foldes
% UPDATES:
%

method_list = varargin;

for imethod = 1:length(method_list)
    
    method_option = method_list{imethod};
    
    switch method_option
        
        
        case {'GUIMove','GUIRest'}
            %% Manual marking MOVE events from Target-code, EMG and MISC channels
            % will try to load and save events
            %
            % ---INPUTS---
            % Extract.full_file_name
            % TimeVecs.target_code_org or TimeVecs.target_code
            %
            % ---OUTPUTS---
            % Events
            %   .events_rest
            %   .events_move.
            %
            % TimeVecs
            %   .EMG_data
            %   .MISC_data
            %   .target_code
            %
            % 2013-12-06 Foldes
            
            Events = [];
            
            % name of event
            switch method_option
                case {'GUIMove'}
                    event_name = 'events_move';
                case {'GUIRest'}
                    event_name = 'events_rest';
            end
            
            % Try to load events from Events_Temp file
            [Extract.file_path,Extract.file_name]=fileparts(Extract.full_file_name);
            try
                load([Extract.file_path filesep 'Events_Temp_' Extract.file_name]);
            end
            
            % initalize
            if ~isfield(Events,event_name)
                eval(['Events.' event_name ' = [];']);
            end
            
            
            % Load extra signals (if not already loaded)
            if ~isfield(TimeVecs,'target_code')
                TimeVecs.target_code = remove_pport_trigger_from_CRX_startstop(TimeVecs.target_code_org);
            end
            if ~isfield(TimeVecs,'EMG_data')
                [TimeVecs.EMG_data] =  Load_from_FIF(Extract,'EMG');
            end
            if ~isfield(TimeVecs,'MISC_data')
                [TimeVecs.MISC_data] =  Load_from_FIF(Extract,'MISC');
            end
            
            signal_name_list = {'Cue Code','EMG','EMG','MISC','MISC','MISC'};
            signal4eventpicking=[TimeVecs.target_code TimeVecs.EMG_data TimeVecs.MISC_data];
            
            [Marks,save_flag]=Plot_Inspect_TimeSeries_Signals(TimeVecs.timeS,signal4eventpicking,...
                'premarked_events',Events.(event_name),...
                'signal_name_list',signal_name_list,'plot_title',['Select Onset of ' event_name ' (push #1 key)']);
            try
                Events.(event_name) = cell2mat(Marks.events_idx);
            end
            
            save([Extract.file_path filesep 'Events_Temp_' Extract.file_name],'Events');
            
    end % method options
    
end % all methods