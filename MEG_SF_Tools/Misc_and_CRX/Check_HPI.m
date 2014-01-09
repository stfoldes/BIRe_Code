% Print out the HPI digitization information shown on digitization sheet
%
% Stephen Foldes (2012-04-12)

% clear

% Extract.subject = 'NS02';
% Extract.session = '01';
% Extract.runs{1} = '01';

function Check_HPI(Extract)

Extract.file_path=['C:\Data\MEG\' Extract.subject '\S' Extract.session '\'];
for irun = 1:size(Extract.runs,2) % 2012-03-02 SF: Works for Cells
    Extract.file_name{irun}=[Extract.subject 's' Extract.session 'r' Extract.runs{irun}];
end

ifile = 1;
file_name = [Extract.file_path Extract.file_name{ifile} '.fif'];

%% Extract

% fif_file = fiff_setup_read_raw(file_name);
[fid, tree, dir] = fiff_open(file_name);
[info,meas] = fiff_read_meas_info(fid,tree);

%% Find Fiducial Points
[~, most_left_idx]=min([info.dig(1).r(1) info.dig(2).r(1) info.dig(3).r(1)]);
[~, most_right_idx]=max([info.dig(1).r(1) info.dig(2).r(1) info.dig(3).r(1)]);
[~, most_forward_idx]=max([info.dig(1).r(2) info.dig(2).r(2) info.dig(3).r(2)]);

Nasion = round_sig(1000*info.dig(most_forward_idx).r,-1);
LPA = round_sig(1000*info.dig(most_left_idx).r,-1);
RPA = round_sig(1000*info.dig(most_right_idx).r,-1);

%% Find HPI locations
clear HPI
icnt = 0;
for ipos = 1:20
    if info.dig(ipos).kind == 2
        icnt = icnt +1;
        HPI(:,icnt) = round_sig(1000*info.dig(ipos).r,-1);
    end
end

%% Print out
disp(' ')
disp(['Nasion: X= ' num2str(Nasion(1)) ', Y= ' num2str(Nasion(2)) ', Z= ' num2str(Nasion(3))])
disp(['LPA: X= ' num2str(LPA(1)) ', Y= ' num2str(LPA(2)) ', Z= ' num2str(LPA(3))])
disp(['RPA: X= ' num2str(RPA(1)) ', Y= ' num2str(RPA(2)) ', Z= ' num2str(RPA(3))])

disp(' ')
disp('HPI')
for iHPI = 1:4
    disp(['HPI ' num2str(iHPI) ': X= ' num2str(HPI(1,iHPI)) ', Y= ' num2str(HPI(2,iHPI)) ', Z= ' num2str(HPI(3,iHPI))])
end