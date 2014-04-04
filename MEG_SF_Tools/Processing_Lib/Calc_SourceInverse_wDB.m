function SourceData = Calc_SourceInverse_wDB(DB_entry,AnalysisParms)
% Uses BST to find the ImagingKernel and SmoothingKernel
% Will run a BST-pipeline if needed to: Import, Computer Sources, Project 2 MNI
% Using the DB
% BST must be pointed to the protocol that you want to use ***IMPROVE***
% AnalysisParms.event_name_rest is the event name for the inverse kernel
% CURRENTLY ALL INVERSE PARAMETERS ARE HARDCODED
%
% PROCEDURES
%   1. Find study in BST
%   2. Run Pipeline if needed
%   3. Get ImagingKernel.^2 (b/c power)
%   4. Compute SmoothingKernel
%   5. Multiple Kernels to make SmoothSourceKernel
%
% OUTPUT:
%   SourceData
%           .ImagingKernel:
%           .SmoothingKernel:
%           .SmoothSourceKernel: [nSources x nSources] This is what you want
%           .AnalysisParms:
%
% 2014-03-26 FOldes
% UPDATES:
%

% YOU MUST BE OPEN TO THE CORRECT PROTOCOL IN BST
% BST_protocol = 'SF_Takeover';


%% Get ImagingKernel and ResultsMat from BST (will run BST pipeline if needed)

sStudies = bst_get('StudyWithCondition',['Group_analysis/' AnalysisParms.event_name_rest]);

target_inverse_file = [DB_entry.subject '/MN: MEG GRAD(Constr)']; % ***HARDCODED***

if ~isempty(sStudies)
    iStudy = find(strcmp({sStudies.Result.Comment},target_inverse_file));
else % no studies made, need to get the ball rolling
    iStudy = [];
end
if isempty(iStudy)
    try
        BST_Pipeline_wDB(DB_entry, AnalysisParms);
        sStudies = bst_get('StudyWithCondition',['Group_analysis/' AnalysisParms.event_name_rest]);
        iStudy = find(strcmp({sStudies.Result.Comment},target_inverse_file));
    catch
        error(['Failure with importing and calculating inverse for ' DB_entry.entry_id])
    end
end
sStudy = sStudies.Result(iStudy);
ResultsFile =   sStudy.FileName;

ResultsMat =    in_bst_results(ResultsFile, 0, 'ImagingKernel','SurfaceFile');
SourceData.ImagingKernel = ResultsMat.ImagingKernel.^2; % squared b/c power

%% Spatial Filter
% It is still not clear if this should be done on the individual anatomy level (if so, add to Kernel?)
% fMRI does this at the group brain level.
% See my BST-forum discussion

Method = 'average';

% From process_ssmooth.m [2014-03]
% Load surface file
SurfaceMat = in_tess_bst(ResultsMat.SurfaceFile);
% Compute the smoothing operator
SourceData.SmoothingKernel = tess_smooth_sources(SurfaceMat.Vertices, SurfaceMat.Faces,SurfaceMat.VertConn, AnalysisParms.FWHM/1000, Method);
% Smooth the Imaging Kernel (apply this to the power, i.e. the raw data)
SourceData.SmoothSourceKernel = SourceData.SmoothingKernel * SourceData.ImagingKernel;

SourceData.AnalysisParms =  AnalysisParms;

% ***SHOULD SAVE MORE, LIKE THE FORWARD MODEL INFO***

end % main

%% BST Pipeline
function BST_Pipeline_wDB(DB_entry, AnalysisParms)
% Runs a pipeline that uses DB (w/ Extract functions) to compute
%   wMNE, Constained, Grad only,  0-2s after ArtifactFreeRest
% Puts Events into BST format (ALWAYS, could check one day)
% AnalysisParms. is needed
%
% 2014-03-25 Foldes
%
disp('***IMPORTING AND CALCULATING INVERSE***')

% Get basic loading info
Extract.file_type =         AnalysisParms.file_type; % What type of data
Extract.file_path =         DB_entry.file_path('local');
Extract =                   DB_entry.Prep_Extract(Extract);

% BST Pipeline
PipeInfo =  BST_Pipeline_Class;

PipeInfo.eventname =           AnalysisParms.event_name_rest;
PipeInfo.subject =             DB_entry.subject;
PipeInfo.condition =           PipeInfo.eventname;

% IMPORT
PipeInfo.FIFFile =             Extract.full_file_name; % '/home/foldes/Data/MEG/NC01/S01/nc01s01r05_tsss.fif';
PipeInfo.EventFile =           [];% Computed below   %'/home/foldes/Data/MEG/NC01/S01/events_4BSTfromMatlab_nc01s01r05.mat';
PipeInfo.epochtime =           AnalysisParms.noisecov_time; % for inverse kernel only, +time doesn't matter

% SOURCE
PipeInfo.noisecov_time =       AnalysisParms.noisecov_time;
PipeInfo.inverse_method =      AnalysisParms.inverse_method;
PipeInfo.inverse_orientation = AnalysisParms.inverse_orientation; % fixed = constrained
PipeInfo.sensortypes =         AnalysisParms.sensortypes;


% ---Save out the event file in BST format---
% Check and load for Events first
DB_entry.load_pointer('Preproc.Pointer_Events');
if ~exist('Events')
    error(['No events exist for ' DB_entry.entry_id])
end


% Need TimeS (too bad)
[~,TimeVecs.timeS,~,Extract] = Load_from_FIF(Extract,'STI');
event_timeS = TimeVecs.timeS(Events.(PipeInfo.eventname));
PipeInfo.EventFile = Export_BSTEvent_File(event_timeS,Extract.data_rate,Extract.full_file_name,'label',PipeInfo.eventname);

% ---Run Pipeline---
[PipeInfo, sFiles_4debug] = PipeInfo.Run('Import','PreSource','Source','Project2MNI');

end % BST_Pipeline_ArtifactFreeRest_wDB
