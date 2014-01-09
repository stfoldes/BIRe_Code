function OutputFile = out_results_volume(ResultsFile, OutputFile, VolDownsample, ExtractTimeS, TimeDownsample, DataThresh)
% OUT_RESULTS_VOLUME: Export a sources file as a 4D matrix (volume/time).
% 
% USAGE:  OutputFile = out_results_volume(ResultsFile, OutputFile, VolDownsample, TimeDownsample, DataThresh)
%         OutputFile = out_results_volume(ResultsFile, OutputFile)

% INPUT:
%     - ResultsFile    : Brainstorm source file to convert to a 4D matrix
%     - OutputFile     : Output filename (if not specified, asked to the user)
%     - VolDownsample  : Integer, volume reduction factor (exports one voxel every ~ in each dimension)
%     - TimeDownsample : Integer, time reduction factor (exports one time point every ~)
%     - DataThresh     : [0,1], Set to zero all the values < DataThresh*100*Max

% @=============================================================================
% This software is part of the Brainstorm software:
% http://neuroimage.usc.edu/brainstorm
% 
% Copyright (c)2000-2012 Brainstorm by the University of Southern California
% This software is distributed under the terms of the GNU General Public License
% as published by the Free Software Foundation. Further details on the GPL
% license can be found at http://www.gnu.org/copyleft/gpl.html.
% 
% FOR RESEARCH PURPOSES ONLY. THE SOFTWARE IS PROVIDED "AS IS," AND THE
% UNIVERSITY OF SOUTHERN CALIFORNIA AND ITS COLLABORATORS DO NOT MAKE ANY
% WARRANTY, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO WARRANTIES OF
% MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE, NOR DO THEY ASSUME ANY
% LIABILITY OR RESPONSIBILITY FOR THE USE OF THIS SOFTWARE.
%
% For more information type "brainstorm license" at command prompt.
% =============================================================================@
%
% Authors: Francois Tadel, 2010-2012

%% ===== PARSE INPUTS =====
% Options
if (nargin < 4) || isempty(DataThresh) || isempty(ExtractTimeS) || isempty(TimeDownsample) || isempty(VolDownsample)
    res = java_dialog('input', ...
        {'Volume downsample factor (integer):', ...
        'Time point to extract (seconds) [enter "none" will use downsample factor]:', ...
        'Time downsample factor (integer):', ...
        'Data threshold (percent):'}, ...
        'Export to 4D matrix', [], {'3', '0', '1', '0'});
    if isempty(res) || isempty(str2num(res{1})) || isempty(str2num(res{3})) || isempty(str2num(res{4}))
        return
    end
    VolDownsample  = str2num(res{1});
    if ~strcmp(res{2},'none')
        ExtractTimeS = str2num(res{2});
    end
    TimeDownsample = str2num(res{3});
    DataThresh     = str2num(res{4}) / 100;
end
% If output filename is not specified in input
if (nargin < 2) || isempty(OutputFile)   
    % Get default directories
    LastUsedDirs = bst_get('LastUsedDirs');
    % Get the default filename
    [resPath, resName, resExt] = bst_fileparts(ResultsFile);
    % Make a unique filename 
    OutputFile = fullfile(LastUsedDirs.ExportData, resName);
    OutputFile = file_unique(OutputFile);
    % Ask user confirmation and file format
    [OutputFile, FileFormat] = java_getfile('save', 'Save sources as 4D matrix', OutputFile, 'single', 'files', ...
            bst_get('FileFilters', 'source4d'), 2);
    if isempty(OutputFile)
        return;
    end
    % Save new default export path
    LastUsedDirs.ExportData = bst_fileparts(OutputFile);
    bst_set('LastUsedDirs', LastUsedDirs);
end


%% ===== LOAD ALL REQUIRED DATA =====
% Progress bar
bst_progress('start', 'Export sources', 'Loading sources...');
% Get surface for those results
ResultsMat = in_bst_results(ResultsFile, 0, 'SurfaceFile');
if isempty(ResultsMat) || ~isfield(ResultsMat, 'SurfaceFile') || isempty(ResultsMat.SurfaceFile)
    error('Could not load results file.');
end
SurfaceFile = ResultsMat.SurfaceFile;
% Get subject
[sSubject, iSubject] = bst_get('SurfaceFile', SurfaceFile);
if isempty(sSubject)
    error('Surface file is not registered in database.');
end
% Load MRI
sMri = bst_memory('LoadMri', iSubject);
if isempty(sMri)
    error('Could not load MRI file.');
end
mriSize = size(sMri.Cube);
% Load surface
[sSurf, iSurf] = bst_memory('LoadSurface', SurfaceFile);
if isempty(sSurf)
    error('Could not load surface file.');
end
% Get transformation MRI<->Surface
tess2mri_interp = bst_memory('GetTess2MriInterp', iSurf);
% Load results
[iDS, iResult] = bst_memory('LoadResultsFileFull', ResultsFile);
if isempty(iDS)
    error('Could load results file.');
end
% Get time vector
[DataTimeVectorS, iTime] = bst_memory('GetTimeVector', iDS, iResult, 'UserTimeWindow');
% If static (one or two time points): keeps only the first one
if (length(iTime) <= 2)
    iTime = iTime(1);
elseif (TimeDownsample > 1)
    iTime = iTime(1:TimeDownsample:length(iTime));
end
% Get maximum value (to normalize values)
DataMinMax = bst_memory('GetResultsMaximum', iDS, iResult);
DataMax = max(abs(DataMinMax));

%% 

if exist('ExtractTimeS')
    iTime = find(DataTimeVectorS>ExtractTimeS,1,'first');
end

Nt = length(iTime);


%% ===== OPEN OUTPUT FILE =====
switch (FileFormat)
    case {'Analyze', 'Nifti1'}
        dataType = 'int16';
        % Write file header
        fid = out_mri_nii(sMri.FileName, OutputFile, dataType, Nt, VolDownsample);
        % Factor to scale the values (convert to int16)
        fValue = 1 ./ DataMax .* 32767;
    case 'BST'
        % Initialize saved matrix
        Cube4D = zeros([mriSize, Nt], 'single');
end


%% ===== MATRIX CONSTRUCTION LOOP =====
bst_progress('start', 'Export sources', 'Saving file...', 0, Nt);
for i = 1:Nt
    % Get results values
    [SurfData, nComponents] = bst_memory('GetResultsValues', iDS, iResult, [], iTime(i));
    if isempty(SurfData)
        error('Could not load sources values.');
    end
    % Build interpolated cube
    CubeData = tess_interp_mri_data(tess2mri_interp, mriSize, SurfData);
    % Threshold
    CubeData(abs(CubeData) < DataThresh .* DataMax) = 0;
    % Append data to the current file
    switch (FileFormat)
        case {'Analyze', 'Nifti1'}
            % Downsample volume
            if (VolDownsample > 1)
                f = VolDownsample;
                sz = floor(size(CubeData) ./ f);
                downCube = zeros(sz);
                for iv = 1:f
                    downCube = downCube + CubeData(iv:f:f*sz(1), iv:f:f*sz(2), iv:f:f*sz(3)) ./ f;
                end
                CubeData = downCube;
            end
            % Apply factor
            CubeData = round(CubeData .* fValue);
            % Write current cube
            for z = 1:size(CubeData,3)
                fwrite(fid, CubeData(:,:,z), dataType);
            end
        case 'BST'
            Cube4D(:,:,:,i) = single(CubeData);
    end
    bst_progress('inc', 1);
end


%% ===== CLOSE/SAVE FILE =====
switch (FileFormat)
    case {'Analyze', 'Nifti1'}
        % Close file
        fclose(fid);
    case 'BST'
        % Save file
        save(OutputFile, 'Cube4D');
end
% Unload unused datasets
bst_memory('UnloadAll');
% Close progress bar
bst_progress('stop');


