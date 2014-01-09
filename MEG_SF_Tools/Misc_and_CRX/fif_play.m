% Load .FIF parameters
% [Extract.file_path Extract.file_name{1} '.fif']
clear fif_file
fif_file = fiff_setup_read_raw('/home/foldes/Data/MEG/NS01/S02/ns01s02r10.fif');
fif_file2 = fiff_setup_read_raw('/home/foldes/Data/MEG/NS01/S02/ns01s02r10_sss.fif');

fif_file.info
fif_file.info.dev_head_t.trans % Head posision?
fif_file.info.dig % digitilization points?

%% Plot Digitalization points
for i=1:length(fif_file.info.dig)
    r(i,:) = fif_file.info.dig(i).r;
end

figure;
plot3(r(:,1),r(:,2),r(:,3),'.')
axis square

%% 
% Could copy fif_file.info.dig into another (rtMEG)