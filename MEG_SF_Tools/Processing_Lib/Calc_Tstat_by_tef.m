function tval = Calc_Tstat_by_tef(data2score,ref_data)
% Calculates T-stat for standard trial wise data organization
%
% *_by_tef = by trial x electrode x frequency
% data2score=feature_data_move
% ref_data=feature_data_rest
% 
% MATH:
% ( X - MEAN(ref) ) / ( STD(ref)/sqrt(n) )
%
% EXAMPLE:
% mod = Calc_Tstat_by_tef(feature_data_move,feature_data_rest);
%
% SEE:
% Calc_ModDepth.m
%
% 2013-07-17 Foldes
% UPDATES:
%

% Baseline mean and SE for T
ref_MEAN = squeeze(mean(ref_data,1));
ref_SE = squeeze(std(ref_data,[],1))./sqrt(size(ref_data,1)); % SEM for T

tval=zeros(size(data2score));
for itrial=1:size(data2score,1)
    tval(itrial,:,:) = (squeeze(data2score(itrial,:,:))-ref_MEAN)./ref_SE;
end

%     Plot_MEG_head_plot(mean(mean(tval(:,:,[66:86]),3),1),1,sort([1:3:306 2:3:306]));
%     caxis_center




