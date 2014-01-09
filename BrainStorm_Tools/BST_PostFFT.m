
freq_list_beta = [13 30];
freq_list_gamma = [58 62];

power_diff = squeeze(power_move.TF-power_rest.TF);

ideal_chan_num = sensors2chanidx(DSP2ChanNum(power_move.RowNames),DEF_MEG_sensors_sensorimotor_left_hemi_BEST);
ideal_chan_num = sensors2chanidx(DSP2ChanNum(power_move.RowNames),40);

figure;
subplot(1,2,1);hold all
plot(power_move.Freqs,power_diff(ideal_chan_num,:),'k')
plot([min(power_move.Freqs),max(power_move.Freqs)],[0 0],'r--')
xlim([min(freq_list_beta)-10 max(freq_list_beta)+10])
subplot(1,2,2);hold all
plot(power_move.Freqs,power_diff(ideal_chan_num,:),'k')
plot([min(power_move.Freqs),max(power_move.Freqs)],[0 0],'r--')
xlim([min(freq_list_gamma)-10 max(freq_list_gamma)+10])
StretchFigure(2)


freq_idx = find(power_move.Freqs>=min(freq_list_beta) & power_move.Freqs<=max(freq_list_beta));
power_diff_beta = squeeze(mean(power_diff(:,freq_idx),2));
Plot_MEG_head_plot(power_diff_beta,1,power_move.RowNames);

freq_idx = find(power_move.Freqs>=min(freq_list_gamma) & power_move.Freqs<=max(freq_list_gamma));
power_diff_gamma = squeeze(mean(power_diff(:,freq_idx),2));
Plot_MEG_head_plot(power_diff_gamma,1,power_move.RowNames);

%



source_diff_beta = inverse_kernel.ImagingKernel*power_diff_beta;

Beta_4BST = MNE_full;
Beta_4BST.ImageGridAmp = source_diff_beta;
Beta_4BST.Comment = ['MNE Beta (' num2str(min(freq_list_beta)) '-' num2str(max(freq_list_beta)) 'Hz) (Foldes)'];
Beta_4BST.Time = [min(Beta_4BST.Time) max(Beta_4BST.Time)];

source_diff_gamma = inverse_kernel.ImagingKernel*power_diff_gamma;

Gamma_4BST = MNE_full;
Gamma_4BST.ImageGridAmp = source_diff_gamma;
Gamma_4BST.Comment = ['MNE Gamma (' num2str(min(freq_list_gamma)) '-' num2str(max(freq_list_gamma)) 'Hz) (Foldes)'];
Gamma_4BST.Time = [min(Gamma_4BST.Time) max(Gamma_4BST.Time)];


% [hFig, iDS, iFig] = script_view_sources(Beta_4BST, 'cortex'); % Must be in database first
% Call surface viewer
% [hFig, iDS, iFig] = view_surface_data(Beta_4BST.SurfaceFile, Beta_4BST, [], 'NewFigure');
