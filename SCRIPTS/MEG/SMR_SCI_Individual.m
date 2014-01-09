% Inspect Modulation for Single Runs (can be more than one)
% 2013-10-18 Foldes


clearvars -except DB

pointer_name = 'ResultPointers.Power_tsss_trans_Cue_burg';

% Choose criteria for data set to analyize
clear criteria
criteria.subject = 'NS11';
criteria.run_type = 'Open_Loop_MEG';
criteria.run_task_side = 'Right';
criteria.run_action = 'Grasp';
criteria.run_intention = 'Attempt';

ResultParms.freq_names = {'mu','beta','SMR','gamma','gamma_low'};
ResultParms.roi_names = {'left_hemi','right_hemi'}; % DEF_MEG_sensors_sensorimotor_*
ResultParms.p_thres_for_sensors=0.05;

% % Choose criteria for data set to analyize
% remove_criteria.subject = {'NC07','NC02'};

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
DB_short=DB.get_entry(criteria);
% DB_short=DB.get_entry(criteria,remove_criteria);
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


%% PSD - By Subject

% Maybe do that cool gui I used to have
% pick subject by name

sensorimotor_left_idx = sensors2chanidx(Results(1).Extract.channel_list,DEF_MEG_sensors_sensorimotor_left_hemi);
% subject_list = {'NC06'};
% for isubject = 1:length(subject_list)
for ientry = 1:length(Results)
    %current_subject = subject_list{isubject};
    current_idx = ientry;%DB_find_idx(Results,'subject',current_subject);
    
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
