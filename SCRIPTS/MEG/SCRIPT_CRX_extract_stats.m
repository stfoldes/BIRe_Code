% Finds all .mat files, if they are brain control, it will get the stats from them
%
% Foldes 2012-10-06

clear
tic

% %% Set global paths for DB_Class
% global MY_PATHS
% MY_PATHS.local_base = 'C:\Data\MEG\';
% %MY_PATHS.local_path_design='[subject]/S[session]'; % eg. NS01/S01
% %MY_PATHS.server_base = ['/home/foldes/Desktop/Katz/experiments/' MY_PATHS.project];
% %MY_PATHS.server_path_design='[subject]/S[session]'; % eg. NS01/S01
%
%
% %% Move files to approprate folder
% local_base = MY_PATHS.local_base;
% valid_ext = 'mat';
% subfolder_name = 'CRX_data';
% move_flag = 0;
%
% org_path = uigetdir(local_base,'Select folder to automatically extract and organize data folders');
% files = dir(org_path);
%
% for ifile = 3:length(files)
%     [~,~,ext]=fileparts(files(ifile).name);
%     % is it a valid file type?
%     if strcmpi(ext,valid_ext) || strcmpi(ext,['.' valid_ext])
%         [subject, session, run] = split_data_file_name(files(ifile).name);
%
%         subject_path = [local_base filesep upper(subject)];
%         session_path = [subject_path filesep 'S' session(end-1:end)]; % /SXX (only 2 numbers hardcoded)
%         % check if subject folder exists from base path
%         if exist(subject_path) ~= 7
%             mkdir(subject_path);
%         end
%         % check if session folder exists from base path
%         if exist(session_path) ~= 7
%             mkdir(session_path);
%         end
%
%         final_path = [session_path filesep subfolder_name];
%         % check if final folder exists from base path
%         if exist(final_path) ~= 7
%             mkdir(final_path);
%         end
%
%         disp([files(ifile).name ' --> ' final_path])
%         if move_flag == 1
%             movefile([org_path filesep files(ifile).name],[final_path filesep files(ifile).name]);
%         else
%             copyfile([org_path filesep files(ifile).name],[final_path filesep files(ifile).name]);
%         end
%     end
% end


%% Build metadata base



% CRX_path = 'C:\Data\MEG\CRX4HBM_Mats\';
CRX_path = '/home/foldes/Data/MEG/CRX4HBM_Mats/';
CRX_file_list = search_dir(CRX_path,'*.mat');

% Go thru a folder and pull the metadata from the CRX files
tic
CRX_meta = Feedback_Class;
fail_cnt=0;
for ifile = 1:length(CRX_file_list)
    %    disp([num2str(ifile) ' '  CRX_file_list{ifile}])
    % end
    
    try
        load(CRX_file_list{ifile})
    catch
        warning(['*** Failed Loading - ' CRX_file_list{ifile} ' ***'])
        fail_cnt=fail_cnt+1;
        failed_file_list{fail_cnt}= CRX_file_list{ifile};
        continue
    end
    
    if ~isfield(S,'App_Sampled')
        warning(['*** Failed Loading - ' CRX_file_list{ifile} ' ***'])
        fail_cnt=fail_cnt+1;
        failed_file_list{fail_cnt}= CRX_file_list{ifile};
        continue
    end
    
    % Metadata info from file
    clear entry
    entry = Feedback_Class;
    
    [~,entry.entry_id] =    fileparts(CRX_file_list{ifile});
    entry.subject =         entry.entry_id(1:4);%S.Properties.Subject;
    entry.session =         ['0' S.Properties.Session];
    entry.session =         entry.session(end-1:end);
    entry.date =            S.Properties.Date;
    entry.run =             S.Properties.Run;
    
    % figure out run_type
    if ~strcmp(S.Properties.Application_Module,'FlipbookControl')
        disp([CRX_file_list{ifile} ' is of type: ' S.Properties.Application_Module])
        continue
    end
    
    %         figure;hold all
    %         plot(S.App_Sampled.Training)
    %         plot(S.App_Sampled.Trial_Count)
    %         title(entry.entry_id)
    
    % training flag = training data (or training+testing)
    %         if max(S.App_Sampled.Training)==0 && min(S.App_Sampled.Training)==0
    %             entry.run_intention ='Training';
    %         elseif max(S.App_Sampled.Training)==1 && min(S.App_Sampled.Training)==0
    %             entry.run_intention ='Training_and_Control';
    %         elseif max(S.App_Sampled.Training)==1 && min(S.App_Sampled.Training)==1
    %             entry.run_intention ='Control';
    %         end
    if max(S.App_Sampled.Training)==1 && min(S.App_Sampled.Training)==1
        entry.run_intention ='Training';
    elseif max(S.App_Sampled.Training)==1 && min(S.App_Sampled.Training)==0
        entry.run_intention ='Training_and_Control';
    elseif max(S.App_Sampled.Training)==0 && min(S.App_Sampled.Training)==0
        entry.run_intention ='Control';
    end
    
    % Check that pictures didn't change...this shouldn't happen (fileparts doesn't work)
    %     % look for task type
    %     for ientry = 2: length(S.App_Ctls.PictureFolderPath{1})
    %         if ~strcmp(fileparts(S.App_Ctls.PictureFolderPath{1}{ientry}),fileparts(S.App_Ctls.PictureFolderPath{1}{ientry-1}))
    %             error('MISMATCH IN PICTURES LOADED, UHNO')
    %         end
    %     end
    
    % Currently Messy
    stimulus_name_split=regexp(S.App_Ctls.PictureFolderPath{1}{1},'FlipBook_(.*?)_(.*?)\\','tokens');
    %     path_parts=regexp(S.App_Ctls.PictureFolderPath{1}{1},'\w*\\w*','match');
    %     stimulus_name_split = regexp(path_parts{end},'_','split');
    
    entry.run_action = cell2mat(stimulus_name_split{1}(1));
    entry.run_task_side = cell2mat(stimulus_name_split{1}(2));
    
    entry.run_info = [entry.run_task_side '_' entry.run_action '_' entry.run_intention];
    
    disp([entry.subject ' S' entry.session ': ' entry.run_info])
    
    CRX_meta = CRX_meta.update_entry(entry);
end

%% run_group: what runs go with each one
% what about train+test trials? *****************
% what about re-training?

for ientry = 1:length(CRX_meta)
    
    current_entry = CRX_meta(ientry);
    
    crit.subject =          current_entry.subject;
    crit.session =          current_entry.session;
    crit.run_action =       current_entry.run_action;
    crit.run_task_side =    current_entry.run_task_side;
    crit.run_intention =    current_entry.run_intention;
    
    [~,entry_idx_list] = CRX_meta.get_entry(crit);
    
    if ~isempty(entry_idx_list)
        % .run_group = CRX_meda(entry_idx_list).entry_id;
        current_entry.run_group = {CRX_meta(entry_idx_list).entry_id};% 2014-03-25
    end
    
    CRX_meta = CRX_meta.update_entry(current_entry);
end

%% Get the data from each run, but your going to have to link runs by group

% DB_lookup_unique_entries(CRX_meta,'run_intention')
Results = CRX_Results_Class;

% for each subject
subject_list = DB_lookup_unique_entries(CRX_meta,'subject');

for isubject = 1:length(subject_list)
    
    session_list_cell = {CRX_meta.get_entry('subject',subject_list{isubject}).session};% 2014-03-25
    session_list =      (unique(session_list_cell));
    
    
    % for each session
    for isession = 1:length(session_list)
        clear crit
        crit.subject =  subject_list{isubject};
        crit.session =  session_list{isession};
        
        
        crit.run_action =       'Grasp';
        crit.run_intention =    'Control'; %Training_and_Control
        
        [~,entry_idx_list] = CRX_meta.get_entry(crit);
        if isempty(entry_idx_list)
            break
        end
        
        % Need a unqiue for cell arrays
        %     unique(struct_field2cell(CRX_meta(entry_idx_list),'run_group'))
        
        % ASSUMING GROUPS ARE CORRECTLY DEFINED ABOVE AND SAME ACROSS GROUP MEMBERS
        current_entry_id_list = CRX_meta(entry_idx_list(1)).run_group;
        
        % Now you have a list of entrys for this person
        trial_cnt = 0; % used to group files
        clear Trial_Info
        for ientry = 1:length(current_entry_id_list)
            current_entry_id =  cell2mat(current_entry_id_list(ientry));
            current_entry =     CRX_meta.get_entry(current_entry_id);
            
            % Load S
            load([CRX_path filesep current_entry.entry_id '.mat']);
            
            clear raw_cursor_pos
            for itime = 1:length( S.App_Sampled.Control_Position)
                try
                    raw_cursor_pos(itime) = (S.App_Sampled.Control_Position{itime});
                end
            end
            % plot(raw_cursor_pos)
            
            clear raw_target_pos
            for itime = 1:length( S.App_Sampled.Control_Position)
                try
                    raw_target_pos(itime) = (S.App_Sampled.Target_Position{itime});
                end
            end
            % plot(raw_target_pos)
            
            % check out some stuff
            %figure;hold all;plot(S.App_Sampled.Hit_Count);plot(zscore(raw_cursor_pos));plot(S.App_Sampled.State_Code);xlim([200 500])
            
            % Get App time from Source Time (this is easy, but this code is careful)
            source_timeS =(S.Sig_Proc_Sampled.End_Time_Stamp-min(S.Sig_Proc_Sampled.End_Time_Stamp))/1000;
            app_timeS = source_timeS(find_closest_in_list_idx(S.App_Sampled.Sample_Index,S.Source_Sampled.Sample_Index));
            
            % Sometimes the trial count is reset, remove those times
            % indices when a reset happens
            trial_cnt_reset_idx = [find(diff(S.App_Sampled.Trial_Count)<0); length(S.App_Sampled.Trial_Count)];
            % find bad shit short
            good_idx = ones(size(S.App_Sampled.Trial_Count));
            % is the reset less than 5 trials?
            if max(S.App_Sampled.Trial_Count(trial_cnt_reset_idx)<5)
                aborted_trial=find(S.App_Sampled.Trial_Count(trial_cnt_reset_idx)<5);
                if aborted_trial > 1
                    back_in_time = trial_cnt_reset_idx(aborted_trial-1);
                else
                    back_in_time = 1;
                end
                good_idx(back_in_time :trial_cnt_reset_idx(aborted_trial))=0;
                disp(['Aborted Time Removed: ' num2str(length(back_in_time:trial_cnt_reset_idx(aborted_trial))) ' Samples'])
            end
            
            % remove abort
            % SampleVecs.sample_idx =     S.App_Sampled.Sample_Index(good_idx==1); % shouldnt matter if you don't skip samples
            SampleVecs.timeS =          app_timeS(good_idx==1);
            SampleVecs.trial_count =    S.App_Sampled.Trial_Count(good_idx==1); % why need this?
            SampleVecs.target_code =    S.App_Sampled.Target_Code(good_idx==1);
            SampleVecs.state_code =     S.App_Sampled.State_Code(good_idx==1); % 3 = control
            SampleVecs.hit_count =      S.App_Sampled.Hit_Count(good_idx==1); % why need this?
            SampleVecs.cursor_pos =     raw_cursor_pos(good_idx==1);
            SampleVecs.target_pos =     raw_target_pos(good_idx==1);
            SampleVecs.in_target =      S.App_Sampled.In_Target_Flag(good_idx==1);
            
            % removes count resets
            SampleVecs.hit_flag =           [0; (diff(SampleVecs.hit_count)>0)];
            SampleVecs.cum_trial_count =    cumsum([0; diff(SampleVecs.trial_count)>0]);
            
            hit_idx_org =   find(SampleVecs.hit_flag==1); % idx of orgingal hits
            % Indicies of trials starting (defined by state==3)
            trial_start_idx =   find([0; diff(SampleVecs.state_code==3)]>0);
            trial_end_idx =     find([0; diff(SampleVecs.state_code==3)]<0); % why not -1?
            
            
            %% Go thru each trial and find NEW hit time
            
            parms.hold_timeS = 0.500;%S.App_Ctls.Hold_Time; % ms
            parms.hold_thres = 10;
            
            hit_info = [];
            hit_cnt = 0;
            for itrial = 1:length(trial_start_idx)
                trial_cnt = trial_cnt + 1; % For grouping files
                
                clear current_trial_
                current_trial_idx =           [trial_start_idx(itrial):trial_end_idx(itrial)+1]; % why +1, b/c things in CRX change at different samples?
                current_trial_in_target =     SampleVecs.in_target(current_trial_idx);
                current_trial_timeS =         SampleVecs.timeS(current_trial_idx);
                current_trial_target_pos =    SampleVecs.target_pos(current_trial_idx);
                current_trial_target_code =   SampleVecs.target_code(current_trial_idx);
                if length(unique(current_trial_target_code))>1 % this doesn't work right
                    warning('Something wrong. There should only be one target code per trial')
                end
                current_trial_cursor_pos =    SampleVecs.cursor_pos(current_trial_idx);
                current_trial_hit_flag =      SampleVecs.hit_flag(current_trial_idx);
                
                Trial_Info(trial_cnt).run =         current_entry.run;
                Trial_Info(trial_cnt).start_idx =   min(current_trial_idx);
                Trial_Info(trial_cnt).start_timeS = min(current_trial_timeS);
                Trial_Info(trial_cnt).durationS =   max(current_trial_timeS)-min(current_trial_timeS);
                Trial_Info(trial_cnt).target_code = current_trial_target_code(1); % SHOULD BE ANY INDX
                Trial_Info(trial_cnt).hit =         0; % default to no-hit
                itime = 0;
                while itime < length(current_trial_timeS)
                    itime = itime + 1;
                    % How many samples does it take to get to a certain time
                    windowS = 0; sample_cnt = 0; still_time = 1;
                    while windowS<parms.hold_timeS && still_time
                        sample_cnt = sample_cnt + 1;
                        if (itime+sample_cnt+1)>length(current_trial_timeS) % what you want is bigger than what you have
                            still_time = 0; % you are out of time
                            sample_cnt = 0; % reset cnt just to be safe you dont use it
                        end
                        windowS = current_trial_timeS(itime+sample_cnt)-current_trial_timeS(itime);
                    end
                    
                    if still_time == 1
                        % is this small chunck of time all in_target?
                        if min(current_trial_in_target(itime:itime+sample_cnt))==1
                            % must also be the correct target
                            if abs(current_trial_target_pos(itime+sample_cnt)-current_trial_cursor_pos(itime+sample_cnt)) <= parms.hold_thres
                                % sample_cnt = sample_cnt - 1;
                                hit_cnt = hit_cnt+1;
                                hit_info.idx(hit_cnt) =         current_trial_idx(itime+sample_cnt);
                                hit_info.timeS(hit_cnt) =       current_trial_timeS(itime+sample_cnt);
                                % CHECK HELPERS
                                %hit_info.trial_num(hit_cnt) =   current_trial_cum_trial_count(itime+sample_cnt);
                                hit_info.target_code(hit_cnt) = current_trial_target_code(itime+sample_cnt);
                                %TESTING HERE TO SEE WHY THIS IS -1 SOMETIME AND NOT OTHERS
                                hit_info.hit_flag(hit_cnt) =    current_trial_hit_flag(itime+sample_cnt);
                                hit_info.in_target(hit_cnt) =   current_trial_in_target(itime+sample_cnt);
                                
                                Trial_Info(trial_cnt).hit =             1;
                                Trial_Info(trial_cnt).hit_idx =         hit_info.idx(hit_cnt);
                                Trial_Info(trial_cnt).hit_timeS =       hit_info.timeS(hit_cnt);
                                
                                % Time to trial success = first-sample-in-successful-hold-window - first-sample-in-trial
                                Trial_Info(trial_cnt).success_timeS =   current_trial_timeS(itime) - current_trial_timeS(1);
                                
                                % Path efficiency ***HERE***
                                
                                % crank time up to prevent multiple hits
                                % itime = itime + sample_cnt;
                                itime = length(current_trial_timeS); % go to end of trial to exit
                            end % in correct target
                        end % all in target
                    end
                    
                end % time
            end %trial
            
            %             % Plot
            %             figure;hold all
            %             Figure_Stretch(2);
            %             plot(SampleVecs.timeS,SampleVecs.target_pos,'b')
            %             plot(SampleVecs.timeS,SampleVecs.cursor_pos,'k')
            %             plot(SampleVecs.timeS,SampleVecs.in_target.*SampleVecs.cursor_pos','c.')
            %             hit_marker_idx = hit_info.idx;
            %             plot(SampleVecs.timeS(hit_marker_idx),SampleVecs.cursor_pos(hit_marker_idx)','g.','MarkerSize',30)
            %             hit_marker_idx = hit_idx_org;
            %             plot(SampleVecs.timeS(hit_marker_idx),SampleVecs.cursor_pos(hit_marker_idx)','r.','MarkerSize',20)
            %             xlim([30,200])
            
        end % grouped runs
        
        %% Save Results
        
        current_result = CRX_Results_Class;
        current_result = copy_fields(current_result,current_entry,...
            'subject','session','run_action','run_task_side','run_intention','run_info','run_group');
        
        current_result.run_by_trial =          struct_field2mat(Trial_Info,'run');
        current_result.hold_timeS =            parms.hold_timeS;
        current_result.num_trials =            length(Trial_Info);
        current_result.success_timeS =         struct_field2mat(Trial_Info,'success_timeS');
        current_result.mean_success_timeS =    mean(current_result.success_timeS);
        
        current_result.success_trial_num =     find(struct_field2mat(Trial_Info,'hit')==1);
        target_code_by_trial = struct_field2mat(Trial_Info,'target_code');
        current_result.success_trial_target =  target_code_by_trial(current_result.success_trial_num);
        
        current_result.target_code_types = sort(unique(struct_field2mat(Trial_Info,'target_code'))); % easier than it looks
        
        for idim = 1:length(current_result.target_code_types)
            % target_codes for trials that were successful
            target_code_by_success = target_code_by_trial(current_result.success_trial_num);
            
            current_result.hit_per_dim(:,idim) =   sum(target_code_by_success==current_result.target_code_types(idim));
            current_result.trial_per_dim(:,idim) = sum(target_code_by_trial==current_result.target_code_types(idim));
            current_result.hit_rate(:,idim) =      current_result.hit_per_dim(:,idim)/current_result.trial_per_dim(:,idim);
        end
        
        Results = Results.update_entry(current_result);
        
    end % session
end % subject

toc

subject_list = DB_lookup_unique_entries(Results,'subject');
for isubject = 1:length(subject_list)
    session_list_cell = {Results.get_entry('subject',subject_list{isubject}).session};% 2014-03-25
    session_list =      (unique(session_list_cell));
    
    disp([subject_list{isubject} ' ' session_list])
end
    
%%
num_to_agr = 40;

clear crit
ifile = 0;

ifile = ifile+1;
crit(ifile).subject = 'NS01';
crit(ifile).session = '03';
ifile = ifile+1;
crit(ifile).subject = 'NS01';
crit(ifile).session = '04';

ifile = ifile+1;
crit(ifile).subject = 'NS02';
crit(ifile).session = '02';
ifile = ifile+1;
crit(ifile).subject = 'NC02';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'NS03';
crit(ifile).session = '02';
ifile = ifile+1;
crit(ifile).subject = 'ns03';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'ns04';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'NS06';
crit(ifile).session = '02';
ifile = ifile+1;
crit(ifile).subject = 'NS06';
crit(ifile).session = '03';
% ifile = ifile+1;
% crit(ifile).subject = 'NS06';
% crit(ifile).session = '04';
% ifile = ifile+1;
% crit(ifile).subject = 'NS06';
% crit(ifile).session = '05';
% ifile = ifile+1;
% crit(ifile).subject = 'NS06';
% crit(ifile).session = '06';
% ifile = ifile+1;
% crit(ifile).subject = 'NS06';
% crit(ifile).session = '07';
% ifile = ifile+1;
% crit(ifile).subject = 'NS06';
% crit(ifile).session = '08';
% ifile = ifile+1;
% crit(ifile).subject = 'NS06';
% crit(ifile).session = '09';
% ifile = ifile+1;
% crit(ifile).subject = 'NS06';
% crit(ifile).session = '10';

ifile = ifile+1;
crit(ifile).subject = 'NS07';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'NS08';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'NS11';
crit(ifile).session = '03';


% grouped by first session
clear crit
ifile = 0;

ifile = ifile+1;
crit(ifile).subject = 'NS01';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'NS02';
crit(ifile).session = '02';

ifile = ifile+1;
crit(ifile).subject = 'NS03';
crit(ifile).session = '02';

ifile = ifile+1;
crit(ifile).subject = 'ns04';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'NS06';
crit(ifile).session = '02';

ifile = ifile+1;
crit(ifile).subject = 'NS07';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'NS08';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'NS11';
crit(ifile).session = '03';




% Grouped by day1, day2
clear crit
ifile = 0;

ifile = ifile+1;
crit(ifile).subject = 'NS01';
crit(ifile).session = '03';
ifile = ifile+1;
crit(ifile).subject = 'NS01';
crit(ifile).session = '04';

ifile = ifile+1;
crit(ifile).subject = 'NS02';
crit(ifile).session = '02';
ifile = ifile+1;
crit(ifile).subject = 'NC02';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'NS03';
crit(ifile).session = '02';
ifile = ifile+1;
crit(ifile).subject = 'ns03';
crit(ifile).session = '03';

ifile = ifile+1;
crit(ifile).subject = 'NS06';
crit(ifile).session = '02';
ifile = ifile+1;
crit(ifile).subject = 'NS06';
crit(ifile).session = '03';


%%
clear total
for ifile = 1:length(crit)
    x = Results.get_entry(crit(ifile));
    
    % Total hit rate
    total.hit_per_dim(ifile,:) = x.hit_per_dim./x.trial_per_dim;
    total.hit(ifile) = mean(total.hit_per_dim(ifile,:));
    
    file_split_trial = find([0; diff(str2num(x.run_by_trial))]);
    hit_vec = zeros(1,sum(x.trial_per_dim)); % add to obj
    hit_vec(x.success_trial_num) = 1;
    
    % moving_avg_plot(x.success_timeS,[],10);
    % hold all
    % Plot_VerticalMarkers(file_split_trial);
    
    % moving_avg_plot(hit_vec',[],10);
    % hold all
    % Plot_VerticalMarkers(file_split_trial);
    
    
    % first and last
    total.first_hit(ifile) = mean(hit_vec(1:num_to_agr));
    total.end_hit(ifile) = mean(hit_vec(end-num_to_agr+1:end));
    
    % times
    total.time(ifile) = mean(x.success_timeS);
    success_trial_num = find_lists_overlap_idx([1:num_to_agr],x.success_trial_num);
    total.first_time(ifile) = mean(x.success_timeS(success_trial_num));

    num_trials = size(x.run_by_trial,1);
    success_trial_num = find_lists_overlap_idx([num_trials-num_to_agr+1:num_trials],x.success_trial_num);
    total.end_time(ifile) = mean(x.success_timeS(end-num_to_agr+1:end));
       
end

%%
disp(' ')
disp('*************')
disp('HITS')
disp('Total hit rate')
disp_mean_std(total.hit)
disp('end rate')
disp_mean_std(total.end_hit)
disp('Hit for grasp')
disp_mean_std(total.hit_per_dim(:,1))
disp('Hit for rest')
disp_mean_std(total.hit_per_dim(:,2))
disp('Hit diff end-beg (+ = gets better)')
disp_mean_std(total.end_hit - total.first_hit)

disp(' ')
disp('TIMES')
disp_mean_std(total.time)
disp('end rate')
disp_mean_std(total.end_time)
disp('time diff end-beg (- = gets faster')
disp_mean_std(total.end_time - total.first_time)



%% Compare across 2 days (assumes 1:2:end and 2:2:end match)



disp(' ')
disp('*************')
disp('DIFF HITS (neg = +performance)')
diff_hit = total.hit(1:2:end) - total.hit(2:2:end);
disp_mean_std(diff_hit)

disp('beg1 vs. beg2 (neg = +performance)')
disp_mean_std(total.first_hit(1:2:end) - total.first_hit(2:2:end))
disp('end1 vs. end2 (neg = +performance)')
disp_mean_std(total.end_hit(1:2:end) - total.end_hit(2:2:end))

disp('Retention: end day 1 vs. beg day 2 (neg = +performance)')
disp_mean_std(total.end_hit(1:2:end) - total.first_hit(2:2:end))
disp('across both days: beg 1 vs. end day 2 (neg = +performance)')
disp_mean_std(total.first_hit(1:2:end) - total.end_hit(2:2:end))


disp(' ')
disp('Diff TIMES time1-time2')
diff_time = total.time(1:2:end) - total.time(2:2:end);
disp_mean_std(diff_time)

disp('beg1 vs. beg2 (neg = slow down)')
disp_mean_std(total.first_time(1:2:end) - total.first_time(2:2:end))
disp('end1 vs. end2 (neg = slow down)')
disp_mean_std(total.end_time(1:2:end) - total.end_time(2:2:end))

disp('Retention: end day 1 vs. beg day 2 (neg = slow down)')
disp_mean_std(total.end_time(1:2:end) - total.first_time(2:2:end))
disp('across both days: beg 1 vs. end day 2 (neg = slow)')
disp_mean_std(total.first_time(1:2:end) - total.end_time(2:2:end))

disp(' ')
disp('FIRST OF 2')
disp('HITS')
disp('end1-beg1: neg = -performance')
disp_mean_std(total.end_hit(1:2:end) - total.first_hit(1:2:end))
disp('TIMES')
disp('end1-beg1: neg = +perforamnce')
disp_mean_std(total.end_time(1:2:end) - total.first_time(1:2:end))

disp(' ')
disp('2nd OF 2 days')
disp('HITS')
disp('end2-beg2: neg = -performance')
disp_mean_std(total.end_hit(2:2:end) - total.first_hit(2:2:end))
disp('TIMES')
disp('end2-beg2: neg = +perforamnce')
disp_mean_std(total.end_time(2:2:end) - total.first_time(2:2:end))

