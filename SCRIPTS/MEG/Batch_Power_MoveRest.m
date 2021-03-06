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
        Extract.data_rate = 1000;
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
        
        %% Calc Power
       
        % Calc Rest Power
        FeatureParms.window_lengthS = AnalysisParms.window_lengthS_rest;
        FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
        [feature_data_rest,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,AnalysisParms.events_rest,FeatureParms);
        
        % Calc Move Move
        FeatureParms.window_lengthS=AnalysisParms.window_lengthS_move;
        FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
        [feature_data_move,FeatureParms]=Calc_PSD_TimeLocked(MEG_data_clean,AnalysisParms.events_move,FeatureParms);
        
        
        %% PLOT: PSD for an ROI
        ROI_name = 'sensorimotor_left_hemi';
        eval(['ROI_idx = sensors2chanidx([Extract.channel_list],[DEF_MEG_sensors_' ROI_name ']);'])
        data4psd = Calc_ModDepth(feature_data_move,feature_data_rest,'T');
        
        fig_psd = figure;hold all
        Figure_Stretch(2,1)
        % Left Sensorimotor
        Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(data4psd,1))',...
            'variance_method',[.05 .95],'patch_color','k','patch_alpha',0.6,'fig',fig_psd); % STD across all sensor groups
        plot(FeatureParms.actual_freqs,squeeze(mean(data4psd(:,ROI_idx,:),1))',...
            'g','LineWidth',2)
        clear text_input
        text_input{1} = [ROI_name ' (' num2str(length(ROI_idx)) ' sensors)'];
        text_input{end+1} = ['MOVE: ' num2str(length(AnalysisParms.events_move)) 'Events , ' num2str(AnalysisParms.window_lengthS_move) 's window'];
        text_input{end+1} = ['REST: ' num2str(length(AnalysisParms.events_rest)) 'Events , ' num2str(AnalysisParms.window_lengthS_rest) 's window'];
        text_input{end+1} = ['Order: ' num2str(FeatureParms.order)];
        Figure_Annotate(text_input)
        title(str4plot(Extract.full_file_name))
        xlabel('Freq [Hz]')
        ylabel('Modulation [T]')
        
        % PLOT: Interactive Topography by freq band
        %GUI_Inspect_ModDepth_wTopography(fig_psd,feature_data_move,feature_data_rest,Extract.channel_list,FeatureParms,'p_thres',0.1);
        
        % PLOT: Topography for freq bands
        AnalysisParms.freq_names_4grouping = {'beta','gamma'};
        
        % make list of freqs
        AnalysisParms.freq_idx_4grouping=[];
        for ifreq = 1:size(AnalysisParms.freq_names_4grouping,2)
            AnalysisParms.freq_idx_4grouping=[AnalysisParms.freq_idx_4grouping; ...
                find_closest_range_idx(DEF_freq_bands(AnalysisParms.freq_names_4grouping{ifreq}),FeatureParms.actual_freqs)]; % do that find_closet stuff to get the valid indicies (what if you don't have 1Hz res?)
        end
        
        moddepth = Calc_ModDepth(feature_data_move,feature_data_rest,'t');
        [moddepth_by_location_freqband,sensor_group_list] = Calc_ModDepth_Combine_by_Location(moddepth,AnalysisParms.freq_idx_4grouping,Extract.channel_list);
        
        fig=figure;
        for ifreq = 1:size(AnalysisParms.freq_idx_4grouping,1)
            subplot(1,size(AnalysisParms.freq_idx_4grouping,1),ifreq);hold all
            Plot_MEG_head_plot([1:3:306],moddepth_by_location_freqband(:,ifreq),'fig',fig);
            Plot_MEG_chan_locations(DEF_MEG_sensors_sensorimotor_left_hemi,'MarkerType',1,'Color','k'); % 2013-08-13
            caxis_center;colorbar
            title(AnalysisParms.freq_names_4grouping{ifreq})
        end
        Figure_Stretch(2,2)
        title_figure([DB_entry.subject])
        
        %% Save
        
        Power.feature_data_move = feature_data_move;
        Power.feature_data_rest = feature_data_rest;
        Power.Extract =           Extract;
        Power.FeatureParms =      FeatureParms;
        Power.AnalysisParms =     AnalysisParms;
        
        % Save processed data to file & write to DB entry
        [DB_entry,saved_pointer_flag] = DB_entry.save_pointer(Power,save_pointer_name,'mat',overwrite_flag);
        % Save current DB entry back to database
        if saved_pointer_flag==1
            DB=DB.update_entry(DB_entry);
        end
        
    catch
        disp('***********************************')
        disp('*********** FAIL ******************')
        disp('***********************************')
        fail_list{end+1} = DB_entry.entry_id;
    end
end

% Save database out to file
if saved_pointer_flag==1
    DB.save_DB;
end
