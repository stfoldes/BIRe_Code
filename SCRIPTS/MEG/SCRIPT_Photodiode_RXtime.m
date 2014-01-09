clearvars -except DB
% close all

% Choose criteria for data set to analyize
clear criteria
criteria.run_type = 'Open_Loop_MEG';
% criteria.run_task_side = 'Right';
criteria.run_intention = {'Observe','Imitate'};
criteria.run_action = 'Grasp';


%% Load Database
% Build database
if ~exist('DB','var')
    DB=DB_MEG_Class;
    DB=DB.build('PATHS_meg_neurofeedback'); % also sets global MY_PATHS
end

% Chooses the approprate entries
[DB_short,short_idx] = DB.get_entry(criteria);
[~,sort_idx] = DB_short.sort_enteries('date'); % sort by date
entry_list = short_idx(sort_idx);

% ********
% It is better to use idx so you can update the DB as a whole, not sub-DBs
% ********


%% Loop for All Entries
delay_list = [];date_list = [];
fail_list = [];
for ientry = 1:length(entry_list)
    
    DB_entry = DB(entry_list(ientry));
    disp(' ')
    disp(['==================File #' num2str(ientry) '/' num2str(length(entry_list)) ' | ' DB_entry.run_info '================='])

    try
        % Load Events (just so you dont over write)
        loaded_flag = DB_entry.load_pointer('Preproc.Pointer_Events');
        
        if loaded_flag ~= -1 % events loaded
            
            if ~isfield(Events,'Original') || ~isfield(Events.Original,'ParallelPort_Move')
                Events = DB_entry.Calc_Event_Markers('ParallelPort',[],1);
            end
            
            if ~isfield(Events.Original,'photodiode') || isempty(Events.Original.photodiode)
                Events = DB_entry.Calc_Event_Markers('photodiode',[],1);
            end
        end
        
        if loaded_flag ~= -1 % events loaded & photodiode is there
            for ievent=1:length(Events.Original.photodiode)
                current_delay=Events.Original.photodiode(ievent) - find_closest_in_list(Events.Original.photodiode(ievent),Events.Original.ParallelPort_BlockStart);
                delay_list = [delay_list current_delay];
                date_list = [date_list; DB_entry.date];
            end
        end
    catch
        fail_list = [fail_list DB_entry.entry_id];
    end
    
end

disp_mean_std(delay_list)

figure;plot(delay_list,'.')


Plot_by_Date(date_list,delay_list)
hold all
plot([xlim],[nanmedian(delay_list) nanmedian(delay_list)],'r')
Figure_Stretch(2)
ylabel('Photodiode lag (samples) from parallel port (movie)')
title([num2str(quantile(delay_list,0.5)) ' +- ' num2str(quantile(delay_list,0.25)) ',' num2str(quantile(delay_list,0.75))])
% Figure_TightFrame

%%
DB_entry = DB.get_entry('nc04s01r008')



%     processed_loaded_flag = DB_entry.load_pointer('Preproc.Pointer_processed_data_for_events');
%
%     % Preprocessing is needed, so do it now (should have done with Batch_Process_EMGandAcc_to_File)
%     if (processed_loaded_flag == 0) || ~isfield(processed_data,'EMG_data')
%
%%

% clear Extract
% Extract.file_name{1}=DB_entry.entry_id;
% Extract.file_path = DB_entry.file_path('local');
% Extract.base_sample_rate=1000;
% 
% % Load data
% clear TimeVecs
% TimeVecs.data_rate = Extract.base_sample_rate;
% [TimeVecs.target_code_org,TimeVecs.timeS] = Load_from_FIF(Extract,'STI');
% % Get TimeVecs.target_code
% ExpDefs.paradigm_type =DB_entry.run_type;
% ExpDefs=Prep_ExpDefs(ExpDefs);
% TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
% 
% 
% 
% figure;hold all
% plot(TimeVecs.timeS,TimeVecs.target_code)
% clear current_events
% current_events = Events.Original.photodiode;
% plot(TimeVecs.timeS(current_events),3*ones(size(current_events)),'ro')
% clear current_events
% current_events = Events.Original.ParallelPort_BlockStart;
% plot(TimeVecs.timeS(current_events),3*ones(size(current_events)),'g.')
% 
% 
% 
% figure;hold all
% plot(TimeVecs.target_code)
% clear current_events1
% current_events1 = Events.Original.photodiode;
% plot((current_events1),3*ones(size(current_events1)),'ro')
% clear current_events2
% current_events2 = Events.Original.ParallelPort_BlockStart;
% plot((current_events2),3*ones(size(current_events2)),'g.')


%%

% Choose criteria for data set to analyize
clear criteria
criteria.run_type = 'Open_Loop_MEG';
criteria.run_task_side = 'Right';
criteria.run_intention = 'Attempt';
% criteria.run_intention = 'Imagine';
criteria.run_action = 'Grasp';
% criteria.subject = 'NS04';

[~,entry_list] = DB.get_entry(criteria);

for ientry = 1:length(entry_list)
    DB_entry = DB(entry_list(ientry));
    
    % Load processed_data
    DB_entry.load_pointer('Preproc.Pointer_processed_data_for_events');
    
    % % Extract TimeVecs (if needed)
    % clear Extract
    % Extract.file_name{1}=DB_entry.entry_id;
    % Extract.file_path = DB_entry.file_path('local');
    % Extract.base_sample_rate=1000;
    %
    % % Load data
    % clear TimeVecs
    % TimeVecs.data_rate = Extract.base_sample_rate;
    % [TimeVecs.target_code_org,TimeVecs.timeS] = Load_from_FIF(Extract,'STI');
    % % Get TimeVecs.target_code
    % ExpDefs.paradigm_type =DB_entry.run_type;
    % ExpDefs=Prep_ExpDefs(ExpDefs);
    % TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
    
    Plot_Inspect_TimeSeries_Signals([],processed_data.ACC_data,'GUI_flag',0,'plot_title',DB_entry.run_info,'window_timeS',10000);
    pause(.5)
end
