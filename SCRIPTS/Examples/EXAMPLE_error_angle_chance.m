% EXAMPLE_error_angle_chance
% ST Foldes (2012-03-06)
% 
% Calculates the chance level of error between vectors. Uses rand() random number generator.
% Can define number of dimensions and number of observations.
% Uses Dot Product
% Plots the histogram with the mean+-sd

num_dim =3;
num_obs = 100000;

% Make points (-1 to +1)
predict=(rand(num_obs,num_dim)*2)-1;
actual=(rand(num_obs,num_dim)*2)-1;

% Make points on the unit circle (unnecssary b/c norm is removed in error angle calculation, but doesn't hurt)
predict_unit = predict/norm(predict);
actual_unit = actual/norm(actual);

% Calculate the error angle using dot product
error_angle=zeros(num_obs,1);
for itrial = 1:num_obs
    error_angle(itrial) = acosd(dot(predict_unit(itrial,:),actual_unit(itrial,:))./(norm(predict_unit(itrial,:))*norm(actual_unit(itrial,:)))); % norms should = 1 by definition
end

figure;hist(error_angle)
ylabel('Incidence');xlabel('Error Degrees')
title(['Mean+-SD = ' num2str(mean(error_angle)) '+-' num2str(std(error_angle))])

