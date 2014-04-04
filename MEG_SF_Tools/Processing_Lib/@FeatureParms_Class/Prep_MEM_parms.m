function obj = Prep_MEM_parms(obj)
% Sets the MEM parameters for running mem.mex from BCI2000
%
% REQUIRED
%     %---Feature Parameters (FeatureParms.)---
%     FeatureParms = FeatureParms_Class;
%     FeatureParms.feature_method = 'MEM';
%     FeatureParms.order = 30;
%     FeatureParms.feature_resolution = 1;
%     FeatureParms.sample_rate = Extract.data_rate;
%     FeatureParms.ideal_freqs = [0:150]; % not needed here, but will be later
%     %-------------------------------
%     FeatureParms=Prep_FeatureParms(FeatureParms);
%
% OPTIONAL (hidden)
%     FeatureParms.MEM_firstBinCenter
%     FeatureParms.MEM_lastBinCenter
%     FeatureParms.MEM_NumOfEvaluation
%
%
% Overview
% http://www.bci2000.org/wiki/index.php/User_Reference:SpectralEstimator
% Parameters
% http://www.bci2000.org/wiki/index.php/User_Reference:Matlab_MEX_Files#mem
%
% model order: AR order, default = 30
% first bin center: first freq [Hz], default = 0
% last bin center: last freq [Hz], default = sampling_rate/2
% bin width: freqs per output value, no default
% evaluations per bin: within-bin resolution, default = BinWidth*2
% detrend option: (optional, 0: none, 1: mean, 2: linear; defaults to none)
% sampling frequency: no default
%
% To Use:
% parms = [model order, first bin center, last bin center, bin width, evaluations per bin, detrend option, sampling frequency];
%
% [spectrum, frequencies] = mem(signal, parms);
% with <signal> and <spectrum> having dimensions values x channels, and with <parms> being a vector of parameter values:
%
% 2013-07-25 Foldes
% UPDATES
%

% ModelOrder
    % The order of the autoregressive model. Roughly, this corresponds to the maximum number of peaks in the resulting spectrum.
    if obj.order == -1
        obj.order = 30; % 2013-07-25
        warning(['@FeatureParms.order: Setting to default = ' num2str(obj.order) ]);
    end
    
% BinWidth
    % A single nonnegative float value representing the width of a single bin, e.g. "3Hz".
    if obj.feature_resolution == -1
        obj.feature_resolution = 1; % 2013-07-25
        warning(['@FeatureParms.feature_resolution: Setting to default = ' num2str(obj.feature_resolution) ]);
    end

% FirstBinCenter
    % A float value representing the center of the first frequency bin, e.g. "5Hz".
    if obj.MEM_firstBinCenter == -1
        obj.MEM_firstBinCenter = 0; % 2013-07-25
    end

% LastBinCenter (this doesn't seem to matter at all - Foldes 2013-07-26)
    % A float value representing the center of the last frequency bin.
    if obj.MEM_lastBinCenter == -1
        obj.MEM_lastBinCenter = min(150,obj.sample_rate/2); % Hard code max to 150 if not defined. (2013-07-25 Foldes, changed from 200Hz)
    end

% EvaluationsPerBin
    % A single nonnegative integer value representing the number of uniformly spaced evaluation points that enter into a single bin's value.
    if obj.MEM_NumOfEvaluation == -1
        obj.MEM_NumOfEvaluation = round(obj.feature_resolution*2); % 2013-07-25
    end

% Detrend option (optional, 0: none, 1: mean, 2: linear; defaults to none),
    obj.MEM_Trend = 0; % don't remove the mean.

%% Make Paramter List
% 
% % parms = [model order, first bin center, last bin center, bin width, evaluations per bin, detrend option, sampling frequency];
% MEM_parms = [FeatureParms.order, FeatureParms.MEM_firstBinCenter, FeatureParms.MEM_lastBinCenter, FeatureParms.feature_resolution, FeatureParms.MEM_NumOfEvaluation, FeatureParms.MEM_Trend, FeatureParms.sample_rate];
% 
% max_num_bins = round((FeatureParms.MEM_lastBinCenter-FeatureParms.MEM_firstBinCenter)/FeatureParms.feature_resolution); % helps to initilize sizes






