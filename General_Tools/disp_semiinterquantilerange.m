% disp_mean_std(data)
% 03-24-11 Stephen Foldes
%
% displays the mean and standard deviation of each column in 'data'
% data: (samples x features)
% will also display the overall mean+-std if more than two columns are presented
% simply saves you from typing and managing "[mean(data) std(data)]"

function disp_semiinterquantilerange(data)

for icol=1:size(data,2)
%     disp([num2str(mean(data(:,icol),1)) char(177) num2str(std(data(:,icol),[],1))])
    fprintf('%3.2f%c%3.2f \n',quantile(data(:,icol),[0.5]),char(177),diff(quantile(data(:,icol),[0.25 0.75]))/2,[],1)
end

if size(data,2)>1
    fprintf('OVERALL: %3.2f%c%3.2f \n',quantile(reshape(data,[],1),0.5),char(177),diff(quantile(reshape(data,[],1),[0.25 0.75]))/2)
end