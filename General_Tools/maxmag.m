function [max_mag, idx] = maxmag(data,dim,signed_flag)
% Returns the values in data that have the maximum magnitude in the given dimension (and the index)
% dim varible is optional and will do biggest dimension by default
%
% signed_flag = 1 ==> returned a signed value
%
% Stephen Foldes (2012-02-24)
% UPDATES:
% 2013-01-24 Foldes: Now does default of biggest dimension, returns absolute value
% 2013-07-17 Foldes: Added signed option, tried to make more than 2D, too hard!! TRUST ME


if ~exist('dim') || isempty(dim)
    [~,dim] = max(size(data)); % default is looking at the biggest dimension
end

if dim == 1
    for icol = 1:size(data,2)
        [value(icol),idx(icol)]=max(abs(data(:,icol)));
        max_mag(icol) = data(idx(icol),icol);
    end
    
elseif dim == 2
    for irow = 1:size(data,1)
        [value(irow),idx(irow)]=max(abs(data(irow,:)));
        max_mag(irow) = data(irow,idx(irow));
    end
end

if ~exist('signed_flag') || isempty(signed_flag) || signed_flag~=1
    max_mag=abs(max_mag);
end


%% TRYING TO DO MORE THAN 2D
% max_mag=data(max_idx(abs_data(:),[],dim)); % 2013-07-17 THIS MIGHT NOT WORK
% 
% THIS WORKS BUT TAKES 60s
% tic
% x=zeros(size(abs_data,1),length(sensor_group_list),size(abs_data,3));
% for igroup = 1:length(sensor_group_list)
%     data = sensor_data(:,(sensor_idx2group==sensor_group_list(igroup)),:);
%     
%     abs_data = abs(data);
%     sign_data = sign(data);
%     for itrial = 1:size(abs_data,1)
%         for ifreq = 1:size(abs_data,3)
%             [x(itrial,igroup,ifreq)]=data(itrial,max_idx(abs_data(itrial,:,ifreq),[],2),ifreq);
%         end
%     end
%     
% end
% toc
