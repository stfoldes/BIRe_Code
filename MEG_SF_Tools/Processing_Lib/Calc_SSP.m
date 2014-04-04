% [ssp_components, ssp_projector] = Calc_SSP(MEG_data,events_list,data_rate,artifact_type_str);
% Calculates components that represent artifacts that are centered at events_list
% Includes Interactive plots to select components
% These components can be added with other artifact-components and turned into projector to remove artifacts
%     see: Calc_SSP_Filters.m
%     ssp_projector = eye(size(ssp_components,1)) - (ssp_components*ssp_components');
%
% INPUTS
%     MEG_data: [time x sensor(306)] All MEG data
%     events_list: indicies of artifact centers (see GUI_Auto_Event_Markers.m)
%     data_rate: 1000Hz
%     artifact_type_str: 'blink' or 'cardiac' (for now)
%     sensor_names [OPTIONAL]: Used for inspection of filtering (SEE: Plot_Inspect_TimeSeries_Signals), looking for MEG2443 format from Load_MEG
%
% OUTPUTS
%     ssp_components: [sensors x components]
%     ssp_projector: [sensors x sensors] can be used to remove just these components
%
% EXAMPLE
%     % Data Look Up Info
%     clear criteria_struct
%     criteria_struct.subject = 'NC03';
%     criteria_struct.run_type = 'Open_Loop_MEG';
%     criteria_struct.run_task_side = 'Right';
%     criteria_struct.run_action = 'Grasp';
%     criteria_struct.run_intention = 'Attempt';
%
%     % Load Metadata for file
%     server_base_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
%     local_base_path = '/home/foldes/Data/MEG/';
%     metadatabase_base_path = server_base_path;
%     metadatabase_location=[metadatabase_base_path filesep 'Neurofeedback_metadatabase.txt'];
%     Metadata = Metadata_Class();
%     Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);
%     [metadata_entry] = Metadata_Get_Entry(Metadata,criteria_struct);
%     Extract.file_type='sss';
%     Extract.data_path_default = local_base_path;
%     Extract = Prep_Extract_w_Metadata(Extract,metadata_entry);
%
%     % Load Data and Events
%     [MEG_data,TimeVecs.timeS] = Load_from_FIF(Extract,'MEG');
%     load([server_base_path filesep metadata_entry.subject filesep 'S' metadata_entry.session filesep metadata_entry.Preproc.Pointer_Events]);
%
%     % Computer SSP
%     ssp_components_blink = Calc_SSP(MEG_data,Events.blink,Extract.data_rate,'blink');
%     ssp_components_cardiac = Calc_SSP(MEG_data,Events.cardiac,Extract.data_rate,'cardiac');
%     ssp_projector = Calc_SSP_Filters([ssp_components_blink ssp_components_cardiac]);
%
%     % Apply SSP
%     data_clean = (ssp_projector*MEG_data')';
%
% Foldes 2013-04-24
% UPDATES:
% 2013-08-26 Foldes: Cleaned up, added sensor_names

function [ssp_components, ssp_projector] = Calc_SSP(MEG_data,events_list,data_rate,artifact_type_str,sensor_names)
% DEFAULTS

% No events provided, quit
if isnan(events_list)
    warning('No Events Provided @Calc_SSP')
    ssp_components=[];
    ssp_projector=[];
    return
end

% Paramters for filting and window sizes (from BrainStorm?)
switch artifact_type_str
    case 'blink'
        freqs = [1.5 15];
        event_windowS = 0.400;
    case 'cardiac'
        freqs = [10 40];
        event_windowS = 0.080;
end

if ~exist('sensor_names') || isempty(sensor_names)
    for ichan = 1:size(MEG_data,2)
        sensor_names{ichan} = num2str(ichan);
    end
end
if ~iscell(sensor_names)
    sensor_names_str = sensor_names;
    clear sensor_names
    for ichan = 1:size(MEG_data,2)
        sensor_names{ichan} = sensor_names_str(ichan,:);
    end
end

% bandpass filter to given range (TAXING)
disp('CALCULATING: band-pass filter of sensors')
clear filter_b filter_a
Wn=freqs/(data_rate/2);
[filter_b,filter_a] = butter(4,Wn); % 4th order butterworth filter
MEG_filt=filtfilt(filter_b,filter_a,MEG_data);

%% Calculate SSP

% Parse MEG data around event
event_window=floor(event_windowS*data_rate);
event_window_half=floor(event_window/2);
data_by_event = zeros(event_window_half*2,size(MEG_filt,2),length(events_list));
data_by_event_flat=[];
for ievent = 1:length(events_list)
    data_by_event(:,:,ievent) = MEG_filt(events_list(ievent)-event_window_half+1:events_list(ievent)+event_window_half,:);
    data_by_event_flat = [data_by_event_flat;data_by_event(:,:,ievent)];
end

% SVD decomposition
disp('CALCULATING: SVD decomposition')
[U,S,V] = svd(data_by_event_flat', 'econ');

% Component Contribution (% of total)
contribution = diag(S)./sum(diag(S));
% figure;bar(100*contribution);
% xlim([1 30])
% ylabel('% of Contribution')
% xlabel('Component number')

%% Select SSP Components

num_components_high = max(sum(contribution>=0.05),8); % Only show components with >5% contribution, or 8

% Parse out MEG data around event
event_windowS = 0.5;
event_window=floor(event_windowS*data_rate);
event_window_half=floor(event_window/2);
data_by_event = zeros(event_window_half*2,size(MEG_filt,2),length(events_list));
data_for_inspection=[];
for ievent = 1:length(events_list)
    data_by_event(:,:,ievent) = MEG_filt(events_list(ievent)-event_window_half+1:events_list(ievent)+event_window_half,:);
    data_for_inspection = [data_for_inspection;data_by_event(:,:,ievent)];
    ssp_by_events(:,:,ievent) = MEG_filt(events_list(ievent)-event_window_half+1:events_list(ievent)+event_window_half,:)*(U(:,[1:num_components_high]));
end

ssp_components_top = data_for_inspection*(U(:,[1:num_components_high]));

while 1 % keep looping until user is happy
    
    % Plot distributions
    fig=figure;hold all
    for issp=1:size(ssp_by_events,2)
        Plot_Variance_as_Patch([-(size(ssp_by_events,1)/2):(size(ssp_by_events,1)/2)-1].*(1/data_rate),(4*(issp-1))+squeeze(zscore(ssp_by_events(:,issp,:))),...
            'variance_method','quantile','fig',fig,'patch_alpha',1);
        plot([-(size(ssp_by_events,1)/2):(size(ssp_by_events,1)/2)-1].*(1/data_rate),(4*(issp-1))+median(squeeze(zscore(ssp_by_events(:,issp,:))),2),'k')
    end
    Plot_VerticalMarkers(0);
    xlim([-(size(ssp_by_events,1)/2),(size(ssp_by_events,1)/2)-1].*(1/data_rate))
    xlabel('Time [S]')
    set(gca,'YTick',(4*([1:size(ssp_by_events,2)]-1)))
    set(gca,'YTickLabel',[1:size(ssp_by_events,2)])
    ylabel('SSP Component')
    title(['Distribtuion for ' artifact_type_str '(Interquartile Range)'])
    Figure_Stretch(2,1.5)
    Figure_Position(1)
    Figure_TightFrame
    
    
    % Show how SSPs affect event data
    event_centers = [event_window_half:event_window_half*2:size(ssp_components_top,1)];
    
    [Marks,save_flag]=Plot_Inspect_TimeSeries_Signals(ssp_components_top,[0:size(ssp_components_top,1)-1].*(1/data_rate),[],find(contribution>=0.10),event_centers,'Select SSP Components (Pre-Red components have a >10% contribution)');
    
    if save_flag && ~isempty(Marks.signals_idx)
        ssp_components = U(:,Marks.signals_idx);
    else % user was NOT happy
        warning('No SSPs Selected @Calc_SSP')
        ssp_components=[];
        ssp_projector=[];
        return
    end
    
    ssp_projector = eye(size(ssp_components,1)) - (ssp_components*ssp_components');
    data_clean = (ssp_projector*data_for_inspection')';
    % mix clean and unclean
    clear data4plot signal_marks sensor_names_double
    cnt = 0;
    for ichan = 1:size(data_clean,2)
        cnt=cnt+1;
        data4plot(:,cnt) = data_for_inspection(:,ichan);
        signal_marks(cnt) = 0;
        sensor_names_double{cnt} = sensor_names{ichan};

        cnt=cnt+1;
        data4plot(:,cnt) = data_clean(:,ichan);
        signal_marks(cnt) = 1;
        sensor_names_double{cnt} = sensor_names{ichan};
    end
    
    [~,save_flag]=Plot_Inspect_TimeSeries_Signals(zscore(data4plot),[0:size(ssp_components_top,1)-1].*(1/data_rate),sensor_names_double,find(signal_marks==1),event_centers,'Affect of SSP (q=redo): Red = CLEAN');
    pause(0.1)
    
    if (save_flag==1) % user was happy
        try
            close(fig)
        end
        break
    end
    

end % while loop

