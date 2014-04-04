% Marks bad channels and time segments on a fif file using gui
% Writes bad channels to a file for Maxfilter-code to use
%
% dependency_pkg(which('EXAMPLE_Mark_Bad_MEG'),'/home/foldes/Documents/private/');
% 2014-01-23 Foldes

Extract.full_file_name = '/home/foldes/Data/MEG/DBI05/S01/dbi05s01r14_tsss_trans.fif';
Extract = Prep_Extract_MEG(Extract); % OPTIONAL

[save_flag,bad_chan_list,bad_segments] = Mark_Bad_MEG(Extract);

% write bad channels to a file (just the channel numbers) 
bad_chan_file_name = [Extract.file_path filesep Extract.file_name '_badchans']; % clever naming
if save_flag
    file_id = fopen(bad_chan_file_name,'w');   
    for istr =1:size(bad_chan_list,1)
        fprintf(file_id,'%s ', num2str( bad_chan_list(istr,:) ));
    end
    fclose(file_id);
end
% move to server for maxfilter-code to use



