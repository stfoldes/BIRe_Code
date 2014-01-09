% TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs);
% Helps to fill in TImeVecs standard structure
% ***JUST FOR STEPHEN'S MOVEMENT VIDEO OR CROSSHAIRS PARADIGM VIA CRANIUX***
%
% needs TimeVecs.target_code_org, TimeVecs.data_rate ExpDefs.paradigm_type
% If you add more paradigm_types, dont forget to change Prep_ExpDefs.m
%
% Stephen Foldes (2012-02-07)
% UPDATES
% 2012-09-05 Foldes: "paradigm_type" now does not have spaces in it.
% 2012-10-02 Foldes: TimeVecs.data_rate replaces ExpDefs.data_rate
% 2013-01-07 Foldes: Started fixing for different paradigm organizations
% 2013-03-06 Foldes: Cleaned up a bit. Removed outdated error messages
% 2013-03-25 Foldes: Added "Mapping"
% 2013-04-17 Foldes: Fixed Mapping to remove any trials that don't fit within the data
% 2013-07-03 Foldes: target_code now has pre/post crx-start/stop-triggers remove (255)
% 2013-08-06 Foldes: paradigm_type made lowercase so it can doesn't get tripped up by casing, CRX trigger removed from target_code_org

function TimeVecs=Prep_TargetCode(TimeVecs,ExpDefs)

% remove 255 crx on-off signals [2013-08-06]
TimeVecs.target_code_org = remove_pport_trigger_from_CRX_startstop(TimeVecs.target_code_org); % 2013-07-03

switch lower(ExpDefs.paradigm_type)
    case {'open_loop_meg', 'open_loop_pre_rtmeg', 'open_loop_post_rtmeg'}

        %% *** HOW TO DEAL WITH BROKEN PARALLEL PORT? ***
        if max(TimeVecs.target_code_org)>260
            warning('THE PARALLEL PORT WAS MESSED UP')
            return
        end
        
%% Make Target Codes for Video-tasks and Non-video-tasks (i.e. TimeVecs.target_code_by_block vs. TimeVecs.target_code_by_movement)

%% ====NON-VIDEO TASK====
    % Currently, if target code of 5 is used, then you're doing the non-video task
    if max(unique(TimeVecs.target_code_org)==5) == 1
        disp('Non-Video Task Type Detected')
        % move_cue = 3; ExpDefs.nonvideo_target_code.move

        trial_change_idx=TrialTransitions(TimeVecs.target_code_org);
        trial_target_code = TimeVecs.target_code_org(trial_change_idx);
        move_trial_num = find(trial_target_code==ExpDefs.nonvideo_target_code.move);

        % vector of when each block starts
        movement_block_onset_idx = trial_change_idx(find(trial_target_code==2)); % start at 2 (same as video, where there is a pause)

        % Make a video-like target code
        % target codes 2,3,4 are part of the video time
        clear TimeVecs.target_code_by_block
        TimeVecs.target_code_by_block=((TimeVecs.target_code_org>=2) & (TimeVecs.target_code_org<=4))*2; % make move blocks = 2
        TimeVecs.target_code_by_block=TimeVecs.target_code_by_block + (TimeVecs.target_code_org==5)*3; % make move blocks = 3

        % TimeVecs.target_code_org is already in movement-organized form
        TimeVecs.target_code_by_movement=TimeVecs.target_code_org;

%% ====VIDEO TASK====
    else % This is a video task
        disp('Video Task Type Detected')
        % move_cue = 2; ExpDefs.video_target_code.move

        trial_change_idx=TrialTransitions(TimeVecs.target_code_org);
        trial_target_code = TimeVecs.target_code_org(trial_change_idx);
        move_trial_num = find(trial_target_code==ExpDefs.video_target_code.move);
        rest_trial_num = find(trial_target_code==ExpDefs.video_target_code.rest);

        % TimeVecs.target_code_org is already in block-organized form
        TimeVecs.target_code_by_block=TimeVecs.target_code_org;
        
        % vector of when each block starts
        movement_block_onset_idx = trial_change_idx(move_trial_num);

        % Make like non-video WARNING, THIS MIGHT NOT ALWAYS WORK
        
        % ***WARNING: HARD CODING DURATIONS FOR VIDEO PARADIGMS***
        initial_restS = 2; 
        long_restS = 5;
        move1_durationS = 1;
        move2_durationS = 1;
        num_reps_vec = [];
        % **********************************************************************************
        
        TimeVecs.target_code_by_movement = TimeVecs.target_code_org;
        for itrial = 1:size(move_trial_num,1)
            event_start = 0;event_end = event_start+(initial_restS*TimeVecs.data_rate);% first rest = 2
            TimeVecs.target_code_by_movement(trial_change_idx(move_trial_num(itrial))+event_start:trial_change_idx(move_trial_num(itrial))+event_end-1)=2;

            total_move_block_timeS = length(trial_change_idx(move_trial_num(itrial)):trial_change_idx(rest_trial_num(itrial)))/TimeVecs.data_rate;
            num_reps = round( (total_move_block_timeS-initial_restS)/(move1_durationS+move2_durationS) );
            num_reps_vec = [num_reps_vec num_reps];
            
            for rep = 1:num_reps
                event_start = event_end; event_end = event_start+(move1_durationS*TimeVecs.data_rate);% move                
                TimeVecs.target_code_by_movement(trial_change_idx(move_trial_num(itrial))+event_start:trial_change_idx(move_trial_num(itrial))+event_end-1)=3;
                event_start = event_end; event_end = event_start+(move2_durationS*TimeVecs.data_rate);% rest
                TimeVecs.target_code_by_movement(trial_change_idx(move_trial_num(itrial))+event_start:trial_change_idx(move_trial_num(itrial))+event_end-1)=4;
            end

            event_start = event_end; event_end = event_start+(long_restS*TimeVecs.data_rate);% long rest WARNING, THIS MIGHT NOT ALWAYS WORK
            TimeVecs.target_code_by_movement(trial_change_idx(move_trial_num(itrial))+event_start:trial_change_idx(move_trial_num(itrial))+event_end-1)=5;
        end

    end % video or no video
    
%         % THIS IS GOOD STUFF
%         figure;hold all
%         plot([0:size(TimeVecs.target_code_org,1)-1]*(1/TimeVecs.data_rate),zscore(TimeVecs.kinematics_processed),'Color',0.7*[1 1 1])
%         plot([0:size(TimeVecs.target_code_org,1)-1]*(1/TimeVecs.data_rate),TimeVecs.target_code_org,'k','LineWidth',3)
%         plot([0:size(TimeVecs.target_code_org,1)-1]*(1/TimeVecs.data_rate),TimeVecs.target_code_by_block,'r','LineWidth',2)
%         plot([0:size(TimeVecs.target_code_org,1)-1]*(1/TimeVecs.data_rate),TimeVecs.target_code_by_movement,'g','LineWidth',2)
%         xlabel('Time[s]')
%         ylim([-1 7])
%         legend('EMG','base target pos','target pos by block','target pos by movement')
    
    TimeVecs.target_code = TimeVecs.target_code_by_movement; % for this analysis, target pos is by each individual movement. Corrisponds to ExpDefs.target_code.*
    
    
    case 'mapping'
        % See Prep_ExpDef()
        % 2013-03-25 Foldes
        %
        % Original Target Code
        %                |------20s------|               |------20s------|               |------20s------|               |------20s------|
        % ------20s------|               |------20s------|               |------20s------|               |------20s------|               |------20s------|
        %
        % New Target Code
        %                  |-| |-| |-| |-| |-| |-| |-| |-| |-| |-|
        %                |-| |-| |-| |-| |-| |-| |-| |-| |-| |-| |
        % ------20s------|                                       |------20s------| ...

        disp('MAPPING Video Task Type Detected')
        disp('***************************************')
        disp('************GENERIC MAPPING************')
        disp('***************************************')
        % move_cue = 2; ExpDefs.video_target_code.move

        trial_change_idx=TrialTransitions(TimeVecs.target_code_org);
        trial_target_code = TimeVecs.target_code_org(trial_change_idx);
        
        % last good data idx (where 255 happens towards the end)
        last_half_of_trials = floor(length(trial_target_code)/2):length(trial_target_code);
        last_good_idx = trial_change_idx(last_half_of_trials(find(trial_target_code(last_half_of_trials) == 255,1,'First')))-1; % kinda complicated
        if isempty(last_good_idx)
            last_good_idx = trial_change_idx(end);
        end
        
        % remove 255 crx on-off signals        
        trial_change_idx(trial_target_code == 255)=[];
        trial_target_code = TimeVecs.target_code_org(trial_change_idx);

        move_trial_num = find(trial_target_code==ExpDefs.video_target_code.move);
        rest_trial_num = find(trial_target_code==ExpDefs.video_target_code.rest);
        move_rest_trial_num = sort([move_trial_num; rest_trial_num]);

        % TimeVecs.target_code_org is already in block-organized form
        TimeVecs.target_code_by_block=TimeVecs.target_code_org;
        
        % vector of when each block starts
        movement_block_onset_idx = trial_change_idx(move_trial_num);

        % Make like non-video WARNING, THIS MIGHT NOT ALWAYS WORK
        % Get timing parameters from Prep_ExpDefs()
        
        TimeVecs.target_code_by_movement = TimeVecs.target_code_org;
        for itrial = 1:size(move_rest_trial_num,1)
            event_end=0; % Start at 0

            switch TimeVecs.target_code_org(trial_change_idx(move_rest_trial_num(itrial)))
                case ExpDefs.video_target_code.move
                    current_trial_type = 'move';
                    current_block_durationS = ExpDefs.move1_durationS+ExpDefs.move2_durationS;
                    event1_durationS = ExpDefs.move1_durationS; event1_code = ExpDefs.target_code.move; % STARTS WITH FLEXION
                    event2_durationS = ExpDefs.move2_durationS; event2_code = ExpDefs.target_code.btw_move;
                case ExpDefs.video_target_code.rest
                    current_trial_type = 'rest';
                    current_block_durationS = ExpDefs.rest1_durationS+ExpDefs.rest2_durationS;
                    event1_durationS = ExpDefs.rest1_durationS; event1_code = ExpDefs.target_code.rest;
                    event2_durationS = ExpDefs.rest2_durationS; event2_code = ExpDefs.target_code.btw_rest;
            end
            
            % duration of this block
            try
                end_block_time = trial_change_idx(move_rest_trial_num(itrial+1));
            catch
                end_block_time = last_good_idx;
            end
            total_move_block_timeS = length(trial_change_idx(move_rest_trial_num(itrial)):end_block_time)/TimeVecs.data_rate;
                      
            % how many reps can we fit in this block? (NOT floor b/c timing from parallel port not always perfect)
            num_reps = round( (total_move_block_timeS)/(current_block_durationS) );
            %num_reps_vec = [num_reps_vec num_reps];
            
            % Mark each rep
            for rep = 1:num_reps
                event_start = event_end; event_end = event_start+(event1_durationS*TimeVecs.data_rate);% event stage 1               
                if (trial_change_idx(move_rest_trial_num(itrial))+event_end-1) < last_good_idx % only assign values if you're still within the bounds of the data (2013-04-17 Foldes)
                    TimeVecs.target_code_by_movement(trial_change_idx(move_rest_trial_num(itrial))+event_start:trial_change_idx(move_rest_trial_num(itrial))+event_end-1)=event1_code;
                else
                    TimeVecs.target_code_by_movement(trial_change_idx(move_rest_trial_num(itrial))+event_start:last_good_idx)=-1; % This trial would be too short, mark it as 'bad'
                end
                
                event_start = event_end; event_end = event_start+(event2_durationS*TimeVecs.data_rate);% event stage 2
                if (trial_change_idx(move_rest_trial_num(itrial))+event_end-1) < last_good_idx % only assign values if you're still within the bounds of the data (2013-04-17 Foldes)
                    TimeVecs.target_code_by_movement(trial_change_idx(move_rest_trial_num(itrial))+event_start:trial_change_idx(move_rest_trial_num(itrial))+event_end-1)=event2_code;
                else
                    TimeVecs.target_code_by_movement(trial_change_idx(move_rest_trial_num(itrial))+event_start:last_good_idx)=-1; % This trial would be too short, mark it as 'bad'
                end
            end
        end
        
        %         % THIS IS GOOD STUFF
        %         figure;hold all
        %         %         plot([0:size(TimeVecs.target_code_org,1)-1]*(1/TimeVecs.data_rate),zscore(TimeVecs.kinematics_processed),'Color',0.7*[1 1 1])
        %         plot([0:size(TimeVecs.target_code_org,1)-1]*(1/TimeVecs.data_rate),TimeVecs.target_code_org,'k','LineWidth',3)
        %         plot([0:size(TimeVecs.target_code_org,1)-1]*(1/TimeVecs.data_rate),TimeVecs.target_code_by_block,'r','LineWidth',2)
        %         plot([0:size(TimeVecs.target_code_org,1)-1]*(1/TimeVecs.data_rate),TimeVecs.target_code_by_movement,'g','LineWidth',2)
        %         xlabel('Time[s]')
        %         ylim([-1 7])
        %         Figure_Stretch(3)
  
        TimeVecs.target_code = TimeVecs.target_code_by_movement; % for this analysis, target pos is by each individual movement. Corrisponds to ExpDefs.target_code.*

%%    
    otherwise
        TimeVecs.target_code = TimeVecs.target_code_org;
        
end


% Remove CRX start/stop 255 signal...maybe 2013-07-03 Foldes
TimeVecs.target_code = remove_pport_trigger_from_CRX_startstop(TimeVecs.target_code); % 2013-07-03

