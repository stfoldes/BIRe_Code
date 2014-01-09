function [moddepth] = Calc_ModDepth(feature_data_move,feature_data_rest,method_str)
% Relates move data to rest data using different methods (DEFAULT: t-stat)
% method_str:
%     'tstat' [DEFAULT]
%     'zstat'
%     'percent'
% feature_data_*: trial x electrode x frequency
%
% SEE: Calc_ModDepth_Combine_by_Location.m
%
% 2013-07-18 Foldes (replaced Calc_MEG_ModDepth.m)
% UPDATES:
% 2013-07-19 Foldes: added more options

% Default
if ~exist('method_str') || isempty(method_str)
    method_str = 'tstat';
end

switch lower(method_str)   
    case {'tstat','t'}
        % Calc mod measure (Tstat) 2013-07-17
        moddepth = Calc_Tstat_by_tef(feature_data_move,feature_data_rest);
        
    case {'zstat','z','zscore'}
        
        % Baseline mean and STD for Z
        ref_MEAN = squeeze(mean(feature_data_rest,1));
        ref_STD = squeeze(std(feature_data_rest,[],1)); % STD for Z, SEM for T
        
        moddepth=zeros(size(feature_data_move));
        for itrial=1:size(feature_data_move,1)
            moddepth(itrial,:,:) = (squeeze(feature_data_move(itrial,:,:))-ref_MEAN)./ref_STD;
        end
        
    case {'percent','%'}
        
        % Baseline mean
        ref_MEAN = squeeze(mean(feature_data_rest,1));
        % ref_STD = squeeze(std(feature_data_rest,[],1)); % STD for Z, SEM for T
        
        moddepth=zeros(size(feature_data_move));
        for itrial=1:size(feature_data_move,1)
            moddepth(itrial,:,:) = (squeeze(feature_data_move(itrial,:,:))-ref_MEAN)./abs(ref_MEAN);
        end
end

%     Plot_MEG_head_plot(mean(mean(moddepth(:,:,[66:86]),3),1),1,sort([1:3:306 2:3:306]));
%     caxis_center