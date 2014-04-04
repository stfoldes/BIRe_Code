% 
% Determine what data should be used for training keeping the data from each class equal. 
% The simplist method would be to take the minimum trial size accross all classes and just use that much data from each trial. This would ensure equal class sizes.
% This method uses more data by reducing the number of samples from one class to equal that of the other. This is done by removing a % of the samples from each trial. 
% This makes sure that all trials of the larger class are fairly shrunk. 
% This could be further improved by making sure small trials aren't touched (for example, making # of trials removed relative to an exponental curve)
% 

function new_training_trial_start_stop_idx = Equalize_Training_TwoClasses(training_trial_start_stop_idx,training_cue)


    % Training size can be different, so long as the total from each class is the same
    % what happened to the first trial?
    
    
    % how big is each trial
    training_size_by_trial = training_trial_start_stop_idx(:,2) - training_trial_start_stop_idx(:,1);
%     figure;hist(training_size_by_trial)
    
    % what trials belong to which class
    class0_trials=find(training_cue(training_trial_start_stop_idx(:,1))==0);
    class1_trials=find(training_cue(training_trial_start_stop_idx(:,1))==1);
    class_trial_sizes(1) = size(class0_trials,1);
    class_trial_sizes(2) = size(class1_trials,1);
    
    % how many samples in each class
    training_size_class0=sum(training_size_by_trial(class0_trials));
    training_size_class1=sum(training_size_by_trial(class1_trials));
    
    % which class has more and what is the difference
    training_size_diff = abs(training_size_class0-training_size_class1);
    [max_training_size max_training_class_idx] = max([training_size_class0 training_size_class1]);
    

    % what percent of the data needs to be removed, remove that much from each trial (thereby being relative to trial size)
    percent_training_to_remove_from_max = training_size_diff/max_training_size;    
    
    % remove training samples from biggest class, in order of biggest trials
    eval(['max_training_class_trials = class' num2str(max_training_class_idx-1) '_trials;'])
    [sort_max_training_size sort_max_training_size_idx]= sort(training_size_by_trial(max_training_class_trials),'descend');
     
    % what samples should be removed from each trial    
    samples_to_remove_per_trial=floor(percent_training_to_remove_from_max.*sort_max_training_size);
    
    % pick up the extras on the largest trials
    remaining_trials_to_remove=training_size_diff - sum(samples_to_remove_per_trial);
    
    %remove remaining from largest trials
    samples_to_remove_per_trial(1:remaining_trials_to_remove) = samples_to_remove_per_trial(1:remaining_trials_to_remove)+1;
    
%     sum(samples_to_remove_per_trial) == training_size_diff
    
    new_training_trial_start_stop_idx=training_trial_start_stop_idx;   
    eval(['new_training_trial_start_stop_idx(class' num2str(max_training_class_idx-1) '_trials(sort_max_training_size_idx),2) = training_trial_start_stop_idx(class' num2str(max_training_class_idx-1) '_trials(sort_max_training_size_idx),2)- samples_to_remove_per_trial;'])
 
%% Check that this worked

%     % how big is each trial
%     training_size_by_trial = new_training_trial_start_stop_idx(:,2) - new_training_trial_start_stop_idx(:,1);
%     
%     % what trials belong to which class
%     class0_trials=find(training_cue(new_training_trial_start_stop_idx(:,1))==0);
%     class1_trials=find(training_cue(new_training_trial_start_stop_idx(:,1))==1);
%     class_trial_sizes(1) = size(class0_trials,1);
%     class_trial_sizes(2) = size(class1_trials,1);
%     
%     % how many samples in each class
%     training_size_class0=sum(training_size_by_trial(class0_trials));
%     training_size_class1=sum(training_size_by_trial(class1_trials));
%     
%     % which class has more and what is the difference
%     training_size_diff = abs(training_size_class0-training_size_class1)

%% Future?
    
    
%     sum(floor(sqrt(percent_training_to_remove_from_max.*(sort_max_training_size.^2))))
    
    
    
    
    
    
%%

% But when doing a CV this changes, this should be in the CV loop
    
    
    
    
    
    