
% Sample Index sent via Parallel Port (i.e. 8bit) will:
%     1. Starte at 176 until CRX is turned on
%     2. Go to 0 when CRX turns on
%     3. Increment Sample Index until it reaches 255
%     4. Drop back down to 0 and contiune up to 255 again

function new_sample_idx_fif = AlignFIFtoCRX_wSampleIndex(Extract)


% Extract.subject = 'NS02';
% Extract.session = '02';
% Extract.runs{1} = '07';
% Extract.CRX_file.runs{1} = '05';
% Extract.Baseline.runs{1} = '01';
% 
% Extract.file_path=['C:\Data\MEG\' Extract.subject '\S' Extract.session '\'];
% for irun = 1:size(Extract.runs,2) % 2012-03-02 SF: Works for Cells
%     Extract.file_name{irun}=[Extract.subject 's' Extract.session 'r' Extract.runs{irun}];
% end

% Get CRX and FIF Sample_Index data
load([Extract.file_path 'CRX_data\' Extract.subject 's0' Extract.session 'r' Extract.CRX_file.runs{1}]);
sample_idx_crx = S.App_Sampled.Sample_Index;
clear S

sample_idx_fif=Load_from_FIF(Extract,'STI');

% Figure stuff out
first_sample_idx_crx = min(sample_idx_crx);

first_point_fif=find(sample_idx_fif==(mod(first_sample_idx_crx,255)-1),1,'first'); % SHOULD DOUBLE CHECK THIS GUY WITH THE -1

% last sample
isample = length(sample_idx_fif);
while sample_idx_fif(isample) == sample_idx_fif(end)
    isample = isample -1;
end
last_point_fif=isample+1;

%% Define new sample Index
clear new_sample_idx_fif
jump_number = 1; % starts above 256
previous_jump_sample = 0;
sample_cnt = 0;
for isample = first_point_fif:last_point_fif
    sample_cnt = sample_cnt +1;
    
    if sample_idx_fif(isample)==0 && previous_jump_sample<(isample-1000)
        jump_number = jump_number+1;
        previous_jump_sample=isample;
    end
    
    bitfix = (256*jump_number);
    new_sample_idx_fif(sample_cnt,:) = sample_idx_fif(isample)+bitfix;
end
    
% figure; 
% subplot(3,1,1);plot(sample_idx_crx)
% subplot(3,1,2);plot(sample_idx_fif)
% subplot(3,1,3);plot(new_sample_idx_fif)
% 
% length(new_sample_idx_fif)
% min(new_sample_idx_fif)
% max(new_sample_idx_fif)
% 
% min(sample_idx_crx)
% max(sample_idx_crx)
%     
    














