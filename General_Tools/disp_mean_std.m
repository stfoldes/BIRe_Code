function disp_mean_std(data)
% displays the mean and standard deviation of each column in 'data'
% data: (samples x features)
% will also display the overall mean+-std if more than two columns are presented
% simply saves you from typing and managing "[mean(data) std(data)]"
%
% 03-18-11 Stephen Foldes
% UDPATES:
% 2013-08-14 Foldes: Works smarter for 1D vectors


if size(data,1) == 1
    data = data';
end

for icol=1:size(data,2)
%     disp([num2str(mean(data(:,icol),1)) char(177) num2str(std(data(:,icol),[],1))])
    fprintf('%3.2f%c%3.2f \n',nanmean(data(:,icol)),char(177),nanstd(data(:,icol),[],1))
end

if size(data,2)>1
    fprintf('OVERALL: %3.2f%c%3.2f \n',mean(reshape(data,[],1)),char(177),std(reshape(data,[],1),[],1))
end