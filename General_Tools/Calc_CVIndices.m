% [train_idx test_idx]=Calc_CVIndices(num_trials,num_repeats,num_folds,random_flg)
% Stephen Foldes (2009/10/29)
% 
% WARNING, THIS DOES NOT USE CLASS INFORMATION, CAN NOT USE CLASS SPECIFIC DATA
% 
% Gets matrices for indices for both training and test trials
% Works for an MxN CV
% result index matrices are [iteration x block-number]
% 
% EXAMPLE (20 trials, 5x2fold randomized CV, keeping blocks of 2 trials together)
% CV.trial_list = [1:20];
% [CV.train_idx CV.test_idx]=Calc_CVIndices(length(CV.trial_list)/2,5,2,1);
% 
% for icv = 1:size(CV.test_idx,1) 
%   CV.training_trial_list=sort([2*(CV.train_idx(icv,:)-1)+1 2*(CV.train_idx(icv,:)-1)+2]);
%   CV.test_trial_list=sort([2*(CV.test_idx(icv,:)-1)+1 2*(CV.test_idx(icv,:)-1)+2]);
%   ...
%
% 2009-10-29 SF: Can determine if you want to randomize the indices or not with random_flg
% 2012-03-19 SF: Renamed from GetCVIndices.m, added example

function [train_idx test_idx]=Calc_CVIndices(num_trials,num_repeats,num_folds,random_flg)

% Check if too many folds are requested
if num_trials<num_folds
    disp('TOO MANY FOLDS FOR CROSSVALIDATION')
    keyboard
end

% the number of total CVs
num_CVs=num_repeats*num_folds; 

% amount of trials used for testing
fold_size=floor(num_trials/num_folds);

% initialize counter
CV_cnt=1;

% initialize indicies matrix
test_idx=zeros(num_CVs, fold_size);
train_idx=zeros(num_CVs, (fold_size*num_folds)-fold_size );

% go through repeats
for irepeats= 1:num_repeats
    
    if random_flg
        % randomized trial index each repeat
        rand_trial_idx= randperm(num_trials);
    else
        % DONT randomized trial index each repeat
        rand_trial_idx=1:num_trials;
    end
    
    % go through folds
    for ifolds = 1:num_folds
        
        % Get test set
        test_idx(CV_cnt,:)=rand_trial_idx(1, (ifolds-1)*fold_size+1 : ifolds*fold_size );
        
        % Get training data
        clear this_train_idx
        this_train_idx = rand_trial_idx; % all trials possible
        % remove test data
        this_train_idx((ifolds-1)*fold_size+1 : ifolds*fold_size) = [];
        train_idx(CV_cnt,:)=this_train_idx(1:(fold_size*num_folds)-fold_size); %10-24-08 SF limit this to 1/num_folds


        CV_cnt=CV_cnt+1;
        
    end % end folds loop 
end % end repeat loop

