% 2013-06-27 Foldes
% Compares Imagine to Attempt in AB and SCI

clear

save_fig_flag = 0; close all

% freq_band_name = 'mu';
% best_min_or_max = 'min';

% freq_band_name = 'beta';
% best_min_or_max = 'min';

freq_band_name = 'gamma';
best_min_or_max = 'max';

% freq_band_name = 'gamma_high';
% best_min_or_max = 'max';


pointer_name = 'ResultPointers.ModDepth_sss_trans_Cue';

% Choose criteria for data set to analyize
clear criteria_struct
criteria_struct.run_type = 'Open_Loop_MEG';
criteria_struct.run_task_side = 'Right';
criteria_struct.run_action = 'Grasp';
criteria_struct.run_intention = {'Imagine' 'Attempt'};

freq_range_ideal = DEF_freq_bands(freq_band_name);
fig_tag = [freq_band_name ' Avg '];

%% Load results

% Load Database
[Metadata,metadatabase_location,local_path,server_path]=Metadata_Load_Database_Cheat('meg_neurofeedback');

% Chooses the approprate entry (makes one if you don't have one)
[entry_idx_list] = Metadata_Find_Entries_By_Criteria(Metadata,criteria_struct);
% CHECK FIRST
[~,completed_idx_list]=Metadata_Report_Property_Check(Metadata.by_criteria(criteria_struct),pointer_name);

for ientry = 1:length(completed_idx_list)
    
    metadata_entry = Metadata(completed_idx_list(ientry));
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(completed_idx_list)) ' | ' metadata_entry.file_base_name '================='])
    
    % Load Results into workspace
    complete_flag = Metadata_Load_Pointer_Data(metadata_entry,pointer_name,local_path,server_path);
    
    % Freq to look across
    freq_range_idx = [find_closest_in_list_idx(min(freq_range_ideal),Results.FeatureParms.actual_freqs):find_closest_in_list_idx(max(freq_range_ideal),Results.FeatureParms.actual_freqs)];
    
    Results.pzscore_moddepth_by_sensor_set = Calc_MEG_ModDepth(Results.feature_data_move,Results.feature_data_rest,Results.Extract.channel_list,1);
    
    % Average ModDepth in freq band
    moddepth_by_sensor_set(:,ientry) = mean(mean(Results.pzscore_moddepth_by_sensor_set(:,:,freq_range_idx),1),3);
    entry_num(ientry)=completed_idx_list(ientry);
end


%% Organize by criteria

Metadata_short=Metadata(entry_num); % make new database for only the entries used

% Split AB/SCI and Attempt/Imagine (better than hardcoding, but a big pain in the ass)
% for each entry, find a match
clear file_pairs_AB file_pairs_SCI
file_pairs_AB.Attempt=[];file_pairs_AB.Imagine=[];
file_pairs_SCI.Attempt=[];file_pairs_SCI.Imagine=[];
entries_matched = 0;
for ientry = 1:size(Metadata_short,2)
    clear criteria_struct
    criteria_struct.subject = Metadata_short(ientry).subject;
    criteria_struct.session = Metadata_short(ientry).session;
    pairs = Metadata_Find_Entries_By_Criteria(Metadata_short,criteria_struct);
    
    if length(pairs)==2 % only if there is a paring
        for ipair = 1:2
            if max(entries_matched==pairs(ipair))==0
                eval(['file_pairs_' Metadata_short(pairs(1)).subject_type '.' Metadata_short(pairs(ipair)).run_intention '(end+1) = ' num2str(pairs(ipair)) ';'])
                entries_matched = [entries_matched pairs(ipair)];
            end
        end
    else
        warning(['No paring found for ' Metadata_short(pairs(1)).subject ' S' Metadata_short(pairs(1)).session ' ' Metadata_short(pairs(1)).run_intention])
    end
end

num_subjects_AB = size(file_pairs_AB.Attempt,2);
num_subjects_SCI= size(file_pairs_SCI.Attempt,2);

% For Hard Coding
% for ientry =1:size(Metadata_short,2)
%     disp([num2str(ientry) ' ' Metadata_short(ientry).subject ' s' Metadata_short(ientry).session ' ' Metadata_short(ientry).run_intention])
% end


%% Find Peak Sensor-set

best_sensors_possibilties = DEF_MEG_sensors_sensorimotor_left_hemi;
best_sensor_groups = sensors2sensorgroupidx([],best_sensors_possibilties); % NOTE: Assumes all sensor groups

% AB Attempt 
for isubject = 1:num_subjects_AB
    mod_AB_Attempt(:,isubject) = moddepth_by_sensor_set(best_sensor_groups,file_pairs_AB.Attempt(isubject));
    % now look for max, and record electrode #
end
eval(['[best_AB_Attempt,best_idx]=' best_min_or_max '(mod_AB_Attempt);'])
best_AB_Attempt_sensor_groups=best_sensor_groups(best_idx);

% AB Imagine
for isubject = 1:num_subjects_AB
    mod_AB_Imagine(:,isubject) = moddepth_by_sensor_set(best_sensor_groups,file_pairs_AB.Imagine(isubject));
    % now look for max, and record electrode #
end
eval(['[best_AB_Imagine,best_idx]=' best_min_or_max '(mod_AB_Imagine);'])
best_AB_Imagine_sensor_groups=best_sensor_groups(best_idx);

% SCI Attempt
for isubject = 1:num_subjects_SCI
    mod_SCI_Attempt(:,isubject) = moddepth_by_sensor_set(best_sensor_groups,file_pairs_SCI.Attempt(isubject));
    % now look for max, and record electrode #
end
eval(['[best_SCI_Attempt,best_idx]=' best_min_or_max '(mod_SCI_Attempt);'])
best_SCI_Attempt_sensor_groups=best_sensor_groups(best_idx);

% SCI Imagine
for isubject = 1:num_subjects_SCI
    mod_SCI_Imagine(:,isubject) = moddepth_by_sensor_set(best_sensor_groups,file_pairs_SCI.Imagine(isubject));
    % now look for max, and record electrode #
end
eval(['[best_SCI_Imagine,best_idx]=' best_min_or_max '(mod_SCI_Imagine);'])
best_SCI_Imagine_sensor_groups=best_sensor_groups(best_idx);


%% Avg Topography

fig_head=figure;hold all;set(fig_head,'Tag',fig_tag); 

% AB Attempt
current_moddepth = mean(moddepth_by_sensor_set(:,file_pairs_AB.Attempt),2);
current_sensor_group = best_AB_Attempt_sensor_groups;
subplot(2,2,1);hold all
Plot_MEG_head_plot(mean(current_moddepth,2),1,[1:3:306],[],[],fig_head);% NOTE: Assumes all sensor groups
caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
% Plot peak sensor locations 
Plot_MEG_chan_locations(sensorgroup2sensor(current_sensor_group)','MarkerType',0,'Color','none','fig',fig_head); % 2013-08-13
% current_pos = sensorgroup2pos(current_sensor_group);
% plot(mean(current_pos(:,1)),mean(current_pos(:,2)),'.r')
colorbar_with_label('SD Move vs. Rest','EastOutside');
title('AB Attempt')

% SCI Attempt
current_moddepth = mean(moddepth_by_sensor_set(:,file_pairs_SCI.Attempt),2);
current_sensor_group = best_SCI_Attempt_sensor_groups;
subplot(2,2,2);hold all
Plot_MEG_head_plot(mean(current_moddepth,2),1,[1:3:306],[],[],fig_head); % NOTE: Assumes all sensor groups
caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
% Plot peak sensor locations 
Plot_MEG_chan_locations(sensorgroup2sensor(current_sensor_group)','MarkerType',0,'Color','none','fig',fig_head); % 2013-08-13
% current_pos = sensorgroup2pos(current_sensor_group);
% plot(mean(current_pos(:,1)),mean(current_pos(:,2)),'.r')
colorbar_with_label('SD Move vs. Rest','EastOutside');
title('SCI Attempt')

% AB Imagine
current_moddepth = mean(moddepth_by_sensor_set(:,file_pairs_AB.Imagine),2);
current_sensor_group = best_AB_Imagine_sensor_groups;
subplot(2,2,3);hold all
Plot_MEG_head_plot(mean(current_moddepth,2),1,[1:3:306],[],[],fig_head); % NOTE: Assumes all sensor groups
% Plot peak sensor locations 
Plot_MEG_chan_locations(sensorgroup2sensor(current_sensor_group)','MarkerType',0,'Color','none','fig',fig_head); % 2013-08-13
% current_pos = sensorgroup2pos(current_sensor_group);
% plot(mean(current_pos(:,1)),mean(current_pos(:,2)),'.r')
caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
colorbar_with_label('SD Move vs. Rest','EastOutside');
title('AB Imagine')

% SCI Imagine
current_moddepth = mean(moddepth_by_sensor_set(:,file_pairs_SCI.Imagine),2);
current_sensor_group = best_SCI_Imagine_sensor_groups;
subplot(2,2,4);hold all
Plot_MEG_head_plot(mean(current_moddepth,2),1,[1:3:306],[],[],fig_head); % NOTE: Assumes all sensor groups
% Plot peak sensor locations 
Plot_MEG_chan_locations(sensorgroup2sensor(current_sensor_group)','MarkerType',0,'Color','none','fig',fig_head); % 2013-08-13
% current_pos = sensorgroup2pos(current_sensor_group);
% plot(mean(current_pos(:,1)),mean(current_pos(:,2)),'.r')
caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
colorbar_with_label('SD Move vs. Rest','EastOutside');
title('SCI Imagine')

Figure_Stretch(1.5,1.5)
Figure_Position(0.7,1)
title_figure(['Avg w/ peak sensors [' num2str(min(freq_range_ideal)) '-' num2str(max(freq_range_ideal)) 'Hz]'])


%% Attempt - Imagine
% *GOOD* 2013-06-27
% 
% for isubject = 1:num_subjects_AB
%     mod_change_AB(:,isubject) = moddepth_by_sensor_set(:,file_pairs_AB.Attempt(isubject))-moddepth_by_sensor_set(:,file_pairs_AB.Imagine(isubject));
% end
% for isubject = 1:num_subjects_SCI
%     mod_change_SCI(:,isubject) = moddepth_by_sensor_set(:,file_pairs_SCI.Attempt(isubject))-moddepth_by_sensor_set(:,file_pairs_SCI.Imagine(isubject));
% end
% 
% fig_head=figure;hold all;set(fig_head,'Tag',fig_tag); 
% 
% current_moddepth = mod_change_AB;
% subplot(1,2,1);hold all
% Plot_MEG_head_plot(mean(current_moddepth,2),1,[1:3:306],[],[],fig_head); % NOTE: Assumes all sensor groups
% %Plot_MEG_chan_locations(DEF_MEG_sensors_sensorimotor,0,[],fig_head);
% caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
% colorbar_with_label('SD Move vs. Rest','EastOutside');
% title('AB')
% 
% current_moddepth = mod_change_SCI;
% subplot(1,2,2);hold all
% Plot_MEG_head_plot(mean(current_moddepth,2),1,[1:3:306],[],[],fig_head); % NOTE: Assumes all sensor groups
% %Plot_MEG_chan_locations(DEF_MEG_sensors_sensorimotor,0,[],fig_head);
% caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
% colorbar_with_label('SD Move vs. Rest','EastOutside');
% title('SCI')
% Figure_Stretch(1.5,1)
% Figure_Position(0.7,1)
% title_figure(['Attempt - Imagine [' num2str(min(freq_range_ideal)) '-' num2str(max(freq_range_ideal)) 'Hz]'])


%% AB vs. SCI

fig_head=figure;hold all;set(fig_head,'Tag',fig_tag); 

current_moddepth = mean(moddepth_by_sensor_set(:,file_pairs_SCI.Attempt(isubject)),2)-mean(moddepth_by_sensor_set(:,file_pairs_AB.Attempt(isubject)),2);
subplot(1,2,1);hold all
Plot_MEG_head_plot(mean(current_moddepth,2),1,[1:3:306],[],[],fig_head); % NOTE: Assumes all sensor groups
%Plot_MEG_chan_locations(DEF_MEG_sensors_sensorimotor,0,[],fig_head);
caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
colorbar_with_label('SD Move vs. Rest','EastOutside');
title('Attempt')

current_moddepth = mean(moddepth_by_sensor_set(:,file_pairs_SCI.Imagine(isubject)),2)-mean(moddepth_by_sensor_set(:,file_pairs_AB.Imagine(isubject)),2);
subplot(1,2,2);hold all
Plot_MEG_head_plot(mean(current_moddepth,2),1,[1:3:306],[],[],fig_head); % NOTE: Assumes all sensor groups
%Plot_MEG_chan_locations(DEF_MEG_sensors_sensorimotor,0,[],fig_head);
caxis_center(maxmag([maxmag(get(gca,'CLim')),1]));
colorbar_with_label('SD Move vs. Rest','EastOutside');
title('Imagine')
Figure_Stretch(1.5,1)
Figure_Position(0.7,1)
title_figure(['SCI-AB [' num2str(min(freq_range_ideal)) '-' num2str(max(freq_range_ideal)) 'Hz]'])

%% Compare mod depth

fig_bar=figure;hold all;set(fig_bar,'Tag',fig_tag); 
Plot_QuantileBar({best_AB_Attempt; best_SCI_Attempt; NaN ; best_AB_Imagine; best_SCI_Imagine}',{'AB','SCI',' ','AB','SCI'},fig_bar);
ylabel('Modulation Depth (STD)')
if strcmp(best_min_or_max,'min')
    set(gca,'YDir','reverse');
end
axis_lim(0,'y')
title(['Mod Depth [' num2str(min(freq_range_ideal)) '-' num2str(max(freq_range_ideal)) 'Hz]'])

% *GOOD* compares SCI-attempt to others
% % compare SCI-attempt to 
% figure;hold all
% bar([mean(best_SCI_Attempt)-mean(best_AB_Attempt); mean(best_SCI_Attempt)-mean(best_AB_Imagine)]','FaceColor','k','EdgeColor','k','LineWidth',2)
% ylabel('Differenece from SCI Attempt (STD)')
% title(['Modeling SCI attempt w/ AB [' num2str(min(freq_range_ideal)) '-' num2str(max(freq_range_ideal)) 'Hz]'])
% set(gca,'YDir','reverse');
% set(gca,'XTick',[1 2])
% set(gca,'XTickLabel',{'Attempt-AB','Imagine-AB'})
% set(gca,'FontSize',12)

try 
[~,p]=ttest(best_AB_Attempt, best_SCI_Attempt)
[~,p]=ttest(best_AB_Imagine, best_SCI_Attempt)
[~,p]=ttest(best_AB_Imagine, best_SCI_Imagine)

[~,p]=ttest2(best_AB_Attempt, best_AB_Imagine)
[~,p]=ttest2(best_SCI_Attempt, best_SCI_Imagine)
end

%% Laterality

% *GOOD* but now put on topography
% fig_head = figure;
% subplot(2,2,1);hold all;
% current_sensor_group = best_AB_Attempt_sensor_groups;
% Plot_MEG_chan_locations(current_sensor_group'*3,0,[],fig_head);Plot_MEG_Helmet(fig_head); 
% current_pos = sensorgroup2pos(current_sensor_group);
% plot(mean(current_pos(:,1)),mean(current_pos(:,2)),'.r')
% title('AB Attempt')
% 
% subplot(2,2,2);hold all;
% current_sensor_group = best_AB_Imagine_sensor_groups;
% Plot_MEG_chan_locations(current_sensor_group'*3,0,[],fig_head);Plot_MEG_Helmet(fig_head); 
% current_pos = sensorgroup2pos(current_sensor_group);
% plot(mean(current_pos(:,1)),mean(current_pos(:,2)),'.r')
% title('AB Imagine')
% 
% subplot(2,2,3);hold all;
% current_sensor_group = best_SCI_Attempt_sensor_groups;
% Plot_MEG_chan_locations(current_sensor_group'*3,0,[],fig_head);Plot_MEG_Helmet(fig_head); 
% current_pos = sensorgroup2pos(current_sensor_group);
% plot(mean(current_pos(:,1)),mean(current_pos(:,2)),'.r')
% title('SCI Attempt')
% 
% subplot(2,2,4);hold all;
% current_sensor_group = best_SCI_Imagine_sensor_groups;
% Plot_MEG_chan_locations(current_sensor_group'*3,0,[],fig_head);Plot_MEG_Helmet(fig_head); 
% current_pos = sensorgroup2pos(current_sensor_group);
% plot(mean(current_pos(:,1)),mean(current_pos(:,2)),'.r')
% title('SCI Imagine')

pos_AB_Imagine = sensorgroup2pos(best_AB_Imagine_sensor_groups);
pos_SCI_Imagine = sensorgroup2pos(best_SCI_Imagine_sensor_groups);
pos_SCI_Attempt = sensorgroup2pos(best_SCI_Attempt_sensor_groups);
pos_AB_Attempt = sensorgroup2pos(best_AB_Attempt_sensor_groups);

fig_bar=figure;hold all;set(fig_bar,'Tag',fig_tag); 
Plot_QuantileBar({pos_AB_Attempt(:,1) pos_SCI_Attempt(:,1) NaN pos_AB_Imagine(:,1) pos_SCI_Imagine(:,1)},{'AB','SCI',' ','AB','SCI'},fig_bar);
set(gca,'YDir','reverse');
set(gca,'YTick',[min(get(gca,'YLim')) 0])
set(gca,'YTickLabel',{'Lateral','Medial'})
title(['Laterality [' num2str(min(freq_range_ideal)) '-' num2str(max(freq_range_ideal)) 'Hz]'])

% *GOOD* compares SCI-attempt to others
% Plot_QuantileBar({mean(pos_SCI_Attempt(:,1))-mean(pos_AB_Attempt(:,1)) mean(pos_SCI_Attempt(:,1))-mean(pos_AB_Imagine(:,1))},{'Attempt-AB','Imagine-AB'});
% set(gca,'YTick',[0 7])
% set(gca,'YTickLabel',{'Same','Lateral'})
% title(['Modeling SCI attempted w/ AB [' num2str(min(freq_range_ideal)) '-' num2str(max(freq_range_ideal)) 'Hz]'])

% Plot_QuantileBar({mean(pos_AB_Attempt(:,1))-mean(pos_AB_Imagine(:,1)) mean(pos_SCI_Attempt(:,1))-mean(pos_SCI_Imagine(:,1))},{'AB','SCI'});


%% Y Pos

% Is it approprate do to find peak/center of mass with interpolation?


%% SAVE FIGURES

if save_fig_flag
    Save_Fig_wTag(fig_tag);
end