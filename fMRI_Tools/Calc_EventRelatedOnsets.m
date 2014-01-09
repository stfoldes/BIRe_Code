% Event-Related Design
% 2013-09-15 Randazzo, Foldes
%
% Event related onsets for SPM 

% get from eprime order
random_events = [1 2 4 3; 1 3 2 4; 2 1 3 4; 2 4 1 3; 2 4 3 1; 4 1 3 2; 4 1 2 3; 1 2 4 3; 1 4 3 2; 3 1 4 2]; 

scan_seq=[];
for iblock = 1:size(random_events,1)
    current_block = random_events(iblock,:);
    for itype = 1:size(random_events,2)
        current_order = find(current_block==itype);
        offset = (current_order-1)*5 + 1;
        scan_seq(itype,iblock) = ((iblock-1)*25)+5+offset;
    end
end

scan_seq(1,:)'

% text cue
(sort(reshape(scan_seq,1,[]))-1)'



