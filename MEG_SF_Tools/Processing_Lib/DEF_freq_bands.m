% DEF_freq_bands(band_name);
%
% Define the list of my standard frequency bands
%
% 2012-06-27 Foldes
% UPDATES:
% 2013-07-15 Foldes: gamma 60-80 ==> 65-85
% 2013-07-16 Foldes: Added SMR
% 2013-07-26 Foldes: gamma 65-85 --> 70-90
% 2013-10-23 Foldes: beta 20-30 --> 15-30; gamma 70-90 --> 60-80

function freq_band = DEF_freq_bands(band_name)
switch(band_name)
    case 'mu'
        freq_band = [8 13];
    case 'beta'
        freq_band = [15 30];
    case 'SMR'
        freq_band = [8 30];
    case 'gamma'
        freq_band = [60 80];
    case 'gamma_high'
        freq_band = [120 150];
    case 'gamma_low'
        freq_band = [35 55];
        
end