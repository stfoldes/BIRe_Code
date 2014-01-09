%{
Find_Rsquared()
Stephen Foldes
060308

This function finds R squared given actual and predicted responses.
I can't believe matlab doesn't have this function!
This code is addapted from the regress() and regstat() function

y=actual response (target location) (n x 1)
yhat=predicted response (estimated target location) (n x 1)
    yhat = X*b;
r2 = R squared statistic

From preliminary research, it seems there is not one standard way to calculate R2, so a few methods are shown below.
Matlab's versions are include.

%}

function r2=Find_Rsquared(y,yhat)


%% R2 from MATLAB (Can output negative for 'unappropriate' models)
% % "The R-square value is one minus the ratio of the error sum of squares to the total sum of squares.  This value
% % can be negative for models without a constant, which indicates that the model is not appropriate for the data."
% 
%     residuals = y - yhat;
%     sse = norm(residuals)^2;    % sum of squared errors
%     sst = norm(y - mean(y))^2;  % total sum of squares;
% 
%     r2 = 1 - sse ./ sst;        % R-square statistic.

%% Adjusted R2 from MATLAB (Takes into concideration number of parameters.  Number of parameters can inflate R2 value)
%  Very similar to R2 above for my data
%
%     residuals = y - yhat;
%     sse = norm(residuals)^2;    % sum of squared errors
%     sst = norm(y - mean(y))^2;  % total sum of squares;
% 
%     nobs = length(y);
%     %p = length(beta);  % number of parameters
%     p = 5;  % number of parameters
%     dfe = nobs-p;
%     dft = nobs-1;
% 
%     % Rsquared Adjusted
%     r2 = 1 - (sse./sst)*(dft./dfe);

%% Using correlation coeficient (since Rsquared=R^2)

    r=corrcoef([y yhat]);
    r2=r(1,2)^2;

%% Alternative calculation of R-squared 
% % Very similar to using correlation coeficient for my data
%     % (from http://www.ifremer.fr/lpo/gmaze/toolbox/matlab/vrac/1/mregress.html)
% 
% % The follwing equation is from Judge G, et al. "An Introduction to the theory
% % and practice of econometrics", New York : Wiley, 1982. It is the
% % squared (Pearson) correlation coefficient between the predicted and
% % dependent variables. It is the same equation regardless of whether an
% % intercept is included in the model; however, it may yield a negative
% % R-squared for a particularily bad fit.
% 
%     covariance_yhat_and_y = (yhat - mean(yhat))' * (y - mean(y));
%     covariance_yhat_and_yhat = (yhat - mean(yhat))' * (yhat - mean(yhat));
%     covariance_y_and_y = (y - mean(y))' * (y - mean(y));
%     r2 = (covariance_yhat_and_y / covariance_yhat_and_yhat) * (covariance_yhat_and_y / covariance_y_and_y);



