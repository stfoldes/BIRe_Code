% Extract = Prep_Extract_w_basic_info(file_name_full_w_path,Extract[OPTIONAL])
% An easy and quick way to build a simple Extract structure manually. Will propogate additonal Extract parameters input.
% RECOMMEDED TO USE DATABASE INSTEAD
% Default will extract only gradiometers
%
% EXAMPLE:
% Extract = Prep_Extract_w_basic_info('/home/foldes/Data/MEG/NC01/S01/nc01s01r02.fif');
% 
% OR
% [file_name_full, file_path] = uigetfile('*','Select MEG file for quick check.','~/Data/');
% file_name_full_w_path=[file_path filesep file_name_full];
% Extract = Prep_Extract_w_basic_info(file_name_full_w_path);
%
% Stephen Foldes [2013-01-24]

function Extract = Prep_Extract_w_basic_info(file_name_full_w_path,Extract)

if ~exist('Extract')
   Extract = []; 
end

[file_path,file_name,file_type]=fileparts(file_name_full_w_path);

Extract.file_name =file_name;
Extract.file_path=file_path;

if ~isfield(Extract,'file_type')
    Extract.file_type=file_type(2:end);
end

if ~isfield(Extract,'channel_list')
    Extract.channel_list = [1:306]; % Channels to extract (e.g. [1:1:306], DEF_best_left_hemi_sma_MEG_sensors)
end

if ~isfield(Extract,'decimation_factor')
    Extract.decimation_factor=1; % "down sampling" if desired (else =1)
end

if ~isfield(Extract,'data_rate')
    Extract.data_rate = 1000;
end


