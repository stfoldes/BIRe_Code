clear
SCI_movement_Info_SF

entry_cnt = 0;
clear  Movement_Info
Movement_Info=[];

subject_list = fields(Movement_info);
for isubject =1:length(subject_list)
    
    subject = cell2mat(subject_list(isubject));
    
    movement_list = fields( Movement_info.(cell2mat(subject_list(isubject))) );
    
    for imove = 1:length(movement_list)
        session_list = fields( Movement_info.(cell2mat(subject_list(isubject))).(cell2mat(movement_list(imove))) );
        
        for isession = 1:length(session_list)
            session_discription = cell2mat(session_list(isession));
            
            switch session_discription
                case 'Baseline'
                    session = '01';
                    run = ['0' num2str(1)];
                otherwise % get the session number
                    split_str = regexp(session_discription,'_','split');
                    shorter_str = split_str{1};
                    shorter_str(1)=[];
                    session = ['0' shorter_str];
                    session = session(end-1:end);
                    
                    prepost_str = split_str{2};
                    switch prepost_str
                        case 'Pre'
                            run = ['0' num2str(1)];
                        case 'Post'
                            run = ['0' num2str(2)];
                        otherwise
                            error('SHIT')
                    end
            end
            
            
            %% List of things to write in this entry
            
            entry_match = find(Metadata_find(Movement_Info,'subject',subject) & Metadata_find(Movement_Info,'session',session) & Metadata_find(Movement_Info,'run',run));
            if isempty(entry_match)
                entry_cnt = entry_cnt + 1; 
            else
                entry_cnt = entry_match;
            end
            
            Movement_Info{entry_cnt}.subject = subject;
            Movement_Info{entry_cnt}.session = session;
            Movement_Info{entry_cnt}.run = run;
            
            measure_type_list = fields(Movement_info.(cell2mat(subject_list(isubject))).(cell2mat(movement_list(imove))).(cell2mat(session_list(isession))));
            
            for imeasure =1:length(measure_type_list)
                Movement_Info{entry_cnt}.(cell2mat(movement_list(imove))).(cell2mat(measure_type_list(imeasure))) ...
                    = Movement_info.(cell2mat(subject_list(isubject))).(cell2mat(movement_list(imove))).(cell2mat(session_list(isession))).(cell2mat(measure_type_list(imeasure)));
            end
            
        end %session
    end %movement
end %subject

save('C:\Data\MEG\Movement_Info.mat','Movement_Info')
            
% criteria.subject={'NS02'};
% Metadata_Find_Entries_By_Criteria(Movement_Info,criteria)
%             
            
%             if  strcmp(Movement_Info{1}.subject,'NS01')
                
                
                
                
                
                
