% Calculate power and save at ResultPointers.Power_tsss_trans_Cue
% 2013-06-08 Foldes [2013-11-22 Branched]
% UPDATES:
% 
IN PROGRESS
function [Power,Extract,FeatureParms,AnalysisParms]=Calc_Power_MoveRest(MEG_data,Events,Extract,FeatureParms,AnalysisParms)


%% Define Events

% Calc Move Power *AROUND* movement onset (with rx time adjustment); pick first X per block
new_move_events=Calc_Event_Reps_PerBlock(Events.(AnalysisParms.event_name_move),Events.Original.ParallelPort_BlockStart,AnalysisParms.num_reps_per_block);
% add in RX time to each event
AnalysisParms.events_move = new_move_events+floor(AnalysisParms.rx_timeS_move*Extract.data_rate);

% Calc Rest Power *AROUND* cue
% add in RX time to each event
AnalysisParms.events_rest = Events.(AnalysisParms.event_name_rest)+floor(AnalysisParms.rx_timeS_rest*Extract.data_rate);

%% Calc Power
% disp(length(Events.(event_name_move)))
% disp(length(Events.(event_name_rest)))

% Calc Rest Power
FeatureParms.window_lengthS = AnalysisParms.window_lengthS_rest;
FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
[feature_data_rest,FeatureParms]=Calc_PSD_TimeLocked(MEG_data,AnalysisParms.events_rest,FeatureParms);

% Calc Move Move
FeatureParms.window_lengthS=AnalysisParms.window_lengthS_move;
FeatureParms.window_length = floor(FeatureParms.window_lengthS*Extract.data_rate);
[feature_data_move,FeatureParms]=Calc_PSD_TimeLocked(MEG_data,AnalysisParms.events_move,FeatureParms);

%% PLOTS

%             % Plot events in time
%             figure;hold all
%             plot(TimeVecs.timeS,TimeVecs.target_code_org')
%             plot(TimeVecs.timeS(Events.(AnalysisParms.event_name_move)),5*ones(1,length(Events.(AnalysisParms.event_name_move)))','.','Color',0.6*[1 1 1])
%             stem(TimeVecs.timeS(AnalysisParms.events_move),5*ones(1,length(AnalysisParms.events_move))','g.-')
%             plot(TimeVecs.timeS(Events.(AnalysisParms.event_name_rest)),5.2*ones(1,length(Events.(AnalysisParms.event_name_rest)))','.','Color',0.6*[1 1 1])
%             stem(TimeVecs.timeS(AnalysisParms.events_rest),5.2*ones(1,length(AnalysisParms.events_rest))','r.-')
%             Figure_Stretch(4)
%             title(str4plot([DB_entry.run_info ' ' DB_entry.entry_id]))
%             ylim([-1 6])
%             Figure_TightFrame
%             legend({'Cue','Move not Used','MoveUsed','Rest not Used','Rest Used'},'Location','SouthEast')


%         sensorimotor_left_idx = sensors2chanidx(Extract.channel_list,DEF_MEG_sensors_sensorimotor_left_hemi);
%         data4psd = Calc_ModDepth(feature_data_move,feature_data_rest,'T');
%
%         fig_psd = figure;hold all
%         Figure_Stretch(2,1)
%         % Left Sensorimotor
%         Plot_Variance_as_Patch(FeatureParms.actual_freqs,squeeze(mean(data4psd,1))',...
%             'variance_method','std','patch_color','k','patch_alpha',0.6,'fig',fig_psd); % STD across all sensor groups
%         plot(FeatureParms.actual_freqs,squeeze(mean(data4psd(:,sensorimotor_left_idx,:),1))',...
%             'g','LineWidth',2)
%         clear text_input
%         text_input{1} = [DB_entry.run_info];
%         text_input{2} = [AnalysisParms.event_name_move ' (x' num2str(length(AnalysisParms.events_move)) ') ' num2str(AnalysisParms.window_lengthS_move) 's window'];
%         text_input{3} = [AnalysisParms.event_name_rest ' (x' num2str(length(AnalysisParms.events_rest)) ') ' num2str(AnalysisParms.window_lengthS_rest) 's window'];
%         text_input{4} = ['Order: ' num2str(FeatureParms.order)];
%         Figure_Annotate(text_input)
%         title(DB_entry.subject)
%         xlabel('Freq [Hz]')
%         ylabel('Modulation [T]')

%         % Head Plot of Power
%         AnalysisParms.freq_names_4grouping = {'beta','gamma'};
%
%         % make list of freqs
%         AnalysisParms.freq_idx_4grouping=[];
%         for ifreq = 1:size(AnalysisParms.freq_names_4grouping,2)
%             AnalysisParms.freq_idx_4grouping=[AnalysisParms.freq_idx_4grouping; ...
%                 find_closest_range_idx(DEF_freq_bands(AnalysisParms.freq_names_4grouping{ifreq}),FeatureParms.actual_freqs)]; % do that find_closet stuff to get the valid indicies (what if you don't have 1Hz res?)
%         end
%
%         moddepth = Calc_ModDepth(feature_data_move,feature_data_rest,'t');
%         [moddepth_by_location_freqband,sensor_group_list] = Calc_ModDepth_Combine_by_Location(moddepth,AnalysisParms.freq_idx_4grouping,Extract.channel_list);
%
%         fig=figure;
%         for ifreq = 1:size(AnalysisParms.freq_idx_4grouping,1)
%             subplot(1,size(AnalysisParms.freq_idx_4grouping,1),ifreq);hold all
%             Plot_MEG_head_plot([1:3:306],moddepth_by_location_freqband(:,ifreq),'fig',fig);
%             Plot_MEG_chan_locations(DEF_MEG_sensors_sensorimotor_left_hemi,'MarkerType',1,'Color','k'); % 2013-08-13
%             caxis_center;colorbar
%             title(AnalysisParms.freq_names_4grouping{ifreq})
%         end
%         Figure_Stretch(2,2)
%         title_figure([DB_entry.subject])

%% Save

Power.feature_data_move = feature_data_move;
Power.feature_data_rest = feature_data_rest;
Power.Extract =           Extract;
Power.FeatureParms =      FeatureParms;
Power.AnalysisParms =     AnalysisParms;
