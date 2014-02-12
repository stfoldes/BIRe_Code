% Calculate power and save at ResultPointers.Power_tsss_trans_Cue
% 2013-06-08 Foldes [Branched]
% UPDATES:
% 2013-10-11 Foldes: Metadata-->DB
% 2013-10-24 Foldes: Results --> Power

clearvars -except DB
% close all
overwrite_flag=1;
saved_pointer_flag = 1;

save_pointer_name = 'ResultPointers.Power_tsss_trans_Cue_burg';
Extract.file_type='tsss_trans'; % What type of data?

% Choose criteria for data set to analyize
clear criteria
criteria.subject = 'NC01';
criteria.run_type = 'Open_Loop_MEG';
criteria.run_task_side = 'Right';
criteria.run_action = 'Grasp';
criteria.run_intention = 'Attempt';


%% Load Database

% Build database
if ~exist('DB','var')
    DB=DB_MEG_Class;
    DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

% Chooses the approprate entries
DB_short = DB.get_entry(criteria);



% function DEFAULT_MEG(in_struct_name)
% switch lower(in_struct_name)
%     case Extract
%           out_struct.file_path = [];
%           out_struct.channel=sort([1:3:306 2:3:306]); % only gradiometers

% put FeatureParms in Analysis
% Put everything in AnalysisParms? you want all that info together, and its easier to pass
% funtion here(DB_short,AnalysisParms,FeatureParms,'Extract',Extract)

% if DB not object, then it is likely just a file name, split it, make a small DB
    
%% Loop for All Entries
fail_list{1} = [];
for ientry = 1:length(DB_short)
    
    DB_entry = DB_short(ientry);
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(DB_short)) ' | ' DB_entry.entry_id '================='])
    
    try
        
        %% Preparing Data Set Info and Analysis-related Parameters
        %---Extraction Info-------------
        Extract.file_path = DB_entry.file_path('local');
%         Extract.data_rate = 1000;
        Extract.channel_list=sort([1:3:306 2:3:306]); % only gradiometers
        Extract.filter_stop=[59 61];
        Extract.filter_bandpas=[2 200];
        Extract = DB_entry.Prep_Extract(Extract);
        % Copy local (can be used to copy all that match criteria)
        DB_entry.download(Extract.file_name_ending);
        %-------------------------------
        
        %---Feature Parameters (FeatureParms.)---
        FeatureParms = FeatureParms_Class;
        % Can be empty for loading feature data from CRX files
        FeatureParms.feature_method = 'burg';
        FeatureParms.order = 30; % changed 2013-07-12 Foldes
        FeatureParms.feature_resolution = 1;
        FeatureParms.ideal_freqs = [0:120]; % Pick freq or bins
        FeatureParms.sample_rate = Extract.data_rate;
        %-------------------------------
        
        %---Analysis Parameters (AnalysisParms.)---
        AnalysisParms.SSP_Flag = 0;
        switch lower(DB_entry.run_intention)
            case {'imitate' 'attempt'}
                AnalysisParms.event_name_move = 'ParallelPort_Move_Good';
            case {'observe' 'imagine'}
                AnalysisParms.event_name_move = 'ArtifactFreeMove';
        end
        % Window-timing Parameters
        AnalysisParms.window_lengthS_move = 1; % 1s to help with rx variablity
        AnalysisParms.rx_timeS_move=0.1;    % 2013-10-11: 100ms b/c of parallel-port/video offset
        % 1/2s should be for center at 500ms post parallel port 2013-08-23
        AnalysisParms.num_reps_per_block = 4; % Only use the first 4 reps per block
        
        AnalysisParms.event_name_rest = 'ArtifactFreeRest';
        AnalysisParms.window_lengthS_rest = 3; % window is centered (this IS the WindowS from auto-event-parms)
        AnalysisParms.rx_timeS_rest = 0; % shift window (this is NOT the rx_time from auto-event-parms, this should be 0)
        %-------------------------------
        
        %% ----------------------------------------------------------------
        %  -----------------CODE STARTS------------------------------------
        %  ----------------------------------------------------------------
        
        
%         [Power,Extract,FeatureParms,AnalysisParms]=Calc_Power_MoveRest(DB_entry,Extract,FeatureParms,AnalysisParms);
    


        %% Load MEG data
        
        [MEG_data] =  Load_from_FIF(Extract,'MEG');
        TimeVecs.data_rate = Extract.data_rate;
        [TimeVecs.target_code_org,TimeVecs.timeS] = Load_from_FIF(Extract,'STI');
        
        %     % Inspect event times
        %     figure;hold all
        %     plot(TimeVecs.timeS,TimeVecs.target_code_org')
        %     stem(TimeVecs.timeS(AnalysisParms.events_move),5*ones(1,length(AnalysisParms.events_move))','g.-')
        %     stem(TimeVecs.timeS(AnalysisParms.events_rest),5*ones(1,length(AnalysisParms.events_rest))','r.-')
        %     Figure_Stretch(2)       

        %% Load SSP (from server)
        
        if AnalysisParms.SSP_Flag ==1
            ssp_file = [DB_entry.file_path(server_path) filesep DB_entry.entry_id '_SSP_' Extract.file_type];
            % try to load if possible, or calculate
            if exist(ssp_file)==2
                load(ssp_file);
            end
            
            clear MEG_data_clean % 2013-06-26 Foldes
            % Apply
            ssp_projector = Calc_SSP_Filters(ssp_components);
            MEG_data_clean = (ssp_projector*MEG_data')';
            clear MEG_data
        else
            MEG_data_clean = MEG_data;
            clear MEG_data
        end

        %% Load Events (from server)
        
        % REPLACE W/ Calc_Events 2013-12-09
        Events = Calc_Events('load_wDB',DB_entry,Extract.data_rate);
%         events_loaded_flag = DB_entry.load_pointer('Preproc.Pointer_Events');
%         if events_loaded_flag == -1 % its not really a flag, but it will work like this
%             warning(['NO EVENTS FILE for ' DB_entry.entry_id])
%         end
%         % make sure there aren't bad segments being used
%         Events = Calc_Event_Removal_wBadSegments(Events,Extract.data_rate);
        
        %         event_file = [DB_entry.file_path('server') filesep DB_entry.Preproc.Pointer_Events];
        %         % if the file doesn't exist, OR its older than 2013-08-01, then yell!
        %         if exist(event_file)~=2
        %             warning([event_file ' does not exist'])
        %         elseif date_subtraction(datestr('2013-08-01'),date_file_timestamp(event_file))<0
        %             warning([event_file ' is too old'])
        %         else
        %             load(event_file);
        %             % Just make sure there aren't bad segments being used
        %             Events = Calc_Event_Removal_wBadSegments(Events,Extract.data_rate);
        %         end
        
        %% Define Events
        
        % Calc Move Power *AROUND* movement onset (with rx time adjustment); pick first X per block
        new_move_events=Calc_Event_Reps_PerBlock(Events.(AnalysisParms.event_name_move),Events.Original.ParallelPort_BlockStart,AnalysisParms.num_reps_per_block);
        % add in RX time to each event
        AnalysisParms.events_move = new_move_events+floor(AnalysisParms.rx_timeS_move*Extract.data_rate);
                
        % Calc Rest Power *AROUND* cue      
        % add in RX time to each event
        AnalysisParms.events_rest = Events.(AnalysisParms.event_name_rest)+floor(AnalysisParms.rx_timeS_rest*Extract.data_rate);
        
        % Plot events in time
        % figure;hold all
        % plot(TimeVecs.timeS,TimeVecs.target_code_org')
        % stem(TimeVecs.timeS(AnalysisParms.events_move),5*ones(1,length(AnalysisParms.events_move))','g.-')
        % stem(TimeVecs.timeS(AnalysisParms.events_rest),5*ones(1,length(AnalysisParms.events_rest))','r.-')
        % Figure_Stretch(4)
        % ylim([-1 6])
        % Figure_TightFrame
        % legend({'Cue','MoveUsed','Rest Used'},'Location','SouthEast')


        
        %% Calc Power
       
        % Calc Rest Power
        FeatureParms.window_lengthS = AnalysisParms.window_lengthS_rest;
        FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
        [feature_data_rest,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,AnalysisParms.events_rest,FeatureParms);
        
        % Calc Move Move
        FeatureParms.window_lengthS=AnalysisParms.window_lengthS_move;
        FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
        [feature_data_move,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,AnalysisParms.events_move,FeatureParms);
        
