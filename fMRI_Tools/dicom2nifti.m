% function dicom2nifti(file_format,dir_in,dir_out,varargin)
% converts siemens mosaic files into nifti or analyze format
%
% renames files based on ProtocolName in header field
%

%
%     format  = file type of output:
%       'analyze' - 3-D analyze
%       '3dnii'   - 3-D nifti files
%       '4dnii'   - 4-D nifti files (default)
%     dir_in  = directory where raw directories are located
%     dir_out = directory where you would like
%
%     YOU WILL BE PROMPTED IF VALUES NOT ENTERED
%
%     Based on 'spm_dicom_convert.m'
%
%     Arguments for spm_dicom_convert:
%
%       opts     = conversion options
%          'all'        - all DICOM files (default)
%          'mosaic'     - the mosaic images
%          'standard'   - standard DICOM files
%          'raw'        - convert raw FIDs (not implemented)
%          'spect'      - SIEMENS Spectroscopy DICOMs (position only)
%                         This will write out a mask image volume with 1's
%                         set at the position of spectroscopy voxel(s).
%       root_dir = output directory structure
%          'flat'       - SPM5 standard, do not produce file tree
%                         With all other options, files will be sorted into
%                         directories according to their sequence/protocol names
%          'date_time'  - Place files under ./<StudyDate-StudyTime>
%          'patid'      - Place files under ./<PatID>
%          'patid_date' - Place files under ./<PatID-StudyDate>
%          'patname'    - Place files under ./<PatName>
%       format   = output format
%          'img'        - Two file (hdr+img) NIfTI format (default)
%          'nii'        - Single file NIfTI format
%
% DO NOT MANUALLY RENAME DICOMS FROM SCANNER! SCRIPT WILL TAKE CARE OF IT.
%
% MUST HAVE SPM5 INSTALLED!!!
%
% modified 18 july 2007
%
% version 13
%
% @(#)spm_DICOM.m	1.1 John Ashburner 02/08/12
% Modified              Tim Verstynen 07/05/31
%                       Zack Chadick 18 july 2007 (gazzaley lab)
%                       Tim Verstynen 10/03/8 (to work for MRRC data)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% UPDATES:
% 2012-07-16 MR/SF: auto renaming function, works with WIN64, renamed from "schlab_dicom_convert.m"
% 2012-11-17 Foldes: removed option to rename

function dicom2nifti(file_format,dir_in,dir_out,varargin)

%% EDIT THESE VARIABLES

opts            = 'all';   % see above
root_dir        = 'flat';  % see above

dir_number_flag = 0;       % set to 1 if you want to number EPI scans sequentially

%% GET DIRECTORY INFORMATION / SET DEFAULTS

current_dir = pwd;
start_path_in = 'C:\Data\subjects\';
start_path_out = 'C:\Data\subjects\';

if nargin<1
    file_format = '4dnii';
end

switch file_format
    case 'analyze'
        format = 'img';
    case '4dnii'
        format = 'nii';
    case '3dnii'
        format = 'nii';
    otherwise
        error('INVALID FILE FORMAT!!!\n');
end

if nargin<2 || isempty(dir_in)
    dir_in = uigetdir(start_path_in,'PLEASE SELECT PARENT DATA DIRECTORY...');
end

if ~dir_in
    error('You need to select and input directory, punk!')
end

if nargin<3 || isempty(dir_out)
    dir_out = uigetdir(start_path_out,'PLEASE SELECT OUTPUT DIRECTORY...');
end

if ~dir_out
    dir_out = fullfile(dir_in,'converted_dicoms');
end

scan_info = dir(dir_in);

if ~exist(dir_out,'dir')
    mkdir(dir_out);
end

prefix_list = {};
scan_names  = {};

%% FIND SCAN/PROTOCOL NAMES

for a=1:length(scan_info)
    if scan_info(a).isdir && (~strcmpi(scan_info(a).name,'.') && ~strcmpi(scan_info(a).name,'..')) 
        
        data_dir   = fullfile(dir_in,scan_info(a).name);
        file_names = dir(fullfile(data_dir,'*'));
                
        if length(file_names) < 3
            P = spm_select('list',data_dir,'.*');
            info = spm_dicom_headers(P);
        else
            info = spm_dicom_headers(fullfile(data_dir,file_names(3).name));
        end;

        % make sure not to overwrite any already written files

        if strmatch(info{1}.SeriesDescription(end),'_','exact')
            proto = info{1}.SeriesDescription(1:end-1);
        else
            proto = info{1}.SeriesDescription;
        end


        if ~isempty(strmatch(proto,prefix_list,'exact'))
            protocol = sprintf('%s_%02d',proto,length(strmatch(proto,prefix_list,'exact')));
        else
            protocol = proto;
        end
        
        % Protocol information in the header file will be used for file
        % names, so any directory characters need to be replaced
        replMask = ismember(protocol,'/') | ismember(protocol,'\');
        protocol(replMask) = '_';
        
        prefix_list = cat(2,prefix_list,proto);
        scan_names  = cat(1,scan_names,{scan_info(a).name,protocol});

    end
end

%% SORT SCAN NAMES BY SCAN NUMBER

for a=1:size(scan_names,1)
    scan_names(a,3) = {sprintf('%03d',str2double(scan_names(a,1)))};
end

scan_names = sortrows(scan_names,3);

%% ALLOW USER TO ALTER NAMING CONVENTION

name_flag = 0;
new_names = {};

for v = 1:2:length(varargin);
    eval(sprintf('%s = varargin{%d};',varargin{v},v+1));
end;

if name_flag && ~isempty(new_names);
    if length(new_names) ~= length(scan_names(:,3));
        name_flag = 0;
    else
        for s = 1:length(new_names);
            scan_names{s,3} = new_names{s};
        end;
        
        for a=1:size(scan_names,1)
          match_flag(a) = length(find(strcmp(scan_names(:,3),scan_names(a,3))))-1;
          if isempty(strfind('arws',scan_names{a,3}(1)))
%          if isempty(strmatch(scan_names{a,3}(1),'a')) && isempty(strmatch(scan_names{a,3}(1),'r')) && ~isempty(strmatch(scan_names{a,3}(1),'w')) && ~isempty(strmatch(scan_names{a,3}(1),'s'))
            letter_flag(a) = 0;
          else
             letter_flag(a) = 1;
          end
          if isempty(find(isspace(scan_names{a,3})))
            space_flag(a) = 0;
          else
            space_flag(a) = 1;
          end
        end

      if ~isempty(find(match_flag))
        h = warndlg('TWO OR MORE SCANS HAVE THE SAME NAME!!!','SCAN NAME ERROR');
        uiwait(h); name_flag = 0;
      elseif ~isempty(find(letter_flag))
        h = warndlg({'SCAN NAME CANNOT START WITH';'LETTERS ''a'',''r'',''s'',or ''w''!!!'},'SCAN NAME ERROR');
        uiwait(h);name_flag = 0;
      elseif ~isempty(find(space_flag))
        h = warndlg({'SCAN NAME CANNOT CONTAIN SPACES!!!'},'SCAN NAME ERROR');
        uiwait(h);name_flag = 0;
      end;
    end;
end;
    

while ~name_flag
    for a=1:size(scan_names,1)
        if ~isempty(strfind(lower(scan_names{a,2}),'mpragefind(letter_flag~=1)'))
            prompt(a) = {sprintf('SCAN DIRECTORY %5s - PROTOCOL NAME: %s (MUST HAVE ''mprage'' IN NAME!!!)',scan_names{a,1},scan_names{a,2})};
        else
            prompt(a) = {sprintf('SCAN DIRECTORY %5s - PROTOCOL NAME: %s',scan_names{a,1},scan_names{a,2})};
        end
    end

    % ADDED 2012-07-15 MR/SF
    clear scan_names_clean
    for ifile = 1:length(scan_names(:,2))
        clear space_idx current_scan_name_str
        current_scan_name_str = cell2mat(scan_names(ifile,2));
        space_idx = find(current_scan_name_str==' ');
        current_scan_name_str(space_idx)='_'; % overwriting string name
        if current_scan_name_str(end)=='_'
            current_scan_name_str(end)=[];
        end
        scan_names_clean{ifile} = ['epi_' current_scan_name_str];
    end

    scan_names(:,3) = scan_names_clean; % UPDATED 2012-11-17 Foldes - removed option to rename


    % check to see if name is already used or starts with a 'bad' letter ('a' 'r' 's' or 'w') or contains spaces

    for a=1:size(scan_names,1)
        match_flag(a) = length(find(strcmp(scan_names(:,3),scan_names(a,3))));
        if ~isempty(strmatch(scan_names{a,3}(1),'a')) || ~isempty(strmatch(scan_names{a,3}(1),'r')) || ~isempty(strmatch(scan_names{a,3}(1),'w')) || ~isempty(strmatch(scan_names{a,3}(1),'s'))
            letter_flag(a) = 0;
        else
            letter_flag(a) = 1;
        end
        if ~isempty(find(isspace(scan_names{a,3})))
            space_flag(a) = 0;
        else
            space_flag(a) = 1;
        end
    end

    if ~isempty(find(match_flag~=1))
        h = warndlg('TWO OR MORE SCANS HAVE THE SAME NAME!!!','SCAN NAME ERROR');
        uiwait(h);
    elseif ~isempty(find(letter_flag~=1))
        h = warndlg({'SCAN NAME CANNOT START WITH';'LETTERS ''a'',''r'',''s'',or ''w''!!!'},'SCAN NAME ERROR');
        uiwait(h);
    elseif ~isempty(find(space_flag~=1))
        h = warndlg({'SCAN NAME CANNOT CONTAIN SPACES!!!'},'SCAN NAME ERROR');
        uiwait(h);
    else
        name_flag = 1;
    end
end

%% RENUMBER SCANS (if dir_number_flag set to 1)

if dir_number_flag
    for a=1:length(scan_names)
        scan_names(a,4) = {num2str(a)};
    end
end

%% PROCESS FILES
start_dir = pwd;

for a=1:size(scan_names,1)

    if ~isempty(scan_names{a,3})
        protocol = scan_names{a,3};
    else
        protocol = scan_names{a,2};
    end

    if dir_number_flag
        export_dir  = fullfile(dir_out,sprintf('%03d_%s',str2double(scan_names{a,4}),protocol));
    else
        export_dir  = fullfile(dir_out,sprintf('%s',protocol));
    end

    data_dir    = fullfile(dir_in,scan_names{a,1});
    file_names  = dir(fullfile(data_dir,'*.dcm'));
    
    dashes = strfind(file_names(1).name,'-');
    if isempty(dashes)
        prefix      = length(file_names(1).name(1:end-5));
    else    
        prefix = dashes(end);
    end;
    
    fprintf('PROCESSING %s...\n',protocol)

    if ~exist(export_dir,'dir')
        mkdir(export_dir);
    end

    header_info = spm_dicom_headers(fullfile(data_dir,file_names(1).name));
    header_info = header_info{1,1};

    header_info.PatientsName = ''; % anonomize data

    save(fullfile(export_dir,'header_info.mat'),'header_info');

    file_list = {};

    % copy temp files to working directory

    fprintf('...copying working files...\n')

    for b=1:length(file_names)
        file_num = str2double(file_names(b).name(prefix+1:end-4));
        copyfile(fullfile(data_dir,file_names(b).name),fullfile(export_dir,sprintf('%s_%03d.DCM',protocol,file_num)));
        file_list{b} = fullfile(export_dir,sprintf('%s_%03d.DCM',protocol,file_num));
    end

    %eval(sprintf('cd %s;',export_dir));
    cd(export_dir);
    
    files = strvcat(file_list);

    % convert dicoms to analyzer/nifti

    fprintf('...reading header information...\n')
    hdr = spm_dicom_headers(files);
    fprintf('...converting files...\n')
    %spm_dicom_convert(hdr,opts,root_dir,format);
    spm_dicom_convert_schlab(hdr,opts,root_dir,format);
    
    clear hdr;

    % rename files based on protocol

    fprintf('...renaming files...\n')
    if strmatch('img',format,'exact')
        hdr_files = dir(fullfile(export_dir,'*.hdr'));
        img_files = dir(fullfile(export_dir,'*.img'));
        for b=1:length(hdr_files)
            if length(hdr_files)>1
                movefile(fullfile(export_dir,hdr_files(b).name),fullfile(export_dir,sprintf('%s_%04d.hdr',protocol,b)));
                movefile(fullfile(export_dir,img_files(b).name),fullfile(export_dir,sprintf('%s_%04d.img',protocol,b)));
            else
                movefile(fullfile(export_dir,hdr_files(b).name),fullfile(export_dir,sprintf('%s.hdr',protocol)));
                movefile(fullfile(export_dir,img_files(b).name),fullfile(export_dir,sprintf('%s.img',protocol)));
            end
        end
    else
        nii_files = dir(fullfile(export_dir,'*.nii'));
        for b=1:length(nii_files)
            if length(nii_files)>1
                movefile(fullfile(export_dir,nii_files(b).name),fullfile(export_dir,sprintf('%s_%04d.nii',protocol,b)));
            else
                movefile(fullfile(export_dir,nii_files(b).name),fullfile(export_dir,sprintf('%s.nii',protocol)));
            end
        end
    end

    % convert 3d nifti to 4d nifti
    % remove temp files

    cd(start_dir);
    fprintf('...deleting temporary files...\n')
    delete(fullfile(export_dir,'*.DCM'));
    
    if ~isempty(strmatch('4dnii',file_format,'exact'))
        nii_in = dir(fullfile(export_dir,'*.nii'));
        if length(nii_in)>1
            fprintf('...compressing 3-D NIFTI files into 4-D NIFTI file...\n')
            nii_file = {};
            nii_out  = fullfile(export_dir,sprintf('%s.nii',protocol));

            for b=1:length(nii_in)
                nii_file{b} = fullfile(export_dir,nii_in(b).name);
            end

            nii_3Dto4D(nii_file,nii_out);

            for b=1:length(nii_file)
                delete(nii_file{b});
            end
        end
    end



end

%eval(sprintf('cd %s;',current_dir));
cd(current_dir);
fprintf('\nDONE!!!\n\n')

end

%% FUNCTION FOR CREATING 4-D NIFTI FILES

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% MODIFIED FROM spm_config_3Dto4D.m (20 june 2007)
%
% Copyright (C) 2005 Wellcome Department of Imaging Neuroscience
%
% John Ashburner
% $Id: spm_config_3Dto4D.m 245 2005-09-27 14:16:41Z guillaume $
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function nii_3Dto4D(files,save_name)

V    = spm_vol(strvcat(files{:}));
ind  = cat(1,V.n);
N    = cat(1,V.private);

mx   = -Inf;
mn   = Inf;
for i=1:numel(V),
    dat      = V(i).private.dat(:,:,:,ind(i,1),ind(i,2));
    dat      = dat(isfinite(dat));
    mx       = max(mx,max(dat(:)));
    mn       = min(mn,min(dat(:)));
end

sf         = max(mx,-mn)/32767;
ni         = nifti;
ni.dat     = file_array(sprintf('%s',save_name),[V(1).dim numel(V)],'INT16-BE',0,sf,0);
ni.mat     = N(1).mat;
ni.mat0    = N(1).mat;
ni.descrip = '4D image';
create(ni);
for i=1:size(ni.dat,4),
    ni.dat(:,:,:,i) = N(i).dat(:,:,:,ind(i,1),ind(i,2));
    spm_get_space([ni.dat.fname ',' num2str(i)], V(i).mat);
end

end