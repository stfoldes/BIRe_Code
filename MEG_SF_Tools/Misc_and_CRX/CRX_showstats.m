clear
results_file_name='/home/foldes/Data/MEG/CRX_Results';
load(results_file_name);

cnt=0;
for ientry = 2:length(Results)
    
    if ~strcmpi(Results{ientry}.file_base_name(1:2),'NS')
        continue
    end
    cnt=cnt+1;
    
    subject_list(cnt,:) = Results{ientry}.subject;
    session_list(cnt,:) = Results{ientry}.session;
    task_list(cnt,:) = Results{ientry}.task;

    move_hits_list(cnt,:) = Results{ientry}.HitRate.total_move_hits;
    move_trials_list(cnt,:) = Results{ientry}.HitRate.total_move_trials;
    rest_hits_list(cnt,:) = Results{ientry}.HitRate.total_rest_hits;
    rest_trials_list(cnt,:) = Results{ientry}.HitRate.total_rest_trials;
%     disp([subject_list(cnt,:) ' S' session_list(cnt,:) ' R: ' task_list(cnt,:) ': ' Results{ientry}.date])
%     disp(['      ' num2str(Results{ientry}.HitRate.total_move_hits+Results{ientry}.HitRate.total_rest_hits) '/' num2str(Results{ientry}.HitRate.total_move_trials+Results{ientry}.HitRate.total_rest_trials) ])
    disp([num2str(ientry) ' ' subject_list(cnt,:) ' S' session_list(cnt,:) ' R: ' task_list(cnt,:) ': ' num2str(Results{ientry}.HitRate.total_move_hits+Results{ientry}.HitRate.total_rest_hits) '/' num2str(Results{ientry}.HitRate.total_move_trials+Results{ientry}.HitRate.total_rest_trials) ])
   
%    if strcmp(task_list(cnt,:),'Grasp')
%        switch subject_list(cnt,:)
%            case 'NS01'
%                NS01.move_hits=move_hits_list(cnt,:);
%                NS01.move_trials=move_hits_list(cnt,:);
%                NS01.rest_hits=rest_hits_list(cnt,:);
%                NS01.rest_trials=rest_hits_list(cnt,:); 
%        end
%    end
end

%%

% clear grasp_flag
% for idx = 1:size(task_list,1)
%     grasp_flag(idx) = strcmp(task_list(idx,:),'Grasp');
% end
% 
% criteria.subject = 'NS04';
% criteria.session='03';
% criteria.task ='Grasp';
% current_entries = Metadata_Find_Entries_By_Criteria(Results,criteria);
% move_hits=0;move_trials=0; rest_hits=0; rest_trials=0;
% for ientry =1:length(current_entries)
%     move_hits = move_hits + Results{current_entries(ientry)}.HitRate.total_move_hits;
%     move_trials = move_trials + Results{current_entries(ientry)}.HitRate.total_move_trials;
%     rest_hits = rest_hits + Results{current_entries(ientry)}.HitRate.total_rest_hits;
%     rest_trials = rest_trials + Results{current_entries(ientry)}.HitRate.total_rest_trials;
% end
% disp([Results{current_entries(ientry)}.subject ' S' Results{current_entries(ientry)}.session ': ' num2str((move_hits+rest_hits)/(move_trials+rest_trials)) ' | ' num2str( ((move_hits/move_trials)+(rest_hits/rest_trials))/2 ) ' total:' num2str(move_trials+rest_trials)])



%% NOw plOt
% could look at: mean and SD for blocks of 10/20; 
bar_width = 0.3
figure;hold all
bar([0 1 2 3]-bar_width/2,[62 69 62 62],'k','BarWidth',bar_width)
bar([0 1 2]+bar_width/2,[64 72 66],'FaceColor',0.6*[1 1 1],'BarWidth',bar_width)
xlim([-.5 3.2])
ylim([0 100])
set(gca,'XTick',sort([0 1 2 3-bar_width/2]))
set(gca,'XTickLabel',['NS01'; 'NS02'; 'NS03'; 'NS04'])
legend('NF Session 1','NF Session 2')
xlabel('Subject')
ylabel('Success Rate')
box on



