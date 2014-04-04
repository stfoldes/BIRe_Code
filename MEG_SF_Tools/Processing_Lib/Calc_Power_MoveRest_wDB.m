function Power = Calc_Power_MoveRest_wDB(DB_entry,AnalysisParms,Plot_Flags)
% From DB_entry info, process to Power (time locked).
% Loads MEG, SSP, Events, TimeLocked Power
% Needs AnalysisParms and DB_entry (DB_MEG_Class)
%
% Plot_Flags struct can be used to to inspect the data (be careful in loops)
% Flags can actually be figure handles
%
%   Plot_Flags.Events = true:           Time-plot of when events happen and STI101
%   Plot_Flags.PSD = true:              PSD/moddepth for all left-sensorimotor sensors vs. all
%                                       sensors. Defaults mod depth is T-value
%   Plot_Flags.PSD_Interactive = true:  Select freq band from PSD to compute Topos, Requires .PSD 
%   Plot_Flags.Topo = true:             Topography plot for beta and gamma, combines gradiometers
%
%         %---Analysis Parameters (AnalysisParms.)---
%         AnalysisParms.file_type =      'tsss'; % What type of data
%         AnalysisParms.SSP_Flag =  0;
%         switch lower(DB_entry.run_intention)
%             case {'imitate' 'attempt'}
%                 AnalysisParms.event_name_move = 'ParallelPort_Move_Good';
%             case {'observe' 'imagine'}
%                 AnalysisParms.event_name_move = 'ArtifactFreeMove';
%         end
%         % Window-timing Parameters
%         AnalysisParms.window_lengthS_move = 1; % 1s to help with rx variablity
%         AnalysisParms.rx_timeS_move =       0.1;    % 2013-10-11: 100ms b/c of parallel-port/video offset
%         % 1/2s should be for center at 500ms post parallel port 2013-08-23
%         AnalysisParms.num_reps_per_block =  4; % Only use the first 4 reps per block
%
%         AnalysisParms.event_name_rest =     'ArtifactFreeRest';
%         AnalysisParms.window_lengthS_rest = 3; % window is centered (this IS the WindowS from auto-event-parms)
%         AnalysisParms.rx_timeS_rest =       0; % shift window (this is NOT the rx_time from auto-event-parms, this should be 0)
%         %-------------------------------
%
%
% 2013-06-08 Foldes [Branched]
% 2014-03-17 Foldes: Working
% 2014-03-25 Foldes: Plot_Flags can be figure handles


% Check for Events first
if DB_entry.pointer_check('Preproc.Pointer_Events') == 0
    error(['No events exist for ' DB_entry.entry_id])
end

if ~exist('Plot_Flags')
    Plot_Flags = [];
end

%% ---Extraction Parameters-------------
Extract.file_type =         AnalysisParms.file_type; % What type of data
Extract.channel_list =      sort([1:3:306 2:3:306]); % only gradiometers
Extract.filter_stop =       [59 61];
Extract.filter_bandpas =    [2 200];
Extract.file_path =         DB_entry.file_path('local');
Extract =                   DB_entry.Prep_Extract(Extract);
% Copy local (can be used to copy all that match criteria)
DB_entry.download(Extract.file_name_ending);
%----------------------------------------

%% Load MEG data

[MEG_data,~,~,Extract] = Load_from_FIF(Extract,'MEG');
TimeVecs.data_rate = Extract.data_rate;
[TimeVecs.target_code_org,TimeVecs.timeS] = Load_from_FIF(Extract,'STI');

%% Load SSP (from server)

if AnalysisParms.SSP_Flag ==1
    % THIS IS NOT UPTODATE [2014-03-13] ***BUG***
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

%% Define Events

% Load Events (from server)
Events = Calc_Events('load_wDB',DB_entry,Extract.data_rate);

% Calc Move Power *AROUND* movement onset (with rx time adjustment); pick first X per block
new_move_events = Calc_Event_Reps_PerBlock(Events.(AnalysisParms.event_name_move),Events.Original.ParallelPort_BlockStart,AnalysisParms.num_reps_per_block);
% add in RX time to each event
AnalysisParms.events_move = new_move_events+floor(AnalysisParms.rx_timeS_move*Extract.data_rate);

% Calc Rest Power *AROUND* cue
% add in RX time to each event
AnalysisParms.events_rest = Events.(AnalysisParms.event_name_rest)+floor(AnalysisParms.rx_timeS_rest*Extract.data_rate);

if isfield(Plot_Flags,'Events') && (Plot_Flags.Events ~= 0)
    % Plot events in time
    if ishandle(Plot_Flags.Events)
        figure(Plot_Flags.Events);
    else
        figure;
    end
    hold all
    plot(TimeVecs.timeS,TimeVecs.target_code_org')
    stem(TimeVecs.timeS(AnalysisParms.events_move),5*ones(1,length(AnalysisParms.events_move))','g.-')
    stem(TimeVecs.timeS(AnalysisParms.events_rest),5*ones(1,length(AnalysisParms.events_rest))','r.-')
    Figure_Stretch(4)
    ylim([-1 6])
    Figure_TightFrame
    legend({'Cue','MoveUsed','Rest Used'},'Location','SouthEast')
end

%% Calc Power

%---Feature Parameters (FeatureParms.)---
FeatureParms = FeatureParms_Class;
% Can be empty for loading feature data from CRX files
FeatureParms.feature_method =       'burg';
FeatureParms.order =                30; % changed 2013-07-12 Foldes
FeatureParms.feature_resolution =   1;
FeatureParms.ideal_freqs =          [0:120]; % Pick freq or bins
FeatureParms.sample_rate =          Extract.data_rate;
%-------------------------------

% Calc Rest Power
FeatureParms.window_lengthS =   AnalysisParms.window_lengthS_rest;
FeatureParms.window_length =    floor(FeatureParms.window_lengthS*Extract.data_rate);
[feature_data_rest,FeatureParms] = Calc_PSD_TimeLocked(MEG_data_clean,AnalysisParms.events_rest,FeatureParms);

% Calc Move Move
FeatureParms.window_lengthS =   AnalysisParms.window_lengthS_move;
FeatureParms.window_length =    floor(FeatureParms.window_lengthS*Extract.data_rate);
[feature_data_move,FeatureParms] = Calc_PSD_TimeLocked(MEG_data_clean,AnalysisParms.events_move,FeatureParms);


%% Save

Power.feature_data_move = feature_data_move;
Power.feature_data_rest = feature_data_rest;
Power.Extract =           Extract;
Power.FeatureParms =      FeatureParms;
Power.AnalysisParms =     AnalysisParms;

%% ===PLOTTING===

%PLOT: PSD for an ROI
if isfield(Plot_Flags,'PSD') && (Plot_Flags.PSD ~= 0)    
    ROI_name = 'sensorimotor_left_hemi';
    eval(['ROI_idx = sensors2chanidx([Power.Extract.channel_list],[DEF_MEG_sensors_' ROI_name ']);'])
    moddepth = Calc_ModDepth(Power.feature_data_move,Power.feature_data_rest,'t');
    
    if ishandle(Plot_Flags.PSD)
        fig_psd = Plot_Flags.PSD;
    else
        fig_psd = figure;
    end
    figure(fig_psd);hold all
    Figure_Stretch(2,1)
    % Left Sensorimotor
    Plot_Variance_as_Patch(Power.FeatureParms.actual_freqs,squeeze(mean(moddepth,1))',...
        'variance_method',[.05 .95],'patch_color','k','patch_alpha',0.6,'fig',fig_psd); % STD across all sensor groups
    plot(Power.FeatureParms.actual_freqs,squeeze(mean(moddepth(:,ROI_idx,:),1))',...
        'g','LineWidth',2)
    clear text_input
    text_input{1} = [ROI_name ' (' num2str(length(ROI_idx)) ' sensors)'];
    text_input{end+1} = ['MOVE: ' num2str(length(Power.AnalysisParms.events_move)) 'Events , ' num2str(Power.AnalysisParms.window_lengthS_move) 's window'];
    text_input{end+1} = ['REST: ' num2str(length(Power.AnalysisParms.events_rest)) 'Events , ' num2str(Power.AnalysisParms.window_lengthS_rest) 's window'];
    text_input{end+1} = ['Order: ' num2str(Power.FeatureParms.order)];
    Figure_Annotate(text_input)
    title(str4plot(Power.Extract.full_file_name))
    xlabel('Freq [Hz]')
    ylabel('Modulation [T]')
    
    % PLOT: Interactive Topography by freq band
    if isfield(Plot_Flags,'PSD_Interactive') && (Plot_Flags.PSD_Interactive == 1)
        GUI_Inspect_ModDepth_wTopography(fig_psd,Power.feature_data_move,Power.feature_data_rest,Power.Extract.channel_list,Power.FeatureParms,'p_thres',0.1);
    end
end % Plot PSD

% PLOT: Topography for freq bands (combines gradiometers
if isfield(Plot_Flags,'Topo') && (Plot_Flags.Topo ~= 0)
    freq_names_4grouping = {'beta','gamma'};
    
    % make list of freqs
    freq_idx_4grouping=[];
    for ifreq = 1:size(freq_names_4grouping,2)
        freq_idx_4grouping=[freq_idx_4grouping; ...
            find_closest_range_idx(DEF_freq_bands(freq_names_4grouping{ifreq}),Power.FeatureParms.actual_freqs)]; % do that find_closet stuff to get the valid indicies (what if you don't have 1Hz res?)
    end
    
    moddepth = Calc_ModDepth(Power.feature_data_move,Power.feature_data_rest,'t');
    [moddepth_by_location_freqband,sensor_group_list] = Calc_ModDepth_Combine_by_Location(moddepth,freq_idx_4grouping,Power.Extract.channel_list);
    
    if ishandle(Plot_Flags.Topo)
        fig = Plot_Flags.Topo;
    else
        fig = figure;
    end
    figure(fig);hold all

    for ifreq = 1:size(freq_idx_4grouping,1)
        subplot(1,size(freq_idx_4grouping,1),ifreq);hold all
        Plot_MEG_head_plot([1:3:306],moddepth_by_location_freqband(:,ifreq),'fig',fig);
        Plot_MEG_chan_locations(DEF_MEG_sensors_sensorimotor_left_hemi,'MarkerType',1,'Color','k'); % 2013-08-13
        caxis_center;colorbar
        title(freq_names_4grouping{ifreq})
    end
    Figure_Stretch(2,2)
    title_figure([DB_entry.subject])
    
end


%
%         % Save processed data to file & write to DB entry
%         [DB_entry,saved_pointer_flag] = DB_entry.save_pointer(Power,save_pointer_name,'mat',overwrite_flag);
%         % Save current DB entry back to database
%         if saved_pointer_flag==1
%             DB=DB.update_entry(DB_entry);
%         end
%
%     catch
%         disp('***********************************')
%         disp('*********** FAIL ******************')
%         disp('***********************************')
%         fail_list{end+1} = DB_entry.entry_id;
%     end
% end
%
% % Save database out to file
% if saved_pointer_flag==1
%     DB.save_DB;
% end
