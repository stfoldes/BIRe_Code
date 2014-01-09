% Processes: Mark Bad MEG, Event marking, and SSPs
%
% RUN Batch_Process_EMGandAcc_to_File.m first
% MUST RUN AT THE END TO WRITE: DB.save;
%
% SEE: SCRIPT_Status_BadChan_and_MaxFilter
%
% 2013-06-08 Foldes [Branched]
% UPDATES:
% 2013-07-03 Foldes: New way to clean up STI from crx start/stop
% 2013-07-23 Foldes: Cleaned up, ready for use.
% 2013-08-16 Foldes: Upgraded some
% 2013-08-20 Foldes: MEDIUM Mark_Bad_Chans replaced with Mark_Bad_MEG
% 2013-08-20 Foldes: Now saves events initially to Events.Original.X until the bad segments are applied in Calc_Event_Removal_wBadSegments
% 2013-10-08 Foldes: Metadata-->DB, SSP not updated yet


clearvars -except DB
% close all

% ---FLAGS---
Flags.badchans = 1;
Flags.Events = 1;
Flags.SSP = 0;

Flags.badchans_Overwrite = 1;
Flags.Events_Overwrite = 1;
Flags.SSP_Overwrite = 0;

% Choose criteria for data set to analyize
clear criteria
% criteria.subject = 'NS10';
% criteria.run_type = 'Open_Loop_MEG';
% criteria.run_task_side = 'Right';
% criteria.run_action = 'Grasp';
% criteria.run_intention = 'Attempt';
criteria.entry_id = {'ns10s01r03','ns10s01r04'};


%% Load Database

% Build database
if ~exist('DB','var')
    DB=DB_MEG_Class;
    DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

% Chooses the approprate entries
DB_short = DB.get_entry(criteria);

%% Loop for All Entries
fail_list = [];
for ientry = 1:length(DB_short)
    
    DB_entry = DB_short(ientry);
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(DB_short)) ' | ' DB_entry.entry_id '================='])
    
    %     try
    
    %% ----------------------------------------------------------------
    %  -----------------CODE STARTS------------------------------------
    %  ----------------------------------------------------------------
    
    %% Preparing Data Set Info and Analysis-related Parameters
    %---Extraction Info-------------
    Extract.file_type='fif'; % What type of data?
    Extract.file_path = DB_entry.file_path('local');
    Extract.channel_list=[1:306];
    Extract = DB_entry.Prep_Extract(Extract);
    % Copy local (can be used to copy all that match criteria)
    DB_entry.download(Extract.file_name_ending);
    %-------------------------------
    
    % Load Preproc.data
    clear TimeVecs
    TimeVecs.data_rate = Extract.data_rate;
    [TimeVecs.target_code_org,TimeVecs.timeS] = Load_from_FIF(Extract,'STI');
    
    ExpDefs.paradigm_type =DB_entry.run_type;
    ExpDefs=Prep_ExpDefs(ExpDefs);
    TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
    
    %% ===BAD CHANNELS===
    if Flags.badchans==1
        pointer_name = 'Preproc.Pointer_prebadchan';
        
        if Flags.badchans_Overwrite == 0
            % only continue writing if the check is 0
            write_flag = ~pointer_check(DB_entry,pointer_name,'dialog_flag',1);
        else
            write_flag = 1;
        end
        
        % ---Mark Bad Channels---
        if (write_flag == 1)
            prebadchan_file = [DB_entry.file_path('server') filesep DB_entry.Preproc.Pointer_prebadchan];
            event_file = [DB_entry.file_path('server') filesep DB_entry.Preproc.Pointer_Events];
            [save_flag, bad_chan_list, bad_segments] = Mark_Bad_MEG(Extract,prebadchan_file,event_file);
            
            if save_flag == 1
                % Write data to file
                [DB_entry,saved_pointer_flag1] = DB_entry.save_pointer(bad_chan_list,pointer_name,'str2txt',Flags.badchans_Overwrite);
                if exist(event_file)==2 % load the events so you don't overwrite stuff
                    load(event_file);
                end
                Events.bad_segments = bad_segments;
                [DB_entry,saved_pointer_flag2] = DB_entry.save_pointer(Events,'Preproc.Pointer_Events','mat',Flags.badchans_Overwrite);
                
                % Save current DB entry back to database
                if saved_pointer_flag1==1 && saved_pointer_flag2==1
                    DB=DB.update_entry(DB_entry);
                end
            end
        end
        
    end % BAD CHAN
    
    %% ===EVENT MARKING===
    if Flags.Events==1
        clear Events processed_data
        pointer_name = 'Preproc.Pointer_Events';
        
        % Loading of preproc data ***COULD BE BETTER***
        processed_loaded_flag = DB_entry.load_pointer('Preproc.Pointer_processed_data_for_events');
        
        % Preprocessing is needed, so do it now (should have done with Batch_Process_EMGandAcc_to_File)
        if (processed_loaded_flag == -1) || ~isfield(processed_data,'EMG_data')
            warning('Preprocessing will take a while, use Batch_Process_EMGandAcc_to_File.m')
            if ~questdlg_YesNo_logic(['Preprocessing of EMG/ACC is needed and will take a while, CONTINUE?  [Use Batch_Process_EMGandAcc_to_File.m]'],'Preprocess EMG/ACC?')
                write_flag = 0;
            else
                % Calculate time series data that will be used for marking events SLOW
                processed_data=Calc_Processed_EMGandACC(Extract);
                % Save processed data to file & write to DB entry
                [DB_entry,saved_pointer_flag] = DB_entry.save_pointer(processed_data,'Preproc.Pointer_processed_data_for_events','mat',1);
                % Save current DB entry back to database
                if saved_pointer_flag==1
                    DB=DB.update_entry(DB_entry);
                    DB.save_DB;
                end
                write_flag = 1;
            end % ask to do preprocessing of EMG/ACC
        end % need to preprocess
        
        % ===REPLACE SECTION BELOW===
        %Events = Calc_Events('Batch_Preprocessing_wDB',DB_entry);
        
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
            
            % ===END REPLACMENT===
            
            % SAVE OUT NOW (should inspect first)
            [DB_entry,saved_pointer_flag] = DB_entry.save_pointer(Events,pointer_name,'mat',Flags.Events_Overwrite);
            % Save current DB entry back to database
            if saved_pointer_flag==1
                DB=DB.update_entry(DB_entry);
            end
            
        end % marking
    end % EVENTS
    
    %% ===SSP===
    %     if Flags.SSP==1 % SSP after Events
    %         pointer_name = 'Preproc.Pointer_SSP';
    %         eval(['pointer_link = DB_entry.' pointer_name ';']); % Get pointer
    %         pointer_full_path = [DB_entry.file_path(local_path) filesep pointer_link];
    %
    %         % Check if it already exists
    %         write_flag = 1;
    %         if (Flags.Events_Overwrite ~= 1) && (exist(pointer_full_path)==2)
    %             % It already exists, skip?
    %             pointer_date = date_file_timestamp(pointer_full_path);
    %             if questdlg_YesNo_logic([pointer_name ' already exists from ** ' pointer_date ' **, Proceed?'],'POINTER OVERWRITE?')
    %                 write_flag = 1; % yes, overwrite
    %             else % don't overwrite
    %                 write_flag = 0;
    %             end
    %         end
    %
    %         if strcmp(Extract.file_type,'fif')
    %             warning('SSS needs to be run before SSP!')
    %         end
    %
    %         % Load Events, check if blink and cardiac exist
    %         if exist([DB_entry.file_path(local_path) filesep DB_entry.Preproc.Pointer_Events]) == 2
    %             load([DB_entry.file_path(local_path) filesep DB_entry.Preproc.Pointer_Events]);
    %         end
    %
    %         % Calculate Events if they don't already exist
    %
    %         % ===blink===
    %         if ~exist('Events') || ~isfield(Events,'blink')
    %             Events.blink= GUI_Auto_Event_Markers(processed_data.blink_data,TimeVecs.timeS,TimeVecs.target_code,'blink');
    %             [DB_entry,saved_pointer_flag] = DB_Save_Pointer_Data(DB_entry,Events,pointer_name,'mat',local_path,server_path);
    %             if saved_pointer_flag==1
    %                 DB=DB_Update_Entry(DB_entry,DB);
    %             end
    %         end
    %
    %         % ===cardiac===
    %         if ~exist('Events') || ~isfield(Events,'cardiac')
    %             Events.cardiac= GUI_Auto_Event_Markers(processed_data.cardiac_data,TimeVecs.timeS,TimeVecs.target_code,'cardiac');
    %             [DB_entry,saved_pointer_flag] = DB_Save_Pointer_Data(DB_entry,Events,pointer_name,'mat',local_path,server_path);
    %             if saved_pointer_flag==1
    %                 DB=DB_Update_Entry(DB_entry,DB);
    %             end
    %         end
    %
    %         if (write_flag == 1)
    %             [MEG_data] = Load_from_FIF(Extract,'MEG');
    %             % Computer SSP
    %             ssp_components = [];
    %             try; ssp_components = [ssp_components Calc_SSP(MEG_data,Events.blink,Extract.data_rate,'blink')];end
    %             try; ssp_components = [ssp_components Calc_SSP(MEG_data,Events.cardiac,Extract.data_rate,'cardiac')];end
    %
    %             % Save?
    %             if ~isempty(ssp_components)
    %                 if questdlg_YesNo_logic('Save SSP? (NOT SAVED TO DATABASE)','SSP?')
    %                     % Write data to file
    %                     [DB_entry,saved_pointer_flag] = DB_Save_Pointer_Data(DB_entry,ssp_components,'Preproc.Pointer_SSP','mat',local_path,server_path);
    %                     % Save current DB entry back to database
    %                     if saved_pointer_flag==1
    %                         DB=DB_Update_Entry(DB_entry,DB);
    %                     end
    %                 end
    %             end
    %         end
    %
    %     end % SSP
    
    
    
    %     catch
    %         disp('***************************************')
    %         disp(['******* FAIL: ' DB_entry.entry_id ' **************'])
    %         disp('***************************************')
    %         msgbox_wPosition([0.6 1],['FAIL: ' DB_entry.run_info ' (' DB_entry.entry_id ')'])
    %         fail_list = [fail_list DB_short(ientry)];
    %     end
end

if ~isempty(DB_short)
    DB.save_DB;
    
    pointer_name = 'Preproc.Pointer_Events';
    DB_Report_Property_Check(DB.get_entry(criteria),pointer_name);
end

