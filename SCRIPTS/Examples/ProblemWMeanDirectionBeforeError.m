%2012-06-03
clear 

num_trials = 10000;
target = 0;
predict_mean = 12;
predict_sd = 60;

% predicted_original = rand(num_trials,1)*360;

itrial = 0;predicted_original=[];
while length(predicted_original) < num_trials
    current_pick = random('Normal',predict_mean,predict_sd);
    if current_pick>-180 && current_pick<=180
        itrial =itrial+1;
        predicted_original(itrial,1) = current_pick;
    end
       
end

figure;hold all
hist(predicted_original)


figure;hold all
subplot(2,2,1)
rose(predicted_original*(pi/180),100)
title('Predicted')

disp(' ')
disp_mean_std(predicted_original)

%% Error per prediction

% turn +- angles
predicted=predicted_original;
predicted(predicted>180) = -(360-predicted(predicted>180));

error = abs(predicted) - target;
disp_mean_std(error)

subplot(2,2,2);
rose(error*(pi/180),100)
title('Error per prediction')

%% Error of average prediction

predicted = mean(predicted_original);

error = abs(predicted) - target;
disp_mean_std(error)
subplot(2,2,3);
rose(error*(pi/180),100)
title('Error of average prediction')

%% Error of average prediction (after making +-)

predicted=predicted_original;
predicted(predicted>180) = -(360-predicted(predicted>180));

error = abs(mean(predicted)) - target;
disp_mean_std(error)
subplot(2,2,4);
rose(error*(pi/180),100)
title('Error of average |prediction|')

%% GIVE PATTERN



















