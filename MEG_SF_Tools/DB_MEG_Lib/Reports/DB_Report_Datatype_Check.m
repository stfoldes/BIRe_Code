% Metadata_Report_Datatype_Check(Metadata);
% Generates a report of what data types are marked in the data base.
% 
% To populate datatypes from server run this first:
%     Metadata = Metadata_DataTypeCheck(Metadata,server_base_path);
%     % Save back to database
%     Metadata_Write_to_TXT(Metadata,metadatabase_location);
%
% Foldes 2013-03-20

function Metadata_Report_Datatype_Check(Metadata)


% look up the datatype properties that are avalible in Metadata class (removes fif)
prop_list = fieldnames_all(PreprocInfo_Class);
clear datatype_list
type_cnt=0;
for iprop=1:length(prop_list)
    if (length(prop_list{iprop})>8) && strcmp(prop_list{iprop}(1:8),'datatype') && ~strcmp(prop_list{iprop}(10:end),'fif')
        type_cnt=type_cnt+1;
        datatype_list{type_cnt}=prop_list{iprop}(10:end);
    end
end

for itype =1:size(datatype_list,2)
    fprintf('%s\n',cell2mat(datatype_list(itype)));
    for ientry=1:length(Metadata)       
        flag = 0;
        eval(['flag = Metadata(ientry).Preprop.datatype_' cell2mat(datatype_list(itype)) ';'])
        if flag == 1
            fprintf('\t%s - %s %s %s %s (%s)\n',Metadata(ientry).subject, Metadata(ientry).run_type,Metadata(ientry).run_action,Metadata(ientry).run_task_side,Metadata(ientry).run_intention, Metadata(ientry).file_base_name);
        end
    end
end
