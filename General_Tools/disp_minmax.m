% disp_minmax(data)
% Stephen Foldes (2012-03-28)
%
% displays the min and max of each column in 'data'
% data: (samples x features)
% will also display the overall min and max if more than two columns are presented
% simply saves you from typing and managing "[min(data) max(data)]"

function disp_minmax(data)

for icol=1:size(data,2)
    fprintf('%3.2f - %3.2f \n',min(data(:,icol)),max(data(:,icol),[],1))
end

if size(data,2)>1
    fprintf('OVERALL: %3.2f - %3.2f \n',min(reshape(data,[],1)),max(reshape(data,[],1),[],1))
end