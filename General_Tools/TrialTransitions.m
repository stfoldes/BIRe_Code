function [trial_change_idx, min_trial_size, num_trials]=TrialTransitions(trial_marker,marker2match)
% Gives list of when trials change = trial transitions (including first and last sample)
%
% trial_marker = vector of points that indicate trial transitions (doesn't have to be discrete)
% marker2match[OPTIONAL] = if used, will return trials transitions ONLY for trials that start with this value
%     For example, return only trials of 'type' 4
%
% Stephen Foldes [2009-07]
% UPDATES:
% 07-08-09 SF: Diff finds last point before change, this addition now marks first point after change
% 08-22-09 SF: Number of blocks and number of trials was not always correct (block might have unequal amounts of trials)
% 03-02-11 SF: Reorganized. Also, if a change in cue happens in less than 4 samples, it removes that trial (changed from 2 to 4 b/c of MEG data at Pitt), 1 = no removal critera
% 04-12-11 SF: Re-simplified. Might not work for old cases.
% 2012-11-06 Foldes: Revamped w/ new variable names. Added variable that makes sure trials aren't really short
% 2013-08-21 Foldes: Now can match a value given, removed 'min_trial_length' mechanism

trial_change_idx = unique([1; find(abs(diff(trial_marker))>0)+1; size(trial_marker,1)]);

% % remove changes that are very small (happens when removing noise or with weird cues) REMOVED 2013-08-21
% diff_trial_change_idx=diff(trial_change_idx);
% trial_change_idx(find(diff_trial_change_idx<min_trial_length)+1)=[];

% if you have a marker2match, then extract those only
if exist('marker2match') && ~isempty(marker2match)
    matching_idx = find(trial_marker(trial_change_idx)==marker2match);
    trial_change_idx = trial_change_idx(matching_idx);
end

num_trials=(size(trial_change_idx,1)-1); % -1 to discount the final trial off
min_trial_size=min(diff(trial_change_idx)-1); % '-1' b/c trial ends before next starts
