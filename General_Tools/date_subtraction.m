function d = date_subtraction(t1,t2) 
% WRAPPER
% Come one matlab, how am I supposed to remember daysact, what the hell does that mean anyway?
% also, w/o t2, matlab defaults to using 0000AD or some garbage
%
% 2013-08-15 Foldes

if ~exist('t2') || isempty(t2)
    t2 = datestr(now);
end

d = daysact(t1,t2); 