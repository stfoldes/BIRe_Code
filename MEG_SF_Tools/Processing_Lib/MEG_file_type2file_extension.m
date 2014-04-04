% General lookup table for relating file type to file name information
% e.g. 'sss' -> '_sss' '.fif'
% 
% 'fif','crx','sss','sss_trans',tsss','tsss_trans'
% 2013-05-20 Foldes
% UPDATES:
% 2013-08-15 Foldes: Clean

function [file_suffix,file_extension]=MEG_file_type2file_extension(file_type)

% Define file extension and any suffixes that are needed
switch lower(file_type)
    case {'fif'}
        file_suffix = '';
        file_extension='.fif';
    case {'crx'}
        file_suffix = '';
        file_extension='.mat';
    case {'sss'}
        file_suffix = '_sss';
        file_extension='.fif';
    case {'sss_trans'}
        file_suffix = '_sss_trans';
        file_extension='.fif';
    case {'tsss'}
        file_suffix = '_tsss';
        file_extension='.fif';        
    case {'tsss_trans'}
        file_suffix = '_tsss_trans';
        file_extension='.fif';
end