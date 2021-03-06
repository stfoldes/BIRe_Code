% Plots average topograph

clearvars -except DB

% ---FLAGS---
save_figs = 0;save_figs_by_subject = 0;
pointer_name = 'ResultPointers.Power_tsss_trans_Cue_o30';

% Choose criteria for data set to analyize
remove_criteria.subject = {'NC07','NC02'};


% Choose criteria for data set to analyize
clear criteria
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
        
%% ==========================================================
%  =====UNPACKING PROCESSED DATA AND CALCULATING METRICS=====
%  ==========================================================
criteria.subject_type='AB';
% Entries that match the criteria AND have the results pointer filled in
DB_short=DB.get_entry(criteria,remove_criteria);
DB_short(DB_Report_Property_Check(DB_short,pointer_name))=[]; % remove any empty entries
GroupResults_AB = Calc_GroupResults(DB_short,pointer_name);

criteria.subject_type='SCI';
% Entries that match the criteria AND have the results pointer filled in
DB_short=DB.get_entry(criteria,remove_criteria);
DB_short(DB_Report_Property_Check(DB_short,pointer_name))=[]; % remove any empty entries
GroupResults_SCI = Calc_GroupResults(DB_short,pointer_name);

% just to make this easier
AnalysisParms = GroupResults_AB.AnalysisParms;

%% Organization: Screening data and ALL

global MY_PATHS

% Load the function-Screening data
Screening = Load_Function_Screening([MY_PATHS.server_base filesep 'Functional_Assessment_Info' filesep 'Neurofeedback_Function_Screening.xls']);

% Add in Screening data into the results
clear function_results_key
for ientry = 1:length(GroupResults_AB)
    criteria_screen.subject = GroupResults_AB(ientry).subject;
    criteria_screen.session = 'Baseline';
    % Make a key to look up function data later
    function_results_key.AB(ientry) = DB_Find_Entries_By_Criteria(Screening,criteria_screen);
    GroupResults_AB(ientry).Screening=Screening(function_results_key.AB(ientry));
end

for ientry = 1:length(GroupResults_SCI)
    criteria_screen.subject = GroupResults_SCI(ientry).subject;
    criteria_screen.session = 'Baseline';
    function_results_key.SCI(ientry) = DB_Find_Entries_By_Criteria(Screening,criteria_screen);
    GroupResults_SCI(ientry).Screening=Screening(function_results_key.SCI(ientry));
end

% Combine results
GroupResults_ALL = [GroupResults_AB GroupResults_SCI];

% List of frequency indices (e.g. gamma_idx)
freq_list = AnalysisParms.freq_names_4grouping;
for ifreq = 1:length(freq_list)
    current_freq_name = freq_list{ifreq};
    eval([freq_list{ifreq} '_idx=find_lists_overlap_idx(AnalysisParms.freq_names_4grouping,current_freq_name);'])
end














%% ==================
%  ====Group Plots===
%  ==================

%% Beta vs. Grip str
current_freq_name='beta';

clear indep_field dep_field_list
indep_field = 'Screening.Grip_RT_Strength';
dep_label = {'Mean Mod','Peak Mod','X Pos of Peak','Portion Sig'};

eval(['current_freq_idx_str = num2str(' current_freq_name '_idx);'])
dep_field_list = {['left_hemi.mean_mod(' current_freq_idx_str ')']...
    ['left_hemi.min_mod(' current_freq_idx_str ')'],...
    ['left_hemi.min_mod_pos(' current_freq_idx_str ').x'],...
    ['left_hemi.portion_sig(' current_freq_idx_str ')']};

% fig=figure;hold all
% Figure_Stretch(2,2)
% for iplot=1:2%length(dep_field_list)
%     subplot(2,2,iplot);hold all
%     Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list{iplot},'subject_type',...
%         'marker_field','subject','dep_label',dep_label{iplot},'fit_line','none','fig',fig,'annotate_flag',0)
%     set(gca,'YDir','Reverse'); % modulation is upside down b/c of desycn
% end
% for iplot=3:4%1:length(dep_field_list)
%     subplot(2,2,iplot);hold all
%     Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list{iplot},'subject_type',...
%         'marker_field','subject','dep_label',dep_label{iplot},'fit_line','none','fig',fig,'annotate_flag',0)
% end
fig=figure;hold all
Figure_Stretch(2,2)
for iplot=1:2%length(dep_field_list)
    subplot(2,2,iplot);hold all
    Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list{iplot},'subject_type',...
        'marker_field','subject','dep_label',dep_label{iplot},'fit_line','cat','fig',fig,'annotate_flag',1)
    set(gca,'YDir','Reverse'); % modulation is upside down b/c of desycn
end
for iplot=3:4%1:length(dep_field_list)
    subplot(2,2,iplot);hold all
    Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list{iplot},'subject_type',...
        'marker_field','subject','dep_label',dep_label{iplot},'fit_line','cat','fig',fig,'annotate_flag',1)
end

Figure_Position(0)
title_figure(current_freq_name)

%% Gamma vs. Grip str
current_freq_name = 'gamma';
clear indep_field dep_field_list
indep_field = 'Screening.Grip_RT_Strength';
dep_label = {'Mean Mod','Peak Mod','X Pos of Peak','Portion Sig'};

eval(['current_freq_idx_str = num2str(' current_freq_name '_idx);'])
dep_field_list = {['left_hemi.mean_mod(' current_freq_idx_str ')']...
    ['left_hemi.max_mod(' current_freq_idx_str ')'],...
    ['left_hemi.max_mod_pos(' current_freq_idx_str ').x'],...
    ['left_hemi.portion_sig(' current_freq_idx_str ')']};

fig=figure;hold all
Figure_Stretch(2,2)
for iplot=1:length(dep_field_list)
    subplot(2,2,iplot);hold all
    Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list{iplot},'subject_type','dep_label',dep_label{iplot},'fit_line','cat','fig',fig)
end
Figure_Position(0)
title_figure(current_freq_name)


%%


% 
% 
% metric_list = {'portion_sig','maxmag_mod'};
% freq_list = {'beta','gamma'};
% 
% for imetric = 1:length(metric_list)
%     metric_str=metric_list{imetric};
%     
%     fig = figure;hold all
%     for ifreq = 1:length(freq_list)
%         subplot(1,length(freq_list),ifreq);hold all
%         
%         current_freq_name = freq_list{ifreq};
%         current_freq_idx=find_lists_overlap_idx(AnalysisParms.freq_names_4grouping,current_freq_name);
%         clear forplot_AB
%         for isubject = 1:length(GroupResults_AB)
%             forplot_AB(isubject) = GroupResults_AB(isubject).left_hemi.(metric_str)(current_freq_idx);
%         end
%         clear forplot_SCI
%         for isubject = 1:length(GroupResults_SCI)
%             forplot_SCI(isubject) = GroupResults_SCI(isubject).left_hemi.(metric_str)(current_freq_idx);
%         end
%         Plot_Bars({'AB','SCI'},{forplot_AB forplot_SCI},'fig',fig,'color',{'','r'})
%         ylabel(str4plot(metric_str))
%         title(current_freq_name)
%     end
%     Figure_Stretch(2)
%     title_figure(criteria.run_intention)
% end
% 
% % Location of mean
% load DEF_NeuromagSensorInfo;
% 
% metric_str='max_mod_location';
% fig = figure;hold all
% for ifreq = 1:length(freq_list)
%     subplot(1,length(freq_list),ifreq);hold all
%     
%     current_freq_name = freq_list{ifreq};
%     current_freq_idx=find_lists_overlap_idx(AnalysisParms.freq_names_4grouping,current_freq_name);
%     clear forplot_AB
%     for isubject = 1:length(GroupResults_AB)
%         current_sensor = GroupResults_AB(isubject).left_hemi.(metric_str)(current_freq_idx);
%         forplot_AB(isubject) = NeuromagSensorInfo(current_sensor).pos(1);
%     end
%     clear forplot_SCI
%     for isubject = 1:length(GroupResults_SCI)
%         current_sensor = GroupResults_SCI(isubject).left_hemi.(metric_str)(current_freq_idx);
%         forplot_SCI(isubject) = NeuromagSensorInfo(current_sensor).pos(1);
%     end
%     Plot_Bars({'AB','SCI'},{forplot_AB forplot_SCI},'fig',fig,'color',{'','r'})
%     ylabel(str4plot(metric_str))
%     title(current_freq_name)
% end
% Figure_Stretch(2)
% title_figure([criteria.run_intention ' ' criteria.run_action ' ' criteria.run_task_side])

%% PSD

sensor_group_list = unique(sensors2sensorgroup(GroupResults_AB(1).Extract.channel_list));

fig_psd = figure;hold all
Figure_Stretch(1,2)
% FOR AB
clear mod_by_subject
for isubject = 1:length(GroupResults_AB)
    mod_by_subject(isubject,:,:) = GroupResults_AB(isubject).mod;
end

% PSD
subplot(2,1,1)
Plot_ModDepth_Variance(mod_by_subject,GroupResults_AB(1).FeatureParms,GroupResults_AB(1).Extract.channel_list,'sensors4plot','L','fig',fig_psd);
ylabel('Modulation (t-stat)')
text_input{1} = [AnalysisParms.event_name_move ' (x' num2str(length(AnalysisParms.events_move)) ') ' num2str(AnalysisParms.window_lengthS_move) 's window'];
text_input{2} = [AnalysisParms.event_name_rest ' (x' num2str(length(AnalysisParms.events_rest)) ') ' num2str(AnalysisParms.window_lengthS_rest) 's window'];
text_input{3} = ['Order: ' num2str(GroupResults_AB(1).FeatureParms.order)];
text_input{4} = ['# Subjects: ' num2str(length(DB))];
Figure_Annotate(text_input)
title('AB')

% FOR SCI
clear mod_by_subject
for isubject = 1:length(GroupResults_SCI)
    mod_by_subject(isubject,:,:) = GroupResults_SCI(isubject).mod;
end

% PSD
subplot(2,1,2)
Plot_ModDepth_Variance(mod_by_subject,GroupResults_AB(1).FeatureParms,GroupResults_AB(1).Extract.channel_list,'sensors4plot','L','fig',fig_psd);
ylabel('Modulation (t-stat)')
text_input{1} = [AnalysisParms.event_name_move ' (x' num2str(length(AnalysisParms.events_move)) ') ' num2str(AnalysisParms.window_lengthS_move) 's window'];
text_input{2} = [AnalysisParms.event_name_rest ' (x' num2str(length(AnalysisParms.events_rest)) ') ' num2str(AnalysisParms.window_lengthS_rest) 's window'];
text_input{3} = ['Order: ' num2str(GroupResults_AB(1).FeatureParms.order)];
text_input{4} = ['# Subjects: ' num2str(length(DB))];
Figure_Annotate(text_input)
title('SCI')


if save_figs
    Figure_Save(['PSD_ALL_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
end


% Plot Topography
%     fig=figure;
%     for ifreq = 1:size(AnalysisParms.freq_idx_4grouping,1)
%         subplot(1,size(AnalysisParms.freq_idx_4grouping,1),ifreq);hold all
%         Plot_MEG_head_plot(mean(group_mod_by_location_freqband(:,:,ifreq),1),1,sort([1:3:306]),[],[],fig);
%         caxis_center;colorbar
%         title(AnalysisParms.freq_names_4grouping{ifreq})
%     end
%     Figure_Stretch(3,0.5)
%     title_figure([DB_entry.subject_type ' ' DB_entry.run_intention ' ' DB_entry.run_task_side ' ' DB_entry.run_action])
%     if save_figs
%         Figure_Save(['Topography_ALL_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
%     end


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


%% Group Stats: ttest with all subjects vs. 0



current_group =GroupResults_AB;
% current_group =GroupResults_SCI;





num_freq_bands=length(AnalysisParms.freq_names_4grouping);
clear group_mod_by_location_freqband current_subject_list
for isubject=1:length(current_group)
    group_mod_by_location_freqband(isubject,:,:) = current_group(isubject).mod_by_location_freqband;
    current_subject_list{isubject}=current_group(isubject).subject;
end

clear p
for ifreq = 1:num_freq_bands
    freq_name = AnalysisParms.freq_names_4grouping{ifreq};
    for isensor = 1:size(group_mod_by_location_freqband,2)
        [~,p.(freq_name)(isensor)]=ttest(group_mod_by_location_freqband(:,isensor,ifreq));
    end
end


% Plot distribution
sensor_plot_list = [32 37 40 44];
figure;
Figure_Stretch(2,2)
for isensor = 1:length(sensor_plot_list)
    sensor_num = sensor_plot_list(isensor);
    
    h=subplot(ceil(length(sensor_plot_list)/2),ceil(length(sensor_plot_list)/2),isensor);hold all
    
    data2plot=squeeze(group_mod_by_location_freqband(:,sensors2chanidx(sensor_group_list,sensors2sensorgroup(sensor_num)),:))';
    plot(data2plot,'.-')
    plot(nanmean(data2plot,2),'k*')
    
    plot([0 num_freq_bands+1],[0 0],'--')
    set(gca,'XTick',1:num_freq_bands)
    set(gca,'XTickLabel',AnalysisParms.freq_names_4grouping)
    xlim([0 num_freq_bands+1])
    ylabel('Modulation (t-stat)')
    title(['Sensor group for sensor #' num2str(sensor_num)])
    
    for isubject = 1:size(data2plot,2)
        y = data2plot(1,isubject);
        x = 1;
        text(x,y,current_subject_list{isubject},...
            'HorizontalAlignment','right',...
            'VerticalAlignment','middle',...
            'FontSize',10)
    end
    Figure_TightFrame(h)
end
title_figure([criteria.run_intention])
if save_figs
    Figure_Save(['ModPerSubject_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
end

%% B&W p-values
%
%
% fig_head=figure;hold all
% p_thres = 0.10;
% for ifreq = 1:num_freq_bands
%     freq_name = AnalysisParms.freq_names_4grouping{ifreq};
%
%     subplot(3,num_freq_bands,ifreq);hold all
%     Plot_MEG_head_plot(log10(p.(freq_name)),1,sensorgroup2sensor(sensor_group_list,1),[],[],fig_head);
%     % Set colors to be 0.05 to smaller
%     % colorbar_with_label('log10(p)','EastOutside');
%     current_caxis =caxis;
%     caxis(sort([current_caxis(1) log10(p_thres)]))
%     title(['p<' num2str(p_thres) ' for ' (freq_name)])
%     colormap('gray')
%     % Figure_Position(0.7,1)
% end
% p_thres = 0.05;
% for ifreq = 1:num_freq_bands
%     freq_name = AnalysisParms.freq_names_4grouping{ifreq};
%
%     subplot(3,num_freq_bands,ifreq+num_freq_bands);hold all
%     Plot_MEG_head_plot(log10(p.(freq_name)),1,sensorgroup2sensor(sensor_group_list,1),[],[],fig_head);
%     % Set colors to be 0.05 to smaller
%     % colorbar_with_label('log10(p)','EastOutside');
%     current_caxis =caxis;
%     caxis(sort([current_caxis(1) log10(p_thres)]))
%     title(['p<' num2str(p_thres) ' for ' (freq_name)])
%     colormap('gray')
%     % Figure_Position(0.7,1)
% end
% p_thres = 0.01;
% for ifreq = 1:num_freq_bands
%     freq_name = AnalysisParms.freq_names_4grouping{ifreq};
%
%     subplot(3,num_freq_bands,ifreq+2*num_freq_bands);hold all
%     Plot_MEG_head_plot(log10(p.(freq_name)),1,sensorgroup2sensor(sensor_group_list,1),[],[],fig_head);
%     % Set colors to be 0.05 to smaller
%     % colorbar_with_label('log10(p)','EastOutside');
%     current_caxis =caxis;
%     caxis(sort([current_caxis(1) log10(p_thres)]))
%     title(['p<' num2str(p_thres) ' for ' (freq_name)])
%     colormap('gray')
%     % Figure_Position(0.7,1)
% end
% title_figure([DB_entry.subject_type ' ' DB_entry.run_intention ' ' DB_entry.run_task_side ' ' DB_entry.run_action])
% Figure_Stretch(2,1.5)
% if save_figs
%     Figure_Save(['pvalues_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
% end

%% p-masked-modulation


fig_head=figure;hold all
Figure_Stretch(1.5,1)
for ifreq = 1:num_freq_bands
    freq_name = AnalysisParms.freq_names_4grouping{ifreq};
    
    
    subplot(3,num_freq_bands,ifreq);hold all
    Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),nanmean(group_mod_by_location_freqband(:,:,ifreq),1),'fig',fig_head);
    Plot_MEG_Helmet
    colormap('jet')
    title(freq_name)
    caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
    %     colorbar_with_label('Modulation','SouthOutside');
    colormap_freeze % ***TRICK***
    
    
    p_thres = 0.1;
    subplot(3,num_freq_bands,ifreq+num_freq_bands);hold all
    masked_mod = Calc_Sensor_Mask_Apply(group_mod_by_location_freqband,p.(freq_name),p_thres);
    
    Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),nanmean(masked_mod(:,:,ifreq),1),'fig',fig_head);
    Plot_MEG_Helmet
    title(['p<' num2str(p_thres)])
    colormap_masked_middle(0);
    caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
    %colorbar_with_label('Modulation','SouthOutside');
    
    p_thres = 0.05;
    subplot(3,num_freq_bands,ifreq+2*num_freq_bands);hold all
    masked_mod = Calc_Sensor_Mask_Apply(group_mod_by_location_freqband,p.(freq_name),p_thres);
    
    Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),nanmean(masked_mod(:,:,ifreq),1),'fig',fig_head);
    Plot_MEG_Helmet
    %title([freq_name ' masked at p<' num2str(p_thres)])
    title(['p<' num2str(p_thres)])
    colormap_masked_middle(0);
    caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
    %colorbar_with_label('Modulation','SouthOutside');
end
% title_figure('Group Masked Modulation')
title_figure([criteria.run_intention])
if save_figs
    Figure_Save(['Topography_pthres_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
end


%% p-masked-modulation (smaller for simpler view)
fig_head=figure;hold all
Figure_Stretch(1.5,1)
p_thres = 0.05;

freq_name = 'beta';
ifreq = find(strcmpi(AnalysisParms.freq_names_4grouping,freq_name));

subplot(1,2,1);hold all
masked_mod = Calc_Sensor_Mask_Apply(group_mod_by_location_freqband,p.(freq_name),p_thres);
Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),nanmean(masked_mod(:,:,ifreq),1),'fig',fig_head);
Plot_MEG_Helmet
title(freq_name)
colormap_masked_middle(0);
caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
colorbar

freq_name = 'gamma';
ifreq = find(strcmpi(AnalysisParms.freq_names_4grouping,freq_name));

subplot(1,2,2);hold all
masked_mod = Calc_Sensor_Mask_Apply(group_mod_by_location_freqband,p.(freq_name),p_thres);
Plot_MEG_head_plot(sensorgroup2sensor(sensor_group_list,1),nanmean(masked_mod(:,:,ifreq),1),'fig',fig_head);
Plot_MEG_Helmet
title(freq_name)
colormap_masked_middle(0);
caxis_center%(maxmag([maxmag(get(gca,'CLim')),1]));
colorbar

title_figure([criteria.run_intention])


if save_figs
    Figure_Save(['Topography_pthres_small_' DB_entry.subject_type '_' DB_entry.run_intention '_' DB_entry.run_task_side '_' DB_entry.run_action])
end




