% When CRX is started a '255' is sent via the parallel port
% This removes the data before and after (actually sets it to -1)
%
% Foldes 2013-07-03

function STI_data = remove_pport_trigger_from_CRX_startstop(STI_data)

total_length=size(STI_data,1);
on_trigger_idx = find(STI_data>100,1,'first');
off_trigger_idx = find(STI_data>100,1,'last');


if (on_trigger_idx<total_length/2) % on trigger must happen in first 1/2 of the data
    STI_data(1:on_trigger_idx)=-1; % remove all before
end

if (off_trigger_idx>total_length/2) % off trigger must happen in LAST 1/2 of the data
    STI_data(off_trigger_idx:end)=-1; % remove all AFTER
end

STI_data(STI_data>100)=-1; % remove 255s themselves
