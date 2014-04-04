
clear
folder_name = uigetdir('C:/Data/MEG/','Select Folder to Check FIF files');

listing = dir(folder_name);

file_cnt = 0;
for ifile = 3:size(listing,1)
    
    if ~listing(ifile).isdir
        if strcmp(listing(ifile).name(end-2:end),'fif')
            file_cnt = file_cnt +1;
            
            file_name=[folder_name filesep listing(ifile).name];
            fif_info = fiff_setup_read_raw(file_name);
            
            % Channels by type
            MEG_chan_list=[]; EMG_chan_list=[]; EOG_chan_list=[]; STI_chan_list=[];MISC_chan_list=[];
            for ichan = 1:size(fif_info.info.ch_names,2)
                if strcmp(fif_info.info.ch_names{ichan}(1:3),'MEG')
                    MEG_chan_list = [MEG_chan_list, ichan];
                elseif strcmp(fif_info.info.ch_names{ichan}(1:3),'EMG')
                    EMG_chan_list = [EMG_chan_list, ichan];
                elseif strcmp(fif_info.info.ch_names{ichan}(1:3),'EOG')
                    EOG_chan_list = [EOG_chan_list, ichan];
                elseif strcmp(fif_info.info.ch_names{ichan}(1:3),'STI')
                    STI_chan_list = [STI_chan_list, ichan];
                elseif strcmp(fif_info.info.ch_names{ichan}(1:3),'MIS')
                    MISC_chan_list = [MISC_chan_list, ichan];
                end
            end
            
            num_chan_MEG = length(MEG_chan_list);
            EMG_check = ~isempty(EMG_chan_list);
            EOG_check = ~isempty(EOG_chan_list);
            MISC_check = ~isempty(MISC_chan_list);
            if MISC_check
                num_chan_misc = length(MISC_chan_list);
            else
                num_chan_misc = 0;
            end
            
            num_samples = double(fif_info.last_samp)-double(fif_info.first_samp);
            
            disp(' ')
            disp(file_name)
            disp(['     # MEG Channels: ' num2str(num_chan_MEG)])
            disp(['     # MISC Channels: ' num2str(num_chan_misc)])
            disp(['     EMG?: ' num2str(EMG_check)])
            disp(['     EOG?: ' num2str(EOG_check)])
            disp(['     # Samples: ' num2str(num_samples) ' ('  num2str(num_samples/fif_info.info.sfreq/60) ' minutes)'])
            disp(' ')
            
            all_file_durationsS(file_cnt) = num_samples/double(fif_info.info.sfreq);
            all_file_names{file_cnt}=listing(ifile).name;
            
        end
    end
end

% ASS-UMES FILE NAME = idxxsxxrxx*.fif
clear run_number_list
for ifile=1:file_cnt
    run_number_list(ifile,:) = str2num(all_file_names{ifile}(9:10));
end

% Lets check if you're missing any run numbers (which is very possible)
icnt=0;
for ifile=1:file_cnt
    if isempty(find(ifile == run_number_list))
       icnt=icnt+1;
       missing_run_numbers(icnt) = ifile;
    end
end

%% Print out stuff

disp(' ')
disp([folder_name ': ' num2str(file_cnt) ' files checked'])
for ifile=1:file_cnt
    
    % if the file is small, note it
    if all_file_durationsS(ifile)/60>=1
        disp(['     ' all_file_names{ifile}(8:10) ': ' num2str(all_file_durationsS(ifile)/60,'%10.1f') ' minutes (' all_file_names{ifile} ')'])
    else
        disp(['     ' all_file_names{ifile}(8:10) ': ' num2str(all_file_durationsS(ifile)/60,'%10.1f') ' minutes (' all_file_names{ifile} ')  ***SHORT DATA***'])
    end
end
disp(['Total Time: ' num2str(sum(all_file_durationsS)/60) ' minutes'])

disp(' ')
try
    for ifile =1:length(missing_run_numbers)
        disp(['***WARNING***: No File #' num2str(missing_run_numbers(ifile)) ' Found'])
    end
catch
    disp('All Files Accounted For')
end







