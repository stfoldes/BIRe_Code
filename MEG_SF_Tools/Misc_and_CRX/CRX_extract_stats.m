% Finds all .mat files, if they are brain control, it will get the stats from them
%
% Foldes 2012-10-06

clear
tic
results_file_name='/home/foldes/Data/MEG/CRX_Results';
base_data_path = '/home/foldes/Data/MEG/CRX_Data/';

% results_file_name='CRX_Results';
% base_data_path = 'C:\Data\MEG\';

% To start database over
% Results = [];
% save(results_file_name,'Results')


CRX_file_list = findFiles('*.mat', base_data_path,1);
fail_cnt=0;
for ifile = 1:size(CRX_file_list,2)

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
    
    %% Basic info from file
    clear metaentry
    [~,metaentry.file_base_name]=fileparts(CRX_file_list{ifile});
    metaentry.subject = metaentry.file_base_name(1:4);%S.Properties.Subject;
    metaentry.session = ['0' S.Properties.Session];
    metaentry.session = metaentry.session(end-1:end);
    metaentry.date=S.Properties.Date;
    metaentry.run = S.Properties.Run;
    
    % figure out run_type
    if ~strcmp(S.Properties.Application_Module,'FlipbookControl')
        disp([CRX_file_list{ifile} ' is of type: ' S.Properties.Application_Module])
        continue
    end
    
    metaentry.paradigm_type = 'Closed_Loop_MEG';
    
    %         figure;hold all
    %         plot(S.App_Sampled.Training)
    %         plot(S.App_Sampled.Trial_Count)
    %         title(metaentry.file_base_name)
    
    % training flag = training data (or training+testing)
    %         if max(S.App_Sampled.Training)==0 && min(S.App_Sampled.Training)==0
    %             metaentry.control_type ='Training';
    %         elseif max(S.App_Sampled.Training)==1 && min(S.App_Sampled.Training)==0
    %             metaentry.control_type ='Training_and_Control';
    %         elseif max(S.App_Sampled.Training)==1 && min(S.App_Sampled.Training)==1
    %             metaentry.control_type ='Control';
    %         end
    if max(S.App_Sampled.Training)==1 && min(S.App_Sampled.Training)==1
        metaentry.control_type ='Training';
    elseif max(S.App_Sampled.Training)==1 && min(S.App_Sampled.Training)==0
        metaentry.control_type ='Training_and_Control';
    elseif max(S.App_Sampled.Training)==0 && min(S.App_Sampled.Training)==0
        metaentry.control_type ='Control';
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
    
    metaentry.task = cell2mat(stimulus_name_split{1}(1));
    metaentry.hand = cell2mat(stimulus_name_split{1}(2));

    metaentry.run_type = [metaentry.hand '_' metaentry.task '_' metaentry.control_type];

    disp([metaentry.subject ' S' metaentry.session ': ' metaentry.run_type])
    
%% Hit rate from control data
% 
% figure;hold all
% plot(S.App_Sampled.Hit_Count)
% plot(S.App_Sampled.Training)
% 
% clear cursor_pos
% for itime = 1:length( S.App_Sampled.Control_Position)
%     try
%         cursor_pos(itime) = (S.App_Sampled.Control_Position{itime});
%     end
% end
% plot(cursor_pos)
% 

% % cant happen during training
% sum(S.App_Sampled.Hit_Count(S.App_Sampled.Training==0))
% 
% 
% S.App_Ctls.Reset_Stats
% 
% figure;plot(S.App_Sampled.Trial_Count)
%%
    if ~strcmp(metaentry.control_type,'Training')
%         figure;hold all
%         plot(S.App_Sampled.Trial_Count)
%         plot(S.App_Sampled.Hit_Count)
%         % % plot(S.App_Sampled.State_Code)
%         % % plot(S.App_Sampled.

        % indices when a reset happens
        trial_cnt_reset_idx = [find(diff(S.App_Sampled.Trial_Count)<0); length(S.App_Sampled.Trial_Count)];

        % find bad shit short
        good_idx = ones(size(S.App_Sampled.Trial_Count));
        if max(S.App_Sampled.Trial_Count(trial_cnt_reset_idx)<5)
            aborted_trial=find(S.App_Sampled.Trial_Count(trial_cnt_reset_idx)<5);
            if aborted_trial > 1
            back_in_time = trial_cnt_reset_idx(aborted_trial-1);
            else 
                back_in_time = 1;
            end
            good_idx(back_in_time :trial_cnt_reset_idx(aborted_trial))=0;
            disp([num2str(length(back_in_time:trial_cnt_reset_idx(aborted_trial))) ' shit removed'])
        end

        % remove crap
        trial_count_vec = S.App_Sampled.Trial_Count(good_idx==1);
        target_code_vec = S.App_Sampled.Target_Code(good_idx==1);
        hit_count_vec = S.App_Sampled.Hit_Count(good_idx==1);

        % how many grasps where there and where hit?
        trial_idx = find(diff(trial_count_vec)>0);
        clear trial_type hit
        for itrial=1:length(trial_idx)
            trial_type(itrial) =target_code_vec(trial_idx(itrial));
            hit(itrial) = hit_count_vec(trial_idx(itrial)+1)>hit_count_vec(trial_idx(itrial));
        end

        total_move_trials = sum(trial_type==1);
        total_move_hits = sum(hit(trial_type==1));
        total_rest_trials = sum(trial_type==2);
        total_rest_hits = sum(hit(trial_type==2));

        disp(['Move: ' num2str(total_move_hits) '/' num2str(total_move_trials) ' =' num2str(total_move_hits/total_move_trials)])
        disp(['Rest: ' num2str(total_rest_hits) '/' num2str(total_rest_trials) ' =' num2str(total_rest_hits/total_rest_trials)])
        disp(['MEAN: ' num2str(((total_rest_hits/total_rest_trials)+(total_move_hits/total_move_trials))/2)])

%% SAVE
        Results_Save(results_file_name,metaentry,'HitRate',1,'total_move_trials','total_move_hits','total_rest_trials','total_rest_hits')

    end % only control

end % all files


for ifail = 1:length(failed_file_list)
    warning(['FAILED: ' failed_file_list{ifail}])
end
toc
%%
% 
% 
% figure;plot(S.Sig_Proc_Ctls.Training)
% 
% S.App_Sampled.In_Target_Flag
% 
% S.App_Sampled.State_Code
% 
% 
% 
% 
% 
% 
% 
% S.Sig_Proc_Ctls.OLE_Weights
% 
% S.Sig_Proc_Ctls.Training
% S.Sig_Proc_Ctls.Train_Decoder
% 
%         Decoder.block_idx = S.Sig_Proc_Ctls.Sample_Index;
%         
%         Decoder.decoder_block_idx_to_featureseries=[];
%         for iblock = 1:size(S.Sig_Proc_Ctls.Sample_Index,1)
%             Decoder.decoder_block_idx_to_featureseries(iblock,:) = find(S.App_Sampled.Sample_Index == S.Sig_Proc_Ctls.Sample_Index(iblock));
%         end
% 
% 





















