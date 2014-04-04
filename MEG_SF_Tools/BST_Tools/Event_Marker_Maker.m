% This will load a FIF file, process MISC, STI, EMG, and save it back out as a FIF file

% Function loads a fif file, takes the MISC, STI, EMG, and EOG data out, process it some, and then lets the user select points for different events
% Eventually this information needs to be 


% function ? = Event_Marker_Maker(Extract,Save_Out_FIF_Flag)

clear
% Metadata = Metadata_Extractor('Neurofeedback_metadata.txt');
% Extract.file_type = 'fif';
% % Extract = Prep_Extract_w_Metadata_Simple(Extract,Metadata,'subject','NC03','session','01','run_type','Right_Grasp_Attempt');
% Extract = Prep_Extract_w_Metadata_Simple(Extract,Metadata,'file_base_name','ns03s01r05');
% Extract.data_rate=1000;

Extract.paradigm_type='Open_Loop_MEG';
Extract.data_rate=1000;
Extract.file_path='/home/foldes/Data/MEG/NS07/S01/';
Extract.file_name{1}='ns07s01r08';

% Prep_Extract_w_basic_info


        %% ---REQUIRED INPUT INFORMATION---

%         results_file_name ='Neurofeedback_Results';
% %         metadata_criteria.run_type={'Right_Grasp_Imitate', 'Right_Grasp_Observe','Right_Grasp_Attempt','Right_Grasp_Imagine'};
%         metadata_criteria.run_type={'Left_Grasp_Imitate'};
%         metadata_criteria.subject='NS02';
%         
%         Extract.file_type='fif';
%         
%         % Basic info               
%         Metadata= Metadata_Extractor('Neurofeedback_metadata.txt');       
%                 
%         metadata_entry_idx = Metadata_Find_Entries_By_Criteria(Metadata,metadata_criteria); % NEEDED FOR LOOPING FILES (maybe change to a WHILE loop)
%         disp(['Found ' num2str(length(metadata_entry_idx)) ' files to process'])




%% Go through all files and mark data        
%    redo_flag=0;
%     while redo_flag = 0;
        
        
        % Experimental Defintions (needed for auto moving of selection plot)
        ExpDefs.paradigm_type=Extract.paradigm_type; % Use Extract.paradigm_type in auto populating
        ExpDefs.data_rate=Extract.data_rate; %NEEDED? in Prep_TargetCode for now
        ExpDefs=Prep_ExpDefs(ExpDefs);
        
%         AnalysisParms.event_marker_type = 'manual';
%         
%         
%         %% Preping Results
%         
%         % load up the Results stuff
%         load(results_file_name);
%         results_entry_num=Metadata_find_idx(Results,'file_base_name',Extract.file_base_name);
%         
%         % Check if you need to overwrite
%         if ~isempty(results_entry_num) && isfield(Results{results_entry_num}.Event_Markers,AnalysisParms.event_marker_type)
%             if strcmp(questdlg(['Overwrite Event Marker type: ' AnalysisParms.event_marker_type ' for file ' Extract.file_base_name '?'],'OVERWRITE?','Yes','No','Yes'),'No')               
%                 redo_flag=0;
%                 continue
%             end
%         end
%%  Extract non-MEG data

    fif_file = fiff_setup_read_raw([Extract.file_path Extract.file_name{1} '.fif']);
    % Channels by type
    MEG_chan_list=[]; EMG_chan_list=[]; EOG_chan_list=[]; STI_chan_list=[];MISC_chan_list=[];
    for ichan = 1:size(fif_file.info.ch_names,2)
        if strcmp(fif_file.info.ch_names{ichan}(1:3),'MEG')
            MEG_chan_list = [MEG_chan_list, ichan];
        elseif strcmp(fif_file.info.ch_names{ichan}(1:3),'EMG')
            EMG_chan_list = [EMG_chan_list, ichan];
        elseif strcmp(fif_file.info.ch_names{ichan}(1:3),'EOG')
            EOG_chan_list = [EOG_chan_list, ichan];
        elseif strcmp(fif_file.info.ch_names{ichan}(1:3),'STI')
            STI_chan_list = [STI_chan_list, ichan];
        elseif strcmp(fif_file.info.ch_names{ichan}(1:4),'MISC')
            MISC_chan_list = [MISC_chan_list, ichan];
        end
    end

    % Get All non-MEG data
    clear All_data
    [All_data,FIF_TimeS]=fiff_read_raw_segment(fif_file,fif_file.first_samp,fif_file.last_samp,[EMG_chan_list STI_chan_list MISC_chan_list EOG_chan_list]);

    % Separate EMG
    clear EMG_data
    EMG_data = All_data(1:length(EMG_chan_list),:)';
    All_data(1:length(EMG_chan_list),:)=[];
    % Separate STI
    clear STI_data
    STI_data = All_data(1:length(STI_chan_list),:)';
    All_data(1:length(STI_chan_list),:)=[];
    % Separate MISC
    clear MISC_data
    MISC_data = All_data(1:length(MISC_chan_list),:)';
    All_data(1:length(MISC_chan_list),:)=[];
    % Separate EOG
    clear EOG_data
    EOG_data = All_data(1:length(EOG_chan_list),:)';
    All_data(1:length(EOG_chan_list),:)=[];
    clear All_data

%%  Process EMG and MISC
        [EMG_data_processed] = Calc_Processed_EMG(EMG_data,Extract.data_rate);        
        [MISC_data_processed] = Calc_Processed_EMG(MISC_data,Extract.data_rate);

%% Process STI
        % For me, STI101 is all that matters
        STI_data = STI_data(:,1);
        % B/C OF MEG-PARALLEL PORT, SOME HIGH VALUES ARE SEEN IN TRIAL DATA, THIS REMOVES THE TARGET-CHANGE-ARTIFACT
        [TimeVecs.target_code_org]= RemoveStrays(STI_data);
        TimeVecs.data_rate = Extract.data_rate;
        TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
        % remove the 255s from target code for viewing
        STI_data = remove_pport_trigger_from_CRX_startstop(TimeVecs.target_code_org); % 2013-07-03
                
        % Figure out ideal trial break up
        trial_transitions=TrialTransitions(TimeVecs.target_code);
        block_start_ideal_idx = trial_transitions(find(TimeVecs.target_code(trial_transitions)==ExpDefs.target_code.block_start));
        move_start_ideal_idx = trial_transitions(find(TimeVecs.target_code(trial_transitions)==ExpDefs.target_code.move));
        rest_start_ideal_idx = trial_transitions(find(TimeVecs.target_code(trial_transitions)==ExpDefs.target_code.rest));
        
        %% PLOT
        fig=figure;hold all
        
        plot_entry = 0;
        plot(FIF_TimeS,zscore(STI_data_processed),'--k','LineWidth',3) % Trigger
        for ientry = 1:size(MISC_data_processed,2)
            plot_entry = plot_entry+1;
            plot([minmax(FIF_TimeS)],[0 0]-(plot_entry*6),'--','Color',0.6*[1 1 1]);
            plot(FIF_TimeS,zscore(MISC_data_processed(:,ientry))-(plot_entry*6),'LineWidth',3) % Acc
        end
        for ientry = 1:size(EMG_data_processed,2)
            plot_entry = plot_entry+1;
            plot([minmax(FIF_TimeS)],[0 0]-(plot_entry*6),'--','Color',0.6*[1 1 1]);
            plot(FIF_TimeS,zscore(EMG_data_processed(:,ientry))-(plot_entry*6),'LineWidth',3) %EMG
        end
        Plot_VerticalMarkers(FIF_TimeS(move_start_ideal_idx),0.6*[1 1 1],'Move')
        Plot_VerticalMarkers(FIF_TimeS(rest_start_ideal_idx),'r','Rest')
        axis_lim(5,'y','max')
        ylabel('SDs')
        
        xlabel('Time[S]')
        legend('Trigger')
        itrial=1;
        xlim([FIF_TimeS(block_start_ideal_idx(itrial))-20 FIF_TimeS(rest_start_ideal_idx(itrial))+30])
%         title({['Trial # ' num2str(itrial)];[Extract.subject ' S' Extract.session ' ' Extract.run_type];'Select Events: 1st move start & rest start'},'FontSize',14)

        % set full screen (if you have two screens)
        set(fig,'units','normalized','outerposition',[0 0 0.48 1])
        set(gca,'LooseInset',get(gca,'TightInset'));
        
        
%% Now overwrite fif file with processed data


events(1).label = 'Trigger_Move';
events(1).times = FIF_TimeS(move_start_ideal_idx);
events(1).color = [0 1 0];

events(2).label = 'Trigger_Rest';
events(2).times = FIF_TimeS(rest_start_ideal_idx);
events(2).color = [1 0 0];

events(3).label = 'Trigger_Block_Start';
events(3).times = FIF_TimeS(block_start_ideal_idx);
events(3).color = [0 0 1];

events = Export_Event_File(events,[Extract.file_path Extract.file_name{1}],Extract.data_rate);




%%
        
        
        
        
%         
%         
%         
%         %% Select points
%         clear first_moves_idx rest_start_idx
%         
%         num_markers = 20;
%         first_moves_cnt=0;rest_start_cnt=0;
%         for imarker = 1:num_markers
%             
%             [x,y,button]=ginput(1); % could do different buttons, but whatever.
%             first_moves_cnt=first_moves_cnt+1;
%             first_moves_idx(first_moves_cnt)=x;
%             try;plot(first_moves_idx,zeros(size(first_moves_idx)),'.g','MarkerSize',20);end
%             
%             [x,y,button]=ginput(1);
%             rest_start_cnt=rest_start_cnt+1;
%             rest_start_idx(rest_start_cnt)=x;
%             try;plot(rest_start_idx,zeros(size(rest_start_idx)),'.r','MarkerSize',20);end
% 
%             % ***I COULD SHOULD EMG-GUESS AND AN ENTER KEY PRESS WOULD ACCEPT IT***
%             
%             % Change graph every other mark
%             if mod(imarker,2)==0 && length(block_start_ideal_idx)>=itrial+1
%                 itrial=itrial+1;
%                 xlim([block_start_ideal_idx(itrial)-2000 rest_start_ideal_idx(itrial)+3000])
%                 title({['Trial # ' num2str(itrial)];[Extract.subject ' S' Extract.session ' ' Extract.run_type];'Select Events: 1st move start & rest start'},'FontSize',14)
%             end            
%         end
%         
%         xlim('auto')
%         pause(2); close(fig)
%         
% %% Saving        
%         % save Prep
%         clear TrialInfo
%         TrialInfo.first_moves_idx = floor(first_moves_idx);
%         TrialInfo.rest_start_idx = floor(rest_start_idx);
%         
%         eval([AnalysisParms.event_marker_type '_time_stamp = datestr(now,''YYYY-mm-dd HH:MM:SS'');'])
%         eval([AnalysisParms.event_marker_type '=TrialInfo;'])
%         
%         % Ask if they want to save
%         response = questdlg(['Save These Results for ' Extract.file_base_name '?'],'Save?','Save','Redo','Skip','Save');
%         if isempty(response)
%             return
%         end
%         switch response
%             case 'Save'
%                 Results_Save(results_file_name,Metadata(current_metadata_entry_idx),'Event_Markers',1,AnalysisParms.event_marker_type,[AnalysisParms.event_marker_type '_time_stamp']);
%                 redo_flag=0;
%             case 'Redo'
%                 redo_flag = 1;
%             case 'Skip'
%                 redo_flag=0;
%         end
%         
% %     end % all files
%         
%         
%         
%         
%         
%         
%         
%         
%         
%         
%         
%                            
% %                 case 'photodiode' % based off of photodiode and then estimated timing for each movement.
% % 
% %                     load(results_file_name);
% %                     results_entry_num=Metadata_find_idx(Results,'file_base_name',Extract.file_base_name);
% %   
% %                         [diode_offset,diode_onset,diode_processed]=Calc_Photodiode_Change_FIFtimeS(Extract);
% %                                          
% % %                         choose shit
% %                         
% %                         
% %                         % Markers for movement-cue onset based off of photodiode trigger
% %                         relative_movement_onset_timeS = ([1:9]*2)+0; % in seconds
% %                         
% %                         movement_onsetS=[];
% %                         for itrial = 1:length(diode_offset)
% %                             movement_onsetS = [movement_onsetS diode_offset(itrial)+relative_movement_onset_timeS];
% %                         end
% %                         
% %                         %     figure;hold all
% %                         %     plot(diode_processed.FIF_sample_idx,Normalize(diode_processed.photodiode),'Color',0.8*[1 1 1])
% %                         %     plot(diode_processed.FIF_sample_idx,Normalize(diode_processed.diode_processed),'k','LineWidth',5)
% %                         %     plot(diode_onset,ones(size(diode_onset)),'*g')
% %                         %     plot(diode_offset,ones(size(diode_offset)),'*r')
% %                         %     plot(movement_onsetS,ones(size(movement_onsetS)),'.r')
% %                         %     plot(50+TrialInfo.timeseries_event_start_idx/1000,ones(size(TrialInfo.timeseries_trial_start_idx))-.5,'.b')
% %                         %     legend('Photodiode','Processed','Onset','Offset')
% % 
% %                         diode_change = sort([diode_offset; diode_onset; movement_onsetS']);
% %                         clear diode_change_sample
% %                         for itrial=1:length(diode_change)
% %                             diode_change_sample(itrial,1) = find(diode_processed.FIF_sample_idx>=diode_change(itrial),1,'first');
% %                         end
% %                         
% %                         TrialInfo.timeseries_trial_start_idx = diode_change_sample;
% %                         
% %                         % save 
% %                         [AnalysisParms.trial_marker_type '_time_stamp'] = 
% %                         eval([AnalysisParms.trial_marker_type '=TrialInfo.timeseries_trial_start_idx;'])
% %                         Results_Save(results_file_name,Results{results_entry_num},'Event_Markers',1,AnalysisParms.trial_marker_type,[AnalysisParms.trial_marker_type '_time_stamp']);
% %                         
% %                     end % photodiode
% %                     
% %                 otherwise
% %                     % Use parallel port tiggers
%                     
