% ExpDefs=Prep_ExpDefs(ExpDefs) 
%
% Used to automatically populate the Experimental Definitions struct ("ExpDefs") that contains standard values for experimental stuff, like target code names
% ExpDefs.paradigm_type is required, usually set: ExpDefs.paradigm_type=Extract.paradigm_type;
% If you add more paradigm types, make sure to also change Prep_TargetCode
%
% ===OPTIONS===
%     'Open Loop MEG'
%     'Closed Loop MEG' (02-09-2012)
%     'Mapping' (2013-03-22)
%
% Stephen Foldes (2012-01-31)
% UPDATES
% 2012-09-05 Foldes: paradigm_type no longer has spaces
% 2013-03-22 Foldes: Added "Mapping" paradigm, now uses menu for picking if unknown type
% 2013-08-06 Foldes: paradigm_type made lowercase so it can doesn't get tripped up by casing

function ExpDefs=Prep_ExpDefs(ExpDefs)

paradigm_list = {'Open_Loop_MEG','Closed_Loop_MEG','Mapping'}; % 2013-03-22

%% Setup

if ~exist('ExpDefs')
    ExpDefs=[];
end
if ~isfield(ExpDefs,'paradigm_type') || isempty(ExpDefs.paradigm_type)
    choice = menu('Paradigm Type: ',paradigm_list);
    ExpDefs.paradigm_type = cell2mat(paradigm_list(choice));
    pause(0.1)
end

%%

switch lower(ExpDefs.paradigm_type)
    case {'open_loop_meg', 'open_loop_pre_rtmeg', 'open_loop_post_rtmeg'}
        
        % target_code is the main target information...always
        ExpDefs.target_code.baseline=1;
        ExpDefs.target_code.block_start=2;
        ExpDefs.target_code.move=3;
        ExpDefs.target_code.btw_movements=4;
        ExpDefs.target_code.rest=5;
        % ExpDefs.target_code.initialblank=0;
        
        % Codes if looking by block
        ExpDefs.target_code_by_block.video_start=2;
        ExpDefs.target_code_by_block.rest=3;
        ExpDefs.target_code_by_block.baseline=1;
        
        % used to break up the data, use .target_code later
        ExpDefs.video_target_code.move=2;
        ExpDefs.video_target_code.rest=3;
        ExpDefs.video_target_code.baseline=1;
        % ExpDefs.video_target_code.initialblank=0;
        
        ExpDefs.nonvideo_target_code.move=3;
        ExpDefs.nonvideo_target_code.rest=5;
        ExpDefs.nonvideo_target_code.baseline=1;
        
    case 'closed_loop_meg'
        % For Brain Controlled Flip book control
        
        ExpDefs.state_code.iti = 0;
        ExpDefs.state_code.initialize_display = 1;
        ExpDefs.state_code.show_target = 2;
        ExpDefs.state_code.go = 3;
        
        ExpDefs.target_code.move=1;
        ExpDefs.target_code.btw_movements=0;
        ExpDefs.target_code.rest=2;
        
    case 'mapping' % 2013-03-22
        % Original Target Code
        %                |------20s------|               |------20s------|               |------20s------|               |------20s------|
        % ------20s------|               |------20s------|               |------20s------|               |------20s------|               |------20s------|
        %
        % New Target Code
        %                |-----------------MOVE------------------|    
        %                  |-| |-| |-| |-| |-| |-| |-| |-| |-| |-|
        %  rest     rest |-| |-| |-| |-| |-| |-| |-| |-| |-| |-| |
        % ------| |------|                                       |------| |------| ...
        %       |-|                                                     |-|    
        % CRX codes in data
        ExpDefs.video_target_code.rest=1;        
        ExpDefs.video_target_code.move=2;
        
        % Target codes to change to
        ExpDefs.target_code.move=3;
        ExpDefs.target_code.btw_move=2;
        ExpDefs.target_code.rest=1;
        ExpDefs.target_code.btw_rest=0; % making multiple rests
        
        % Timing parameters for Prep_TargetCode()
        ExpDefs.move1_durationS = 1;
        ExpDefs.move2_durationS = 1;
        ExpDefs.rest1_durationS = 20;
        ExpDefs.rest2_durationS = 1; % a break between artifical rest-trials
        
end










