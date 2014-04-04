function move_events=Calc_Event_Reps_PerBlock(org_move_events,block_start_events,num_reps_per_block,first_rep_rx_time)
% returns event indicies for the first 'num_reps_per_block' reps for each block
% first_rep_rx_time[OPTIONAL] = Add a time delay to the first rep in a block (usually there is is more of a delay) (in samples)
% EXAMPLES:
%   Get the first 4 reps of EMG triggers for each block.
%       move_events=Calc_Event_Reps_PerBlock(Events.EMG,Events.ParallelPort_BlockStart,4);
% 
%   Get the first 4 reps of move cues for each block, but add a 300ms reaction time to the first reps
%       move_events=Calc_Event_Reps_PerBlock(Events.ParallelPort_Move,Events.ParallelPort_BlockStart,4,0.3*Extract.data_rate);
% 
% 2013-07-15 Foldes
% UPDATES:
% 2013-07-30 Foldes: I'm too lazy to deal w/ matrix dimension issues
% 2013-08-29 Foldes: I take your lazyness and raise you. fixed issue with if you have less events than num_reps_per_block

if ~exist('first_rep_rx_time') || isempty(first_rep_rx_time)
    first_rep_rx_time = 0;
end

move_events=[];
for iblock = 1:length(block_start_events)
    
    first_move_events_idx = find(org_move_events>block_start_events(iblock),num_reps_per_block,'first');
    
    block_rx_vec = zeros(1,length(first_move_events_idx))';
    block_rx_vec(1) = first_rep_rx_time;
    try
        move_events = [move_events (org_move_events(first_move_events_idx) + block_rx_vec)'];
    catch % 2013-07-30
        move_events = [move_events (org_move_events(first_move_events_idx)' + block_rx_vec)'];
    end
end


%% Plot current events
% figure;hold all
% plot(TimeVecs.timeS,TimeVecs.target_code')
% stem(TimeVecs.timeS(move_events),5*ones(1,length(move_events))','r.-')
% Figure_Stretch(2)
