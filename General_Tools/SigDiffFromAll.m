% [last_sig_condition,sig_diff]=SigDiffFromAll(data,repeats)
% Stephen Foldes 03-30-11
%
% ALWAYS CHECK THE MATH
% Looks for conditions that are sig diff from final condition
% Used for changing amount of data and comparing results from a smaller subset of the data to all the data
% Example, accuracy using different amounts of training data compared to using all the data
% repeats = number of repeats of the cross validation (assumes every CV-fold is independent measure, but then each CV-repeat is not necessarily)
% This is non-parametric, using bonferroni correction

function [last_sig_condition,sig_diff]=SigDiffFromAll(data,repeats,alpha)

% for icondition = 1:size(data,2)
%     [temp p_gaussian(icondition)]=kstest(data(:,icondition));
% %     figure;hist(data(:,icondition))
% end
% 
% [p,table,stats] = anova1(data);
% c=multcompare(stats,'alpha',alpha,'estimate','anova1');
% 
% [p,table,stats] = anova2(data,repeats);
% c=multcompare(stats,'alpha',alpha,'ctype','bonferroni','estimate','column');
% %
if repeats == 1
    [p,table,stats] = kruskalwallis(data);
    c=multcompare(stats,'alpha',alpha,'estimate','kruskalwallis');
    close
else
    [p,table,stats] = friedman(data,repeats);
    c=multcompare(stats,'alpha',alpha,'estimate','friedman');
end
close


% Find what conditions are sig diff from the end condition
end_compare = c(find(c(:,2)==size(data,2)),:);

for icompare=1:size(end_compare,1)
    sig_diff(icompare)=sign(end_compare(icompare,5)) == sign(end_compare(icompare,3));
end

last_sig_condition = find(sig_diff>0,1,'Last');
