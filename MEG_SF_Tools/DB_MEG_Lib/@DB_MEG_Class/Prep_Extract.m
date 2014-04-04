function Extract=Prep_Extract(obj,Extract)
% Used to automatically populate the "Extract" structure for loading data.
% Mostly this sets a lot of path and file names and sampling things
%
% Pre-load Extract with parameters
% REQUIRES Extract.file_type
% 
% Creates:
%     .file_name
%     .file_path
%     .decimation_factor
%     .channel_list
%     .base_sample_rate
%     .data_rate
%     .file_suffix
%     .file_extension
%	  .file_name_ending
%     .full_file_name
%
% YOU REALLY ONLY NEED THE FOLLOWING FOR Load_from_FIF.m
%     Extract.file_name =obj.entry_id;
%     Extract.file_path = obj.file_path('local');
%     Extract.base_sample_rate=1000;
%
% Stephen Foldes [2012-09-05 (based off of Prep_Extract_w_basic_info c.2012-01-31]
% UPDATES
% 2012-09-06 Foldes: Made simplier by having more inputs
% 2012-09-25 Foldes: Improved path-checking to include additional upper/lower case attempts
% 2012-11-12 Foldes: Added 'filesep' for better transitions between windows and linux. Added sss option
% 2013-02-06 Foldes: No longer needs data base, just input the entry.
% 2013-02-09 Foldes: Channel list default now all 306 sensors.
% 2013-05-20 Foldes: Broke file-type lookup table out as function
% 2013-10-07 Foldes: Metadata-->DB, removed Extract.data_path_default
% 2013-10-08 Foldes: Trimmed this down severely
% 2013-11-21 Foldes: data rate now from file, not here
% 2013-12-06 Foldes: No longer need 

global MY_PATHS


%% Get DB-base information and fit criteria

if length(obj)>1
    warning('@Prep_Extract_w_DB: Too many entries; (you know, you could fix this to make it work)')
    return
end

%% Put DB properties into Extract
% DB_fields = fields(obj);
% 
% for ifield = 1:size(DB_fields,1)
%     Extract.(char(cell2mat(DB_fields(ifield)))) = obj.(char(cell2mat(DB_fields(ifield))));
% end

%% Populate fields

if ~isfield(Extract,'file_path') || isempty(Extract.file_path)
    Extract.file_path=obj.file_path;
end
if ~isdir(Extract.file_path)
    error('NO FILE PATH FOUND @Prep_Extract_w_DB')
end


Extract = populate_field_with_default(Extract,'decimation_factor',1);%for 1000Hz, a decimation_factor of 4 should give you a 250Hz sampling freq
Extract = populate_field_with_default(Extract,'channel_list',[1:306]);%channels to extract
% Extract.base_sample_rate=1000;
% Extract.data_rate = Extract.base_sample_rate/Extract.decimation_factor;
if strcmp(Extract.file_type,'CRX') || strcmp(Extract.file_type,'crx')
    Extract.file_path=[Extract.file_path 'CRX_data' filesep];
end



%% Set file names

% Define file extension and any suffixes that are needed
[Extract.file_suffix,Extract.file_extension]=MEG_file_type2file_extension(Extract.file_type); % 2013-05-20 Foldes: broke out as function
Extract.file_name_ending = [Extract.file_suffix Extract.file_extension];

% NO ERROR CHECKING and no multifiles FOR NOW (assumes DB is correct)
Extract.file_name = [obj.entry_id Extract.file_suffix];

Extract.full_file_name = [Extract.file_path filesep Extract.file_name Extract.file_extension];

% if isa(Extract.runs,'cell')
%     for irun = 1:size(Extract.runs,2) % 2012-03-02 SF: Works for Cells
%         Extract.file_name{irun}=[Extract.subject 's' Extract.session 'r' Extract.runs{irun} file_suffix];
%
%         % test out file path and try upper and lower case just incase;)
%         if ~exist([Extract.file_path Extract.file_name{irun} file_suffix])
%             Extract.file_name{irun}=[lower(Extract.subject) 's' Extract.session 'r' Extract.runs{irun} file_suffix];
%         end
%         if ~exist([Extract.file_path Extract.file_name{irun} file_suffix])
%             Extract.file_name{irun}=[upper(Extract.subject) 's' Extract.session 'r' Extract.runs{irun} file_suffix];
%         end
%
%     end
% else
%     for irun = 1:size(Extract.runs,1) % 2012-01-31 SF: now 1st dimension, used to be second
%         Extract.file_name{irun}=[Extract.subject 's' Extract.session 'r' Extract.runs(irun,:) file_suffix];
%     end
%
%     % test out file path and try upper and lower case just incase;)
%     if ~exist([Extract.file_path Extract.file_name{irun} file_suffix])
%         Extract.file_name{irun}=[lower(Extract.subject) 's' Extract.session 'r' Extract.runs(irun,:) file_suffix];
%     end
%     if ~exist([Extract.file_path Extract.file_name{irun} file_suffix])
%         Extract.file_name{irun}=[lower(Extract.subject) 's' Extract.session 'r' Extract.runs(irun,:) file_suffix];
%     end
%
% end

%% Check that the files exist (Foldes 2012-08-30)

if exist(Extract.full_file_name)==0
    errordlg(['CAN NOT FIND FILE: ' Extract.full_file_name ' MUST CHECK PATHS'],'Data File Not Found @Prep_Extract.m')
end




