% function raw2dicom(dir_in, dir_out, name_flags)
% renames raw MRI files based on ProtocolName in header field to dicom.  For MRRC data only
%
%     dir_in  = directory where raw directories are located
%     dir_out = directory where you would like
%     name_flags = cell array of dicom fields to put in the output file
%                   names.  Default =  {'SeriesNumber','InstanceNumber'}
%                   Skips fields not present in the dicom name.
%
%  ORIGINAL: schlab_dicom_rename_updated
%  Written By: T Verstynen, 10/2010 (timothyv [at] pitt [dot] edu)
%  UPDATES
% 2012-06 B Harchick
% 2012-07 Foldes: Updated function name
% 2013-02-10 Foldes: Turned off the verbose display

function raw2dicom(dir_in, dir_out, name_flags)

if nargin < 3
    name_flags = {'SeriesNumber','InstanceNumber'};
end;

if (nargin < 1) || isempty(dir_in)
    dir_in = uigetdir(pwd,'PLEASE SELECT INPUT DIRECTORY...');
end

% Added these lines, updated directory
if (nargin < 2) || isempty(dir_out)
    dir_out = uigetdir(dir_in,'PLEASE SELECT OUTPUT DIRECTORY...');
end

% Removed this section
% if nargin<2 | isempty(dir_out)
%     dir_out = uigetdir(pwd,'PLEASE SELECT OUTPUT DIRECTORY...');
% end

if ~exist(dir_out);
    mkdir(dir_out);
end;

scan_info = dir(dir_in);


prefix_list = {};
scan_names  = {};

% FIND SCAN/PROTOCOL NAMES

for a=1:length(scan_info)
    if scan_info(a).isdir && (~strcmpi(scan_info(a).name,'.') && ~strcmpi(scan_info(a).name,'..')) %&& ~isnan(str2double(scan_info(a).name))
        
        data_dir   = fullfile(dir_in,scan_info(a).name);
        file_names = dir(fullfile(data_dir,'MR.*'));
        
        if ~isempty(file_names);
            info = dicominfo(fullfile(data_dir,file_names(1).name));
            
            %  Error using ==> or   Inputs must have the same size.
            % %         if strfind(info.SeriesDescription,'/') | strfind(info.SeriesDescription,'/') | strfind(info.SeriesDescription,' ')
            %         if strfind(info.SeriesDescription,'/') | strfind(info.SeriesDescription,'\') | strfind(info.SeriesDescription,' ')
            %             info.SeriesDescription(strfind(info.SeriesDescription,'/'))='-';
            %             info.SeriesDescription(strfind(info.SeriesDescription,'\'))='-';
            %             info.SeriesDescription(strfind(info.SeriesDescription,' '))='-';
            %         end;
            
            if strfind(info.SeriesDescription,'/')
                info.SeriesDescription(strfind(info.SeriesDescription,'/'))='-';
            end;
            
            if strfind(info.SeriesDescription,'\')
                info.SeriesDescription(strfind(info.SeriesDescription,'\'))='-';
            end;
            
            if strfind(info.SeriesDescription,' ')
                info.SeriesDescription(strfind(info.SeriesDescription,' '))='-';
            end;
            
            data_out_dir = fullfile(dir_out,sprintf('%s_%dx%d.%d',...
                deblank(info.SeriesDescription), info.Width, info.Height, ...
                info.SeriesNumber));
            
            if ~exist(data_out_dir);
                mkdir(data_out_dir);
            end;
            
            fprintf(sprintf('Processing Scan %s\n',data_dir));
            
            for f = 1:length(file_names);
                info = dicominfo(fullfile(data_dir,file_names(f).name));
                outname = 'DCM';
                
                % Filter out flags not in the dicom header (usually the
                % Acquisition Number is not present in the structurals);
                dicom_fields = name_flags(isfield(info, name_flags));
                
                for n = 1:length(dicom_fields);
                    flag = eval(sprintf('info.%s',dicom_fields{n}));
                    
                    if isnumeric(flag);
                        outname = sprintf('%s-%.4i',outname,flag);
                    else
                        outname = sprintf('%s-%s',outname,flag);
                    end;
                end;
                outname = sprintf('%s.dcm',outname);
                
                % fprintf(sprintf('Renaming %s\n',outname)); % 2013-02-10 Foldes
                copyfile(fullfile(data_dir,file_names(f).name),...
                    fullfile(data_out_dir,outname));
            end
        end

    end
end