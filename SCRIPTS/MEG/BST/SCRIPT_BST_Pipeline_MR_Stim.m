% Used for basic processing of StimMEG data, like MNS
%
% 2014-02-14 Foldes

PipeInfo =  BST_Pipeline_Class;
cnt =       0;

cnt = cnt + 1;
% IMPORT
PipeInfo(cnt).subject =             'MR';
PipeInfo(cnt).eventname =           1; % Always '1' for stim
PipeInfo(cnt).epochtime =           [-0.1 0.1];
% SOURCE
PipeInfo(cnt).noisecov_time =       [-0.1 0];
PipeInfo(cnt).inverse_method =      'dSPM';
PipeInfo(cnt).inverse_orientation = 'fixed';
% First File
PipeInfo(cnt).condition =           'MNS';
PipeInfo(cnt).FIFFile =             '/home/foldes/Data/MEG/Test/Stimulation/mr01_tsss.fif';
PipeInfo(cnt).EventFile =           [];

cnt = cnt + 1;
PipeInfo(cnt) = PipeInfo(1);        % Copy parameters from first entry
PipeInfo(cnt).condition =            'Index';
PipeInfo(cnt).FIFFile =             '/home/foldes/Data/MEG/Test/Stimulation/mr02_tsss.fif';
PipeInfo(cnt).EventFile =           [];

cnt = cnt + 1;
PipeInfo(cnt) = PipeInfo(1);        % Copy parameters from first entry
PipeInfo(cnt).condition =            'Thumb';
PipeInfo(cnt).FIFFile =             '/home/foldes/Data/MEG/Test/Stimulation/mr03_tsss.fif';
PipeInfo(cnt).EventFile =           [];

cnt = cnt + 1;
PipeInfo(cnt) = PipeInfo(1);        % Copy parameters from first entry
PipeInfo(cnt).condition =            'Pinky';
PipeInfo(cnt).FIFFile =             '/home/foldes/Data/MEG/Test/Stimulation/mr04_tsss.fif';
PipeInfo(cnt).EventFile =           [];

cnt = cnt + 1;
PipeInfo(cnt) = PipeInfo(1);        % Copy parameters from first entry
PipeInfo(cnt).condition =           'ForeArm';
PipeInfo(cnt).FIFFile =             '/home/foldes/Data/MEG/Test/Stimulation/mr05_tsss.fif';
PipeInfo(cnt).EventFile =           [];

cnt = cnt + 1;
PipeInfo(cnt) = PipeInfo(1);        % Copy parameters from first entry
PipeInfo(cnt).condition =            'UpperArm';
PipeInfo(cnt).FIFFile =             '/home/foldes/Data/MEG/Test/Stimulation/mr06_tsss.fif';
PipeInfo(cnt).EventFile =           [];

cnt = cnt + 1;
PipeInfo(cnt) = PipeInfo(1);        % Copy parameters from first entry
PipeInfo(cnt).condition =           'Neck';
PipeInfo(cnt).FIFFile =             '/home/foldes/Data/MEG/Test/Stimulation/mr07_tsss.fif';
PipeInfo(cnt).EventFile =           [];

cnt = cnt + 1;
PipeInfo(cnt) = PipeInfo(1);        % Copy parameters from first entry
PipeInfo(cnt).condition =           'Cheek';
PipeInfo(cnt).FIFFile =             '/home/foldes/Data/MEG/Test/Stimulation/mr08_tsss.fif';
PipeInfo(cnt).EventFile =           [];


%% RUN PIPELINE
% 
% %%for ipipe = 1:length(PipeInfo)
%     sInput.SubjectName =    PipeInfo(ipipe).subject; % 'Group_analysis';
%     sInput.Condition =      PipeInfo(ipipe).condition; %'Attempt_Grasp_RT';
%     TimeS =                 TimeS_list(ipipe); % 0.08; % 80ms after cue
%     try
%         ScoutInfo(ipipe) = process_SmartScout('Compute',sInput,'Threshold',...
%             'NameDesign','[condition]_[DataThreshold]_[MaskScouts]_[TimeS]',...
%             'DataThreshold',0.8,'SizeThreshold',1,...
%             'TimeS',TimeS,...
%             'MaskAtlas','Destrieux',...
%             'MaskScouts','G_postcentral L');
% 
%         %         ScoutInfo(ipipe) = process_SmartScout('Compute',sInput,'Threshold',...
%         %             'NameDesign','[condition]_[DataThresholdValue]_[MaskScouts]_[TimeS]',...
%         %             'DataThresholdValue',0.5,...
%         %             'TimeS',TimeS,...
%         %             'MaskAtlas','Destrieux',...
%         %             'MaskScouts','G_postcentral L');
%         
% %         ScoutInfo(ipipe) = process_SmartScout('Compute',sInput,'MaxPoint',...
% %             'NameDesign','[condition]_[MaskScouts]_[TimeS]',...
% %             'TimeS',TimeS,...
% %             'MaskAtlas','Destrieux',...
% %             'MaskScouts','G_postcentral L');
%     end
% end
% [PipeInfo, sFiles_4debug] = PipeInfo.Run('Source');

%%
ipipe = 0;

% MNS
ipipe = ipipe+1;
TimeS_list(ipipe) = .038;

% Index
ipipe = ipipe+1;
TimeS_list(ipipe) = .044;

% Thumb
ipipe = ipipe+1;
TimeS_list(ipipe) = .044;

% Pinky
ipipe = ipipe+1;
TimeS_list(ipipe) = .045;

% ForeArm
ipipe = ipipe+1;
TimeS_list(ipipe) = .055;

% UpperArm
ipipe = ipipe+1;
TimeS_list(ipipe) = .029;

% Neck
ipipe = ipipe+1;
TimeS_list(ipipe) = .027;

ScoutOrder = [7 6 5 1 4 2 3];
ScoutColors = jet(length(ScoutOrder)*2); % flipud(jet(7*2));

clear ScoutInfo
for ipipe = 1:length(ScoutOrder)
    
    current_pipe_num = ScoutOrder(ipipe);
    
    clear sInput
    sInput.SubjectName =    PipeInfo(current_pipe_num).subject; % 'Group_analysis';
    sInput.Condition =      PipeInfo(current_pipe_num).condition; %'Attempt_Grasp_RT';
    TimeS =                 TimeS_list(current_pipe_num); % 0.08; % 80ms after cue
    ScoutInfo(ipipe) = process_SmartScout('Compute',sInput,'Threshold',...
        'NameDesign','[condition]_[DataThreshold]_[MaskScouts]_[TimeS]_Unconstr',...
        'DataThreshold',0.9,'SizeThreshold',2,...
        'TimeS',TimeS,...
        'Color',ScoutColors(ipipe,:),...
        'MaskAtlas','Destrieux',...
        'MaskScouts','G_postcentral L');
    pause(0.5)
    
    %         % For CenterOfMass
    %         ScoutInfo(ipipe) = process_SmartScout('Compute',sInput,'Threshold',...
    %             'NameDesign','[condition]_[DataThreshold]_[MaskScouts]_[TimeS]',...
    %             'DataThreshold',0,'SizeThreshold',1,...
    %             'TimeS',TimeS,...
    %             'MaskAtlas','Destrieux',...
    %             'MaskScouts','G_postcentral L');
    
    %         ScoutInfo(ipipe) = process_SmartScout('Compute',sInput,'Threshold',...
    %             'NameDesign','[condition]_[DataThresholdValue]_[MaskScouts]_[TimeS]',...
    %             'DataThresholdValue',0.5,...
    %             'TimeS',TimeS,...
    %             'MaskAtlas','Destrieux',...
    %             'MaskScouts','G_postcentral L');
    
    %         ScoutInfo(ipipe) = process_SmartScout('Compute',sInput,'MaxPoint',...
    %             'NameDesign','[condition]_[MaskScouts]_[TimeS]',...
    %             'TimeS',TimeS,...
    %             'MaskAtlas','Destrieux',...
    %             'MaskScouts','G_postcentral L');
end
% panel_scout('SetScoutTransparency',0.5);




%%

Plot_ScoutInfo_Somatotopy(ScoutInfo,'Max')

% ScoutInfo.condition
% ScoutInfo = process_SmartScout('Load_Scout_and_ScoutInfo');
% ScoutOrder = [7 6 5 1 4 2 3];
% ScoutColors = jet(length(ScoutOrder)*2); % flipud(jet(7*2));
% Plot_ScoutInfo_Somatotopy(ScoutInfo,'Max','ScoutOrder',ScoutOrder,'ScoutColors',ScoutColors)
% %Plot_ScoutInfo_Somatotopy(ScoutInfo,'Centroid','ScoutOrder',ScoutOrder,'ScoutColors',ScoutColors)
% Plot_ScoutInfo_Somatotopy(ScoutInfo,'CenterOfMass','ScoutOrder',ScoutOrder,'ScoutColors',ScoutColors)



ScoutInfo = process_SmartScout('Load_Scout_and_ScoutInfo');
ScoutOrder = [1 4 2 3];
ScoutColors = jet(length(ScoutOrder)*2); % flipud(jet(7*2));
Plot_ScoutInfo_Somatotopy(ScoutInfo,'Max','ScoutOrder',ScoutOrder,'ScoutColors',ScoutColors)
%Plot_ScoutInfo_Somatotopy(ScoutInfo,'Centroid','ScoutOrder',ScoutOrder,'ScoutColors',ScoutColors)
Plot_ScoutInfo_Somatotopy(ScoutInfo,'CenterOfMass','ScoutOrder',ScoutOrder,'ScoutColors',ScoutColors)



% % Or just re-run
% AtlasInfo = process_SmartScout('AtlasReport');
% 
% for iscout = 1:22
%     AtlasInfo{iscout}.Label
% end






