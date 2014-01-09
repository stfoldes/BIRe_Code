function [feature_data,obj]=Calc_Features(obj,current_raw_data)
%
% Calculates Feature from a chunk of current_raw_data
% Also might update FeatureParms.actual_freqs
%
% EXAMPLE:
%   [feature_data(ievent,:,:), FeatureParms]=Calc_Features(FeatureParms,current_raw_data);
% OR
%   [feature_data(ievent,:,:), FeatureParms]=FeatureParms.Calc_Features(current_raw_data);
%
% 2013-07-25 Foldes
% UPDATES

if ( any(any(isnan(current_raw_data))) || any(any(isinf(current_raw_data))) )
    warning('Error @Calc_Features with NaN or inf')
    return
end

% Calculate Power (features x channels)
switch lower(obj.feature_method)
    case 'fft'
        fft_output=fft(current_raw_data,obj.nfft);
        feature_data=log10(fft_output(obj.freq_bins,:).*conj(fft_output(obj.freq_bins,:))/obj.window_length)';
    case 'mem'
        MEM_parms = [obj.order, obj.MEM_firstBinCenter, obj.MEM_lastBinCenter, obj.feature_resolution, obj.MEM_NumOfEvaluation, obj.MEM_Trend, obj.sample_rate];
        [mem_output f] = mem(current_raw_data, MEM_parms);
        feature_data=log10(mem_output(obj.freq_bins,:))'; % removed +1 b/c taken care of in Prep_FeatureParms 2013-07-15
        obj.actual_freqs = f(obj.freq_bins); % 2013-07-09 Foldes
    case 'welch' % 2013-10-21
        for ichan=1:size(current_raw_data,2)
            [Pxx(:,ichan),f]=periodogram(current_raw_data(:,ichan),1024,120,1028,obj.sample_rate,'onesided');
        end
        
    case {'burg','pburg'}
        burg_output = zeros(length(obj.freq_bins),size(current_raw_data,2));
        for ichan=1:size(current_raw_data,2)
            [burg_output(:,ichan),obj.actual_freqs] = pburg(current_raw_data(:,ichan),obj.order,obj.freq_bins,obj.sample_rate);
        end
        feature_data=log10(burg_output)';

        
end

if any(any(any(isinf(feature_data))))
    disp('Error @Calc_Features:  there was some 0s, and log10(0)=-inf.  Check if two of the same signals were subtracted')
end