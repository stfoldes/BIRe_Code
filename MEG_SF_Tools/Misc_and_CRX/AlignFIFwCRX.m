
% Sample Index sent via Parallel Port (i.e. 8bit) will:
%     1. Starte at 176 until CRX is turned on
%     2. Go to 0 when CRX turns on
%     3. Increment Sample Index until it reaches 255
%     4. Drop back down to 0 and contiune up to 255 again

function [raw_data TimeVecs] = Load_FIF_wCRX(Extract)


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
% clear S

sample_idx_fif=Load_from_FIF(Extract,'STI');


% First sample in the CRX file
first_sample_idx_crx = min(sample_idx_crx);

% Index in FIF where the first CRX Sample Index happens
first_point_fif=find(sample_idx_fif==(mod(first_sample_idx_crx,255)-1),1,'first'); % SHOULD DOUBLE CHECK THIS GUY WITH THE -1

% Index in FIF where the last CRX Sample Index happens
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
    

%% Load FIF data and remove extra stuff so it matches CRX files
    [raw_data]=Load_from_FIF(Extract,'MEG');

    raw_data(last_point_fif+1:end,:)=[];
    raw_data(1:first_point_fif-1,:)=[];
    
    TimeVecs.sample_idx = new_sample_idx_fif;
    
    % Load Extra stuff if desired
%     if isfield(Extract,'load_EMG_flag') && Extract.load_EMG_flag==1
%         [TimeVecs.EMG_data]=Load_EMG_from_FIF(Extract); % Only extracts if flag set
%         [TrialInfo.kinematic_trial_start_idx,TimeVecs.kinematics_triggers,TimeVecs.kinematics_processed,EMG_thres] = Calc_Processed_EMG(TimeVecs.EMG_data(:,1),1,1,TimeVecs.target_code_org,Extract.data_rate);
%     end
%     if isfield(Extract,'load_MISC_flag') && Extract.load_MISC_flag==1
%         [TimeVecs.MISC_data]=Load_MISC_from_FIF(Extract); % Only extracts if flag set
%     end

    TimeVecs.timeS=[0:size(raw_data,1)-1]*(1/Extract.data_rate);


%% Extract TimeVec info from CRX and resample to fit FIF

    %---Resample FeatureSeries variables into TimeSeries (Currently just for getting S.App_Sampled.* into TimeVecs.*)---
    % This might take a little bit of time, not sure why

    clear fields_to_resample
    fields_to_resample{1} = 'Target_Code'; new_field_names{1} = 'target_code';
    fields_to_resample{2} = 'State_Code'; new_field_names{2} = 'state_code';
    fields_to_resample{3} = 'Training'; new_field_names{3} = 'training_code';
    fields_to_resample{4} = 'Target_Position'; new_field_names{4} = 'target_pos';
    fields_to_resample{5} = 'Control_Position'; new_field_names{5} = 'cursor_pos';
    
    total_timeseries_samples=size(raw_data,1);
    num_timeseries_blocks=size(S.Acq_Sampled.Raw_Data,1);

%     tic
    for ifield = 1:size(fields_to_resample,2)
        try
            %timeseries_block_idx_by_sample_idx=zeros(total_timeseries_samples,1);
            eval(['TimeVecs.' new_field_names{ifield} '=zeros(total_timeseries_samples,size(S.App_Sampled.' fields_to_resample{ifield} ',2));'])

            eval(['cell_field_flag = iscell(S.App_Sampled.' fields_to_resample{ifield} ');'])  % won't work for cells
            
            if ~cell_field_flag % Normal, not a cell
                
                for isample = 1:length(TimeVecs.sample_idx)
                    equivelent_app_sample_idx = find(TimeVecs.sample_idx(isample)==S.App_Sampled.Sample_Index);
                    eval(['TimeVecs.' new_field_names{ifield} '(isample,:) = S.App_Sampled.' fields_to_resample{ifield} '(equivelent_app_sample_idx,:);'])
                end
                
            else % is a cell, ***BE CAREFUL***
                for isample = 1:length(TimeVecs.sample_idx)
                    equivelent_app_sample_idx = find(TimeVecs.sample_idx(isample)==S.App_Sampled.Sample_Index);
                    
                    
                    % Gets mad if its empty
                    empty_flg = 0;
                    eval(['empty_flg = isempty(S.App_Sampled.' fields_to_resample{ifield} '{equivelent_app_sample_idx});'])
                    if empty_flg
                        eval(['TimeVecs.' new_field_names{ifield} '(isample,:) = NaN;'])
                    else
                        eval(['TimeVecs.' new_field_names{ifield} '(isample,:) = S.App_Sampled.' fields_to_resample{ifield} '{equivelent_app_sample_idx};'])
                    end
                    
                end % sample
            end % cell or not

        end % TRY (aka please dont crash)
    end % fields to fill

%     toc
    
%     plot_all_children(TimeVecs)

%%

