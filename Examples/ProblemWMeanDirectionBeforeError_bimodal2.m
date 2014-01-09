%2012-06-03
clear 

num_trials = 1000;
target = [0 45 90 135 180 -135 -90 -45];

predict_mean(1) = 180;
predict_sd(1) = 360;

% predict_mean(2) = 90;
% predict_sd(2) = 10;
% 
% predict_mean(3) = 180;
% predict_sd(3) = 10;
% 
% predict_mean(4) = -90;
% predict_sd(4) = 10;

% predict_mean(1) = 45;
% predict_sd(1) = 10;
% 
% predict_mean(2) = -45;
% predict_sd(2) = 10;
% 
% predict_mean(3) = 135;
% predict_sd(3) = 10;
% 
% predict_mean(4) = -135;
% predict_sd(4) = 10;


num_mods = length(predict_mean);
num_trials_per_mod = floor(num_trials/num_mods);

itrial = 0;predicted_original=[];
for imodal = 1:num_mods
    
    while length(predicted_original) < num_trials_per_mod*imodal
        current_pick = random('Normal',predict_mean(imodal),predict_sd(imodal));
        if current_pick>-180 && current_pick<=180
            itrial =itrial+1;
            predicted_original(itrial,1) = current_pick;
        end
        
    end
    
end %modes

figure;hold all
hist(predicted_original)


for itarget = 1:length(target)
    figure(itarget);hold all
    
    subplot(2,2,1)
    rose(target(itarget)*(pi/180),100)
    title('Target')
    subplot(2,2,2)
    rose(predicted_original*(pi/180),100)
    title('Predicted')
end

disp(' ')
disp('  Predicted Angle')
disp_mean_std(predicted_original)

%% Error per prediction

predicted=(predicted_original);

for itarget = 1:length(target)
    error(:,itarget) = abs(predicted - target(itarget));
    mean_error(itarget) = mean(error(:,itarget));

    figure(itarget);
    subplot(2,2,3);
    rose(error(:,itarget)*(pi/180),100)
    title('Error per prediction (single trial)')
end

disp('  Error per prediction (single trial)')
disp_mean_std(mean_error')



%% Error of average prediction

predicted = mean(predicted_original);

for itarget = 1:length(target)
    error(:,itarget) = abs(predicted - target(itarget));
    mean_error(itarget) = mean(error(:,itarget));
    
    figure(itarget);
    subplot(2,2,4);
    rose(error(:,itarget)*(pi/180),100)   
    title('Error of average prediction')
end

disp('  Error of average prediction')
disp_mean_std(mean_error')



