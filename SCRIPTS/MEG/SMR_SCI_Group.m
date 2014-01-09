% 2013-10-18 Foldes

% Plots average topograph

clearvars -except DB

save_figs = 0;save_figs_by_subject = 0;
pointer_name = 'ResultPointers.Power_tsss_trans_Cue_burg';

% Choose criteria for data set to analyize
clear criteria
criteria.run_type = 'Open_Loop_MEG';
criteria.run_task_side = 'Right';
criteria.run_action = 'Grasp';
criteria.run_intention = 'Attempt';

ResultParms.freq_names = {'mu','beta','SMR','gamma','gamma_low'};
ResultParms.roi_names = {'left_hemi','right_hemi'}; % DEF_MEG_sensors_sensorimotor_*
ResultParms.p_thres_for_sensors=0.05;

% Choose criteria for data set to analyize
remove_criteria.subject = {'NC07','NC02'};

%% Load Database

% Build database
if ~exist('DB','var')
    DB=DB_MEG_Class;
    DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

%% ==========================================================
%  =====UNPACKING PROCESSED DATA AND CALCULATING METRICS=====
%  ==========================================================

% Entries that match the criteria AND have the results pointer filled in
DB_short=DB.get_entry(criteria,remove_criteria);
DB_short(DB_Report_Property_Check(DB_short,pointer_name))=[]; % remove any empty entries
[Results,ResultParms] = Calc_Results(DB_short,pointer_name,ResultParms); % <-- RESULTS CALCULATED HERE

% just to make this easier
AnalysisParms = Results.AnalysisParms;

%% Organization: Screening data and ALL

global MY_PATHS

% Load the function-Screening data
Screening = Load_Function_Screening([MY_PATHS.server_base filesep 'Functional_Assessment_Info' filesep 'Neurofeedback_Function_Screening.xls']);

% Add in Screening data into the results
clear function_results_key
for ientry = 1:length(Results)
    criteria_screen.subject = Results(ientry).subject;
    criteria_screen.session = 'Baseline';
    % Make a key to look up function data later
    function_results_key(ientry) = DB_Find_Entries_By_Criteria(Screening,criteria_screen);
    Results(ientry).Screening=Screening(function_results_key(ientry));
end

% % List of frequency indices (e.g. gamma_idx)
% freq_list = ResultsParms.freq_names;
% for ifreq = 1:length(freq_list)
%     current_freq_name = freq_list{ifreq};
%     eval([freq_list{ifreq} '_idx=find_lists_overlap_idx(ResultsParms.freq_names,current_freq_name);'])
% end


%% Define Groups
clear group_idx*
group_idx{1}=DB_find_idx(Results,'subject_type','AB');
group_idx_names{1} = 'AB';
group_idx{2}=DB_find_idx(Results,'subject_type','SCI');
group_idx_names{2} = 'SCI';


% By strength
clear group_idx*
group_idx{1}=DB_find_idx(Results,'subject_type','AB');
group_idx_names{1} = 'AB';

all_SCI_idx=DB_find_idx(Results,'subject_type','SCI');
group_idx{2}= [];group_idx{3}= [];
for iidx = 1:length(all_SCI_idx)
    % Strength > 1 = Moderate
    if Results(all_SCI_idx(iidx)).Screening.Grip_RT_Strength > 1
        group_idx{2}= [group_idx{2} all_SCI_idx(iidx)];
    else % Strength <= 1 = Severe
        group_idx{3}= [group_idx{3} all_SCI_idx(iidx)];
    end
end
group_idx_names{2} = 'Moderate';
group_idx_names{3} = 'Severe';


%% ==================
%  ====Group Plots===
%  ==================

%% BARS - Beta

current_freq_name = 'beta';
current_freq_idx = find_lists_overlap_idx(ResultParms.freq_names,current_freq_name);

fig = figure;hold all

metric_str='mean_sig';
subplot(2,2,1);

clear data4bar
for igroup = 1:length(group_idx)
    for isubject = 1:length(group_idx{igroup})
        current_idx = group_idx{igroup}(isubject);
        data4bar{igroup}(isubject) = Results(current_idx).left_hemi.(metric_str)(current_freq_idx);
    end % subject
end % group
Plot_Bars(group_idx_names,data4bar,'fig',fig,'color',{'','r','m'})
ylabel(str4plot(metric_str))
title(current_freq_name)
set(gca,'YDir','Reverse'); % modulation is upside down b/c of desycn

metric_str='min_sig';
subplot(2,2,2);

clear data4bar
for igroup = 1:length(group_idx)
    for isubject = 1:length(group_idx{igroup})
        current_idx = group_idx{igroup}(isubject);
        data4bar{igroup}(isubject) = Results(current_idx).left_hemi.(metric_str)(current_freq_idx);
    end % subject
end % group
Plot_Bars(group_idx_names,data4bar,'fig',fig,'color',{'','r','m'})
ylabel(str4plot(metric_str))
title(current_freq_name)
set(gca,'YDir','Reverse'); % modulation is upside down b/c of desycn

metric_str='portion_sig';
subplot(2,2,3);

clear data4bar
for igroup = 1:length(group_idx)
    for isubject = 1:length(group_idx{igroup})
        current_idx = group_idx{igroup}(isubject);
        data4bar{igroup}(isubject) = Results(current_idx).left_hemi.(metric_str)(current_freq_idx);
    end % subject
end % group
Plot_Bars(group_idx_names,data4bar,'fig',fig,'color',{'','r','m'})
ylabel(str4plot(metric_str))
title(current_freq_name)

% metric_str='min_sig_pos.x';
subplot(2,2,4);

clear data4bar
for igroup = 1:length(group_idx)
    for isubject = 1:length(group_idx{igroup})
        current_idx = group_idx{igroup}(isubject);
        data4bar{igroup}(isubject) = Results(current_idx).left_hemi.min_sig_pos(current_freq_idx).x;
    end % subject
end % group
Plot_Bars(group_idx_names,data4bar,'fig',fig,'color',{'','r','m'})
ylabel(str4plot('min_sig_pos'))
title(current_freq_name)

Figure_Stretch(2,2)
title_figure(criteria.run_intention)

%% BARS - Gamma

current_freq_name = 'gamma';
current_freq_idx = find_lists_overlap_idx(ResultParms.freq_names,current_freq_name); 

fig = figure;hold all

metric_str='mean_sig';
subplot(2,2,1);

clear data4bar
for igroup = 1:length(group_idx)
    for isubject = 1:length(group_idx{igroup})
        current_idx = group_idx{igroup}(isubject);
        data4bar{igroup}(isubject) = Results(current_idx).left_hemi.(metric_str)(current_freq_idx);
    end % subject
end % group
Plot_Bars(group_idx_names,data4bar,'fig',fig,'color',{'','r','m'})
ylabel(str4plot(metric_str))
title(current_freq_name)

metric_str='max_sig';
subplot(2,2,2);

clear data4bar
for igroup = 1:length(group_idx)
    for isubject = 1:length(group_idx{igroup})
        current_idx = group_idx{igroup}(isubject);
        data4bar{igroup}(isubject) = Results(current_idx).left_hemi.(metric_str)(current_freq_idx);
    end % subject
end % group
Plot_Bars(group_idx_names,data4bar,'fig',fig,'color',{'','r','m'})
ylabel(str4plot(metric_str))
title(current_freq_name)

metric_str='portion_sig';
subplot(2,2,3);

clear data4bar
for igroup = 1:length(group_idx)
    for isubject = 1:length(group_idx{igroup})
        current_idx = group_idx{igroup}(isubject);
        data4bar{igroup}(isubject) = Results(current_idx).left_hemi.(metric_str)(current_freq_idx);
    end % subject
end % group
Plot_Bars(group_idx_names,data4bar,'fig',fig,'color',{'','r','m'})
ylabel(str4plot(metric_str))
title(current_freq_name)

% metric_str='max_sig_pos.x';
subplot(2,2,4);

clear data4bar
for igroup = 1:length(group_idx)
    for isubject = 1:length(group_idx{igroup})
        current_idx = group_idx{igroup}(isubject);
        data4bar{igroup}(isubject) = Results(current_idx).left_hemi.max_sig_pos(current_freq_idx).x;
    end % subject
end % group
Plot_Bars(group_idx_names,data4bar,'fig',fig,'color',{'','r','m'})
ylabel(str4plot('max_sig_pos'))
title(current_freq_name)

Figure_Stretch(2,2)
title_figure(criteria.run_intention)

%% PSD - Groups

% sensor_group_list = unique(sensors2sensorgroup(Results(1).Extract.channel_list));

clear data4psd
for igroup = 1:length(group_idx)
    for isubject = 1:length(group_idx{igroup})
        current_idx = group_idx{igroup}(isubject);
        data4psd{igroup}(isubject,:,:) = Results(current_idx).mod;
    end % subject
end % group

fig_psd = figure;hold all
Figure_Stretch(1,2)

for igroup = 1:length(group_idx)
    % PSD
    subplot(2,1,igroup)
    Plot_ModDepth_Variance(data4psd{igroup},Results(1).FeatureParms,Results(1).Extract.channel_list,...
        'sensors4plot','L','fig',fig_psd);
    ylabel('Modulation (t-stat)')
    clear text_input
    text_input{1} = [AnalysisParms.event_name_move ' (x' num2str(length(AnalysisParms.events_move)) ') ' num2str(AnalysisParms.window_lengthS_move) 's window'];
    text_input{2} = [AnalysisParms.event_name_rest ' (x' num2str(length(AnalysisParms.events_rest)) ') ' num2str(AnalysisParms.window_lengthS_rest) 's window'];
    text_input{3} = ['Order: ' num2str(Results(1).FeatureParms.order)];
    %text_input{4} = ['# Subjects: ' num2str(length(DB))];
    Figure_Annotate(text_input)
    title(group_idx_names{igroup})
end
Figure_Subplot_Same_Axes('y') 

if save_figs
    Figure_Save(['PSD_ALL_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
end




%% Topo - Groups
freq_list2plot = {'beta','SMR','gamma'};

clear data4topo
for igroup = 1:length(group_idx)
    for isubject = 1:length(group_idx{igroup})
        current_idx = group_idx{igroup}(isubject);
        data4topo{igroup}(isubject,:,:) = Results(current_idx).mod_by_location_freqband;
    end % subject
end % group

num_freq = length(freq_list2plot);

for igroup = 1:length(group_idx)
    
    fig_topo = figure;hold all
    
    Figure_Stretch(2,1)
    
    for ifreq = 1:num_freq
        subplot(1,num_freq,ifreq)
        current_freq_name = cell2mat(freq_list2plot(ifreq));
        current_freq_idx = find_lists_overlap_idx(ResultParms.freq_names,current_freq_name);
        
        Plot_MEG_head_plot([],squeeze(nanmean(data4topo{igroup}(:,:,current_freq_idx),1)),'fig',fig_topo);
        colorbar
        %caxis_center(5)
        title(current_freq_name)
    end
    
    title_figure(group_idx_names{igroup})
end


%% PSD - By Subject

% Maybe do that cool gui I used to have
% pick subject by name

sensorimotor_left_idx = sensors2chanidx(Results(1).Extract.channel_list,DEF_MEG_sensors_sensorimotor_left_hemi);
subject_list = {'NC06'};
% subject_list = {'NC01','NS08','NS03','NC03'};
% subject_list = {'NS10','NC06','NC05','NS04'};
for isubject = 1:length(subject_list)
    current_subject = subject_list{isubject};
    current_idx = DB_find_idx(Results,'subject',current_subject);
    
    fig_psd = figure;hold all
    Figure_Stretch(2,1)
    % Left Sensorimotor
    Plot_Variance_as_Patch(Results(current_idx).FeatureParms.actual_freqs,Results(current_idx).mod',...
        'variance_method','std','patch_color','k','patch_alpha',0.6,'fig',fig_psd); % STD across all sensor groups
    plot(Results(current_idx).FeatureParms.actual_freqs,Results(current_idx).mod(sensorimotor_left_idx,:)',...
        'g','LineWidth',2)
    plot( [min(Results(current_idx).FeatureParms.actual_freqs),max(Results(current_idx).FeatureParms.actual_freqs)],2.92*[1 1],'--k')
    plot( [min(Results(current_idx).FeatureParms.actual_freqs),max(Results(current_idx).FeatureParms.actual_freqs)],[0 0],'--k')
    plot( [min(Results(current_idx).FeatureParms.actual_freqs),max(Results(current_idx).FeatureParms.actual_freqs)],2.92*[-1 -1],'--k')
    clear text_input
    text_input{1} = [Results(current_idx).AnalysisParms.event_name_move ' (x' num2str(length(Results(current_idx).AnalysisParms.events_move)) ') ' num2str(Results(current_idx).AnalysisParms.window_lengthS_move) 's window'];
    text_input{2} = [Results(current_idx).AnalysisParms.event_name_rest ' (x' num2str(length(Results(current_idx).AnalysisParms.events_rest)) ') ' num2str(Results(current_idx).AnalysisParms.window_lengthS_rest) 's window'];
    text_input{3} = ['Order: ' num2str(Results(current_idx).FeatureParms.order)];
    text_input{4} = [Results(current_idx).run_info];
    Figure_Annotate(text_input)
    title(Results(current_idx).subject)
    xlabel('Freq [Hz]')
    ylabel('Modulation [T]')
    
    % GUI TOPO
    GUI_Inspect_ModDepth_wTopography(fig_psd,Results(current_idx).feature_data_move,Results(current_idx).feature_data_rest,...
        Results(current_idx).Extract.channel_list,Results(current_idx).FeatureParms);
end

%% Topo - By Subject

subject_list = {'NC01','NS08','NS03','NC03'};
% subject_list = {'NS10','NC06','NC05','NS04'};

freq_list2plot = {'beta','SMR','gamma_low','gamma'};


for isubject = 1:length(subject_list)
    current_subject = subject_list{isubject};
    current_idx = DB_find_idx(Results,'subject',current_subject);
    
    fig_topo = figure;hold all
    Figure_Stretch(2,1)
    
    num_freq = length(freq_list2plot);
    for ifreq = 1:num_freq
        subplot(1,num_freq,ifreq)
        current_freq_name = cell2mat(freq_list2plot(ifreq));
        current_freq_idx = find_lists_overlap_idx(ResultParms.freq_names,current_freq_name);
        
        Plot_MEG_head_plot([],Results(current_idx).mod_by_location_freqband(:,current_freq_idx),'fig',fig_topo);
        colorbar
        %caxis_center(5)
        title(current_freq_name)
    end
    
    title_figure(Results(current_idx).subject)
end % subject


%% Scatter Plots
%
% indep_field = 'Screening.Grip_RT_Strength';
% dep_field_list = {'Screening.Finger_Flex_RT_Strength',...
%     ['left_hemi.max_mod(' num2str(beta_idx) ')'],...
%     ['left_hemi.max_mod(' num2str(gamma_idx) ')'],...
%     ['left_hemi.max_mod(3)']};
% dep_label = {'Finger Strength','MaxMod Beta','MaxMod Gamma','MaxMod SMR'};
% Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list,'subject_type','dep_label',dep_label,'fit_line','group')
% Figure_Stretch(1,2)
% title_figure([criteria.run_intention ' ' criteria.run_action ' ' criteria.run_task_side])
% Figure_Position(0)
%
% indep_field = 'Screening.Grip_RT_Strength';
% dep_field_list = {'Screening.Finger_Flex_RT_Strength',...
%     ['left_hemi.mean_mod(' num2str(beta_idx) ')'],...
%     ['left_hemi.mean_mod(' num2str(gamma_idx) ')'],...
%     ['left_hemi.mean_mod(3)']};
% dep_label = {'Finger Strength','meanMod Beta','meanMod Gamma','meanMod SMR'};
% Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list,'subject_type','dep_label',dep_label,'fit_line','group')
% Figure_Stretch(1,2)
% title_figure([criteria.run_intention ' ' criteria.run_action ' ' criteria.run_task_side])
% Figure_Position(0.25)




%% SCATTER Beta vs. Grip str
current_freq_name='beta';
eval(['current_freq_idx_str = num2str(' current_freq_name '_idx);'])

clear indep_field dep_field_list
indep_field = 'Screening.Grip_RT_Strength';
dep_label = {'Mean Mod','Portion Sig','Peak Mod','X Pos of Peak'};
dep_field_list = {['left_hemi.mean_sig(' current_freq_idx_str ')']...
    ['left_hemi.portion_sig(' current_freq_idx_str ')'],...
    ['left_hemi.min_sig(' current_freq_idx_str ')'],...
    ['left_hemi.min_sig_pos(' current_freq_idx_str ').x']};
flip_y_flags = [1 0 1 0];

fig=figure;hold all
Figure_Stretch(2,2)
for iplot=1:length(dep_field_list)
    subplot(2,2,iplot);hold all
    Plot_Scatter_wStruct(Results,indep_field,dep_field_list{iplot},'subject_type',...
        'marker_field','subject','dep_label',dep_label{iplot},'fit_line','cat','fig',fig,'annotate_flag',0)
    if flip_y_flags(iplot)==1
        set(gca,'YDir','Reverse'); % modulation is upside down b/c of desycn
    end
end
Figure_Position(0)
title_figure(current_freq_name)

%% SCATTER Gamma vs. Grip str

current_freq_name = 'gamma';
eval(['current_freq_idx_str = num2str(' current_freq_name '_idx);'])
clear indep_field dep_field_list
indep_field = 'Screening.Grip_RT_Strength';
dep_label = {'Mean Mod','Portion Sig','Peak Mod','X Pos of Peak'};
dep_field_list = {['left_hemi.mean_sig(' current_freq_idx_str ')']...
    ['left_hemi.portion_sig(' current_freq_idx_str ')'],...
    ['left_hemi.max_sig(' current_freq_idx_str ')'],...
    ['left_hemi.max_sig_pos(' current_freq_idx_str ').x']};
flip_y_flags = [0 0 0 0];

fig=figure;hold all
Figure_Stretch(2,2)
for iplot=1:length(dep_field_list)
    subplot(2,2,iplot);hold all
    Plot_Scatter_wStruct(Results,indep_field,dep_field_list{iplot},...
        'subject_type','dep_label',dep_label{iplot},'fit_line','cat','fig',fig,'annotate_flag',0)
    if flip_y_flags(iplot)==1
        set(gca,'YDir','Reverse'); % modulation is upside down b/c of desycn
    end
end
Figure_Position(0.3)
title_figure(current_freq_name)






%%

















% %% Group Stats: ttest with all subjects vs. 0
% 
% 
% 
% current_group =GroupResults_AB;
% % current_group =GroupResults_SCI;
% 
% 
% 
% 
% 
% num_freq_bands=length(AnalysisParms.freq_names);
% clear group_mod_by_location_freqband current_subject_list
% for isubject=1:length(current_group)
%     group_mod_by_location_freqband(isubject,:,:) = current_group(isubject).mod_by_location_freqband;
%     current_subject_list{isubject}=current_group(isubject).subject;
% end
% 
% clear p
% for ifreq = 1:num_freq_bands
%     freq_name = AnalysisParms.freq_names{ifreq};
%     for isensor = 1:size(group_mod_by_location_freqband,2)
%         [~,p.(freq_name)(isensor)]=ttest(group_mod_by_location_freqband(:,isensor,ifreq));
%     end
% end
% 
% 
% % Plot distribution
% sensor_plot_list = [32 37 40 44];
% figure;
% Figure_Stretch(2,2)
% for isensor = 1:length(sensor_plot_list)
%     sensor_num = sensor_plot_list(isensor);
%     
%     h=subplot(ceil(length(sensor_plot_list)/2),ceil(length(sensor_plot_list)/2),isensor);hold all
%     
%     data2plot=squeeze(group_mod_by_location_freqband(:,sensors2chanidx(sensor_group_list,sensors2sensorgroup(sensor_num)),:))';
%     plot(data2plot,'.-')
%     plot(nanmean(data2plot,2),'k*')
%     
%     plot([0 num_freq_bands+1],[0 0],'--')
%     set(gca,'XTick',1:num_freq_bands)
%     set(gca,'XTickLabel',AnalysisParms.freq_names)
%     xlim([0 num_freq_bands+1])
%     ylabel('Modulation (t-stat)')
%     title(['Sensor group for sensor #' num2str(sensor_num)])
%     
%     for isubject = 1:size(data2plot,2)
%         y = data2plot(1,isubject);
%         x = 1;
%         text(x,y,current_subject_list{isubject},...
%             'HorizontalAlignment','right',...
%             'VerticalAlignment','middle',...
%             'FontSize',10)
%     end
%     Figure_TightFrame(h)
% end
% title_figure([criteria.run_intention])
% if save_figs
%     Figure_Save(['ModPerSubject_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
% end
% 
% %% B&W p-values
% %
% %
% % fig_head=figure;hold all
% % p_thres = 0.10;
% % for ifreq = 1:num_freq_bands
% %     freq_name = AnalysisParms.freq_names{ifreq};
% %
% %     subplot(3,num_freq_bands,ifreq);hold all
% %     Plot_MEG_head_plot(log10(p.(freq_name)),1,sensorgroup2sensor(sensor_group_list,1),[],[],fig_head);
% %     % Set colors to be 0.05 to smaller
% %     % colorbar_with_label('log10(p)','EastOutside');
% %     current_caxis =caxis;
% %     caxis(sort([current_caxis(1) log10(p_thres)]))
% %     title(['p<' num2str(p_thres) ' for ' (freq_name)])
% %     colormap('gray')
% %     % Figure_Position(0.7,1)
% % end
% % p_thres = 0.05;
% % for ifreq = 1:num_freq_bands
% %     freq_name = AnalysisParms.freq_names{ifreq};
% %
% %     subplot(3,num_freq_bands,ifreq+num_freq_bands);hold all
% %     Plot_MEG_head_plot(log10(p.(freq_name)),1,sensorgroup2sensor(sensor_group_list,1),[],[],fig_head);
% %     % Set colors to be 0.05 to smaller
% %     % colorbar_with_label('log10(p)','EastOutside');
% %     current_caxis =caxis;
% %     caxis(sort([current_caxis(1) log10(p_thres)]))
% %     title(['p<' num2str(p_thres) ' for ' (freq_name)])
% %     colormap('gray')
% %     % Figure_Position(0.7,1)
% % end
% % p_thres = 0.01;
% % for ifreq = 1:num_freq_bands
% %     freq_name = AnalysisParms.freq_names{ifreq};
% %
% %     subplot(3,num_freq_bands,ifreq+2*num_freq_bands);hold all
% %     Plot_MEG_head_plot(log10(p.(freq_name)),1,sensorgroup2sensor(sensor_group_list,1),[],[],fig_head);
% %     % Set colors to be 0.05 to smaller
% %     % colorbar_with_label('log10(p)','EastOutside');
% %     current_caxis =caxis;
% %     caxis(sort([current_caxis(1) log10(p_thres)]))
% %     title(['p<' num2str(p_thres) ' for ' (freq_name)])
% %     colormap('gray')
% %     % Figure_Position(0.7,1)
% % end
% % title_figure([DB_entry.subject_type ' ' DB_entry.run_intention ' ' DB_entry.run_task_side ' ' DB_entry.run_action])
% % Figure_Stretch(2,1.5)
% % if save_figs
% %     Figure_Save(['pvalues_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
% % end
% 
% %% p-masked-modulation
% 
% 
% fig_head=figure;hold all
% Figure_Stretch(1.5,1)
% for ifreq = 1:num_freq_bands
%     freq_name = AnalysisParms.freq_names{ifreq};
%     
%     
%     subplot(3,num_freq_bands,ifreq);hold all
%     Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),nanmean(group_mod_by_location_freqband(:,:,ifreq),1),'fig',fig_head);
%     Plot_MEG_Helmet
%     colormap('jet')
%     title(freq_name)
%     caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
%     %     colorbar_with_label('Modulation','SouthOutside');
%     colormap_freeze % ***TRICK***
%     
%     
%     p_thres = 0.1;
%     subplot(3,num_freq_bands,ifreq+num_freq_bands);hold all
%     masked_mod = Calc_Sensor_Mask_Apply(group_mod_by_location_freqband,p.(freq_name),p_thres);
%     
%     Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),nanmean(masked_mod(:,:,ifreq),1),'fig',fig_head);
%     Plot_MEG_Helmet
%     title(['p<' num2str(p_thres)])
%     colormap_masked_middle(0);
%     caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
%     %colorbar_with_label('Modulation','SouthOutside');
%     
%     p_thres = 0.05;
%     subplot(3,num_freq_bands,ifreq+2*num_freq_bands);hold all
%     masked_mod = Calc_Sensor_Mask_Apply(group_mod_by_location_freqband,p.(freq_name),p_thres);
%     
%     Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),nanmean(masked_mod(:,:,ifreq),1),'fig',fig_head);
%     Plot_MEG_Helmet
%     %title([freq_name ' masked at p<' num2str(p_thres)])
%     title(['p<' num2str(p_thres)])
%     colormap_masked_middle(0);
%     caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
%     %colorbar_with_label('Modulation','SouthOutside');
% end
% % title_figure('Group Masked Modulation')
% title_figure([criteria.run_intention])
% if save_figs
%     Figure_Save(['Topography_pthres_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
% end
% 
% 
% %% p-masked-modulation (smaller for simpler view)
% fig_head=figure;hold all
% Figure_Stretch(1.5,1)
% p_thres = 0.01;
% 
% freq_name = 'beta';
% ifreq = find(strcmpi(AnalysisParms.freq_names,freq_name));
% 
% subplot(1,2,1);hold all
% masked_mod = Calc_Sensor_Mask_Apply(group_mod_by_location_freqband,p.(freq_name),p_thres);
% Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),nanmean(masked_mod(:,:,ifreq),1),'fig',fig_head);
% Plot_MEG_Helmet
% title(freq_name)
% colormap_masked_middle(0);
% caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
% colorbar
% 
% freq_name = 'gamma';
% ifreq = find(strcmpi(AnalysisParms.freq_names,freq_name));
% 
% subplot(1,2,2);hold all
% masked_mod = Calc_Sensor_Mask_Apply(group_mod_by_location_freqband,p.(freq_name),p_thres);
% Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),nanmean(masked_mod(:,:,ifreq),1),'fig',fig_head);
% Plot_MEG_Helmet
% title(freq_name)
% colormap_masked_middle(0);
% caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
% colorbar
% 
% title_figure([criteria.run_intention])
% 
% %%
% if save_figs
%     Figure_Save(['Topography_pthres_small_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
% end
% 
% 


