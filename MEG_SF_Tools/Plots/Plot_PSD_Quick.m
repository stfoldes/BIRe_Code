% fig = Plot_PSD_Quick(power_data,feature_time_vec[OPTIONAL],FeatureParms,chan_nums)
%
% Really quickly show a Power Spectral Density plot from power_data in the standard format
% Assume plotting in pseudo-real-time (i.e. first point in 1 window ahead)
% Do any baselining before hand
%
% ---INPUTS---
% power_data [samples x channels x frequencies]
% feature_time_vec = x-axis (time), will auto generate
% FeatureParms = Stephen's standard (see documention or GetPowerOffline*.m)
% chan_nums = vector of channels to plot (if empty or missing varible, will plot all channels)
% 
% Stephen Foldes (2012-26-01)
% UPDATES:
% 2012-02-15 SF: changed function name, cleaned up a little.
% 2012-02-20 SF: can now add to figure
% 2013-07-05 Foldes: added feature_time_vec as possible option

function [figs,feature_time_vec] = Plot_PSD_Quick(power_data,feature_time_vec,FeatureParms,chan_nums,figs)

FeatureParms=Prep_FeatureParms(FeatureParms);

% Time for power vector
if isempty(feature_time_vec)
    feature_time_vec = ([0:size(power_data,1)-1]*(FeatureParms.feature_update_rate/FeatureParms.sample_rate))+(FeatureParms.window_length/FeatureParms.sample_rate);
end

if ~exist('chan_nums') || isempty(chan_nums)
    chan_nums = 1:size(power_data,2);
end

if length(chan_nums) > 20
    h=warndlg(['Creating ' num2str(length(chan_nums)) ' plots: @' mfilename],'ATTENTION')  ;
    uiwait(h)
end

for ichan = 1:length(chan_nums)
    
    if ~exist('figs') || isempty(figs) || length(figs)<ichan
        figs(ichan) = figure;
    else
        figure(figs(ichan));
    end
    hold all
    pcolor(feature_time_vec,FeatureParms.actual_freqs,squeeze(power_data(:,chan_nums(ichan),:))')
    shading interp
    colorbar 
    caxis_center
    set(gca,'FontSize',12);
    ylabel('Freq [Hz]');xlabel('Time [S]')
    title(['Channel # ' num2str(chan_nums(ichan))])
    
    xlim([min(feature_time_vec) max(feature_time_vec)])
    ylim([min(FeatureParms.actual_freqs) max(FeatureParms.actual_freqs)])
    

end






