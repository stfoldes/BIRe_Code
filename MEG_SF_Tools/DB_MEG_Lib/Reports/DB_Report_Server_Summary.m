% SCRIPT
% Writes a file that summarizes what data is on the server.
% Specific for meg_neurofeedback type heirarchy
% MAKE INTO FUNCTION THAT OUTPUTS THE INFO SO YOU CAN CHECK IT AGAINST THE DATABASE 
% ADD OPTION TO DO W/O fMRI
%
% Foldes [2013-01-03]
% UPDATES:
% 2013-02-27 Foldes: Updated
% 2013-03-05 Foldes: Now can save output file local
% 2013-07-02 Foldes: User name --> computer name

%%
% path to server
%path_server = '/home/foldes/Desktop/Katz/experiments/';
path_server = '\\192.168.1.4\data\experiments\';

paradigm = 'meg_neurofeedback';
outfilename = [paradigm '_summary.txt'];

% path2save_output_file = 'C:\Users\hrnel\Documents\';
path2save_output_file = [path_server paradigm];

%% File to Write

fileID = fopen([path2save_output_file filesep outfilename],'w');
fprintf(fileID,'Server Summary for %s \n',paradigm);
fprintf(fileID,'Date Generated: %s (by %s)\n\n',datestr(now,'yyyy-mm-dd'),computer_info);

%%
dir_items=dir([path_server paradigm]);
for iitem = 3:length(dir_items)
    subject_id=[];fMRI_list=[];session_list=[];
    if length(dir_items(iitem).name)==4 && dir_items(iitem).isdir % 4 characters only and a dir
        subject_id = dir_items(iitem).name;
        
        dir_items_subject=dir([path_server paradigm filesep subject_id]);
        
        % Inside a subject folder
        session_list=[];session_cnt = 0;
        for iitem_subject = 3:length(dir_items_subject)
            
            if strcmp(dir_items_subject(iitem_subject).name(1),'S') && length(dir_items_subject(iitem_subject).name)==3 && dir_items_subject(iitem_subject).isdir
                session_cnt = session_cnt+1;
                session_list{session_cnt}.name=dir_items_subject(iitem_subject).name;
                session_list{session_cnt}.number=str2num(dir_items_subject(iitem_subject).name(2:3));
                session_list{session_cnt}.num_files = length(dir([path_server paradigm filesep subject_id filesep dir_items_subject(iitem_subject).name]));
                
                % Get the date
                dir_items_session_sub=dir([path_server paradigm filesep subject_id filesep dir_items_subject(iitem_subject).name]);
                date_list=[];
                for iitem_session_sub = 1:length(dir_items_session_sub)
                    date_list=[date_list; dir_items_session_sub(iitem_session_sub).datenum];
                end
                [~,oldes_idx]=min(date_list);
                session_list{session_cnt}.date=datestr(dir_items_session_sub(oldes_idx).datenum,'yyyy-mm-dd');
                
            end
            
            % In fMRI folder
            dir_items_fMRI =[];
            if strcmp(dir_items_subject(iitem_subject).name,'fMRI') && dir_items(iitem_subject).isdir
                dir_items_fMRI=dir([path_server paradigm filesep subject_id filesep 'fMRI']);
                fMRI_folder_cnt = 0;
                for iitem_fMRI = 3:length(dir_items_fMRI)
                    if dir_items_fMRI(iitem_fMRI).isdir % in subfolder like "Initial"
                        
                        
                        % go into "Initial" (for example)
                        dir_items_fMRI_sub=dir([path_server paradigm filesep subject_id filesep 'fMRI' filesep dir_items_fMRI(iitem_fMRI).name]);
                        
                        % Look thru Subject/fMRI/Initial/.
                        for iitem_fMRI_sub = 3:length(dir_items_fMRI_sub)
                            % Look for Subject/fMRI/Initial/Raw_Data/
                            if strcmp(dir_items_fMRI_sub(iitem_fMRI_sub).name,'Raw_Data') && dir_items_fMRI_sub(iitem_fMRI_sub).isdir
                                fMRI_folder_cnt = fMRI_folder_cnt+1;
                                
                                fMRI_list{fMRI_folder_cnt}.name = dir_items_fMRI(iitem_fMRI).name;
                                
                                % Get the date
                                date_list=[];
                                for iitem_fMRI_sub_sub = 1:length(dir_items_fMRI_sub)
                                    date_list=[date_list; dir_items_fMRI_sub(iitem_fMRI_sub_sub).datenum];
                                end
                                [~,oldes_idx]=min(date_list);
                                fMRI_list{fMRI_folder_cnt}.date=datestr(dir_items_fMRI_sub(oldes_idx).datenum,'yyyy-mm-dd');
                                
                                
                                % Look for Subject/fMRI/Initial/Freesurfer_Reconstruction/
                                fMRI_list{fMRI_folder_cnt}.FS_fMRI_flag = 0;
                                for jitem_fMRI_sub = 3:length(dir_items_fMRI_sub)
                                    if strcmp(dir_items_fMRI_sub(jitem_fMRI_sub).name,'Freesurfer_Reconstruction') && dir_items_fMRI_sub(jitem_fMRI_sub).isdir
                                        fMRI_list{fMRI_folder_cnt}.FS_fMRI_flag = 1;
                                    end
                                end
                                
                                % check if pial surface made (in Subject/fMRI/Initial/.)
                                fMRI_list{fMRI_folder_cnt}.pial_flag = 0;
                                if ~isempty(findFiles('*.pial',[path_server paradigm filesep subject_id filesep 'fMRI' filesep dir_items_fMRI(iitem_fMRI).name]))
                                    fMRI_list{fMRI_folder_cnt}.pial_flag = 1;
                                end
                                
                            end % Raw_Data exists
                            
                        end % check fMRI folder
                        
                    end % fMRI session
                end % fMRI session
            end % fMRI dir
        end % sub subject dir
        
        %% Print out information
        
        fprintf(fileID,'=============================\n');
        fprintf(fileID,'%s\n',subject_id);
        fprintf(fileID,'\tMEG:\n');
        for isession = 1:size(session_list,2)
            fprintf(fileID,'\t\t%s [%s] (%i files)\n',session_list{isession}.name,session_list{isession}.date,session_list{isession}.num_files);
        end
        
        fprintf(fileID,'\tfMRI:\n');
        for isession = 1:size(fMRI_list,2)
            fprintf(fileID,'\t\t%s [%s] (FS?=%i, pial?=%i)\n',fMRI_list{isession}.name,fMRI_list{isession}.date,fMRI_list{isession}.FS_fMRI_flag,fMRI_list{isession}.pial_flag);
        end
        fprintf(fileID,'\n');
        
        
        
        
        
    end  % subject dir
end % parent

fclose(fileID);
disp(['Wrote summary report--> ' path2save_output_file filesep outfilename])
open([path2save_output_file filesep outfilename])
