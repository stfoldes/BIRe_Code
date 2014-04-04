function obj = MEG_DataTypeCheck(obj)
%
% Populates obj-class with the avalible data types. Will go through all entries in obj and overwrite obj(:).datatype_*
% data_path_default[OPTIONAL]: MEG-subject folder location, can be server
% Uses all obj(:).datatype_* properties in checking
% This code has some hardcoded datatype managment [fif, crx]
% Assume if datatype isn't in the special list below, file naming is: 
%     obj(:).datatype_X
%     ~/Data/MEG/NS07/S01/ns07s01r09_X.fif
% 
% Also see: obj_Report_Datatype_Check(obj);
%
% Foldes [2013-01-23 - originally obj_FileTypeAvalible_Check.m]
% UPDATES:
% 2013-01-23 Foldes: Updated for class-type obj
% 2013-08-22 Foldes: datatype_ moved to .Preproc.
% 2013-10-15 Foldes: Metadata-->obj



% global MY_PATHS

%% Basic info
%         Extract.obj_file = obj_file;
disp(['Found ' num2str(length(obj)) ' files to process'])


% look up the datatype properties that are avalible in obj class
prop_list = fieldnames_all(PreprocInfo_Class);
type_cnt=0;
for iprop=1:length(prop_list)
    if (length(prop_list{iprop})>8) && strcmp(prop_list{iprop}(1:8),'datatype')
        type_cnt=type_cnt+1;
        datatype_list{type_cnt}=prop_list{iprop}(10:end);
    end
end

for ifile=1:length(obj)
    
%     %% Look for the spelling of the path
%     file_path=[data_path_default upper(obj(ifile).subject) '/S' obj(ifile).session '/'];
%     
%     % test out file path and try upper and lower case combinations
%     path_try_cnt=1;
%     while ~isdir(file_path)
%         switch path_try_cnt
%             case 1
%                 file_path=[data_path_default lower(obj(ifile).subject) '/S' obj(ifile).session '/'];
%             case 2
%                 file_path=[data_path_default upper(obj(ifile).subject) '/S' obj(ifile).session '/'];
%             case 3
%                 file_path=[data_path_default lower(obj(ifile).subject) '/s' obj(ifile).session '/'];
%             case 4
%                 file_path=[data_path_default upper(obj(ifile).subject) '/s' obj(ifile).session '/'];
%                 
%             otherwise
%                 error('NO FILE PATH FOUND @Prep_Extract_w_obj')
%                 return
%         end
%         path_try_cnt=path_try_cnt+1;
%     end
%     
    
    %% Go thru possible file types looking for the correct names
    
    for itype = 1:size(datatype_list,2)
        
        switch datatype_list{itype}
            case 'fif'
                file_extension='.fif';
                if exist([obj(ifile).file file_extension],'file')==2
                    eval(['obj(ifile).Preproc.datatype_' datatype_list{itype} '=1;'])
                end
                
            case 'crx'
                %                     file_suffix = '';file_extension='.mat';
                %                     if exist([file_path 'CRX_data/' obj(ifile).entry_id file_suffix file_extension],'file')==2
                %                         eval(['obj(ifile).datatype_' datatype_list{itype} '=1;'])
                %                     end
                
            otherwise % Assumes .fif is default type
                
                file_suffix = datatype_list{itype}; file_extension='.fif';
                if exist([obj(ifile).file '_' file_suffix file_extension],'file')==2
                    eval(['obj(ifile).Preproc.datatype_' datatype_list{itype} '=1;'])
                end
                
        end % switch
    end % datatype loop
    
end % obj loop
