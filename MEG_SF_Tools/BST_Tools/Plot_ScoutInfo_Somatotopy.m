function [max_separation_mm,Fig] = Plot_ScoutInfo_Somatotopy(ScoutInfo,stat_name,varargin)
% Plot the points in ScoutInfo(:).(stat_name).scsLoc/prinproj on ScoutInfo(1).Vertices_ROI
% Also outputs the maximum separation in the group (in mm)
%
% 'ScoutOrder': Organize ScoutInfo(ScoutOrder)
% 'ScoutColors': Colors to use
% 
% EXAMPLE:
%   ScoutInfo = process_SmartScout('Load_Scout_and_ScoutInfo');
%   ScoutOrder = [7 6 5 1 4 3 2];
%   ScoutColors = jet(7*2); % flipud(jet(7*2));
%   Plot_ScoutInfo_Somatotopy(ScoutInfo,'Max','ScoutOrder',ScoutOrder,'ScoutColors',ScoutColors)
%
% 2014-03-06 Foldes
% UPDATES:
%

%% Setup

if ~exist('ScoutInfo')
    % Load ScoutInfo for the atlas, assuming you are selected on the atlas
    ScoutInfo = process_SmartScout('Load_Scout_and_ScoutInfo');
end

parms.ScoutOrder =  [1:length(ScoutInfo)];
parms.ScoutColors = rand(length(ScoutInfo),3);

parms = varargin_extraction(parms,varargin);

%% Get info out of ScoutInfo

for iscout = 1:length(parms.ScoutOrder)
    ConditionNames{iscout} = ScoutInfo(parms.ScoutOrder(iscout)).condition;
    scsLoc(iscout,:) = ScoutInfo(parms.ScoutOrder(iscout)).(stat_name).scsLoc;
    prinprj(iscout,:) = ScoutInfo(parms.ScoutOrder(iscout)).(stat_name).prinprj;
end

sSurf = bst_memory('GetSurface', ScoutInfo(1).surface);
ROI_VertXYZ = sSurf.Vertices(ScoutInfo(1).Vertices_ROI,:)*1000;

%% Plot

hFig = figure; 
subplot(2,1,1); hold all
plot3(ROI_VertXYZ(:,1),ROI_VertXYZ(:,2),ROI_VertXYZ(:,3),'.','Color',0.6*[1 1 1])
for iscout = 1:size(scsLoc,1)
    plot3(scsLoc(iscout,1),scsLoc(iscout,2),scsLoc(iscout,3),'.-','MarkerSize',30,'Color',parms.ScoutColors(iscout,:))
    text(scsLoc(iscout,1),scsLoc(iscout,2),scsLoc(iscout,3),ConditionNames{iscout},...
        'FontSize',16,'Color',parms.ScoutColors(iscout,:),'VerticalAlignment','Bottom','FontWeight','Bold')
end
title(stat_name)
box on
axis square

subplot(2,1,2); hold all
for iscout = 1:size(scsLoc,1)
    stem(iscout,prinprj(iscout),'.-','MarkerSize',30,'Color',parms.ScoutColors(iscout,:))
    text(iscout,prinprj(iscout),ConditionNames{iscout},...
        'FontSize',16,'Color',parms.ScoutColors(iscout,:),...
        'HorizontalAlignment','Center','VerticalAlignment','Bottom')
end

ylabel({'Principal Projection (mm)','<-- Lateral|Medial -->'})
xlabel('Input order')
axis square
Figure_Stretch(1,2)



%% Get max separation

clear sep_dist
for iscout = 1:size(scsLoc,1)
    for jscout = iscout+1:size(scsLoc,1)
        sep_dist(iscout,jscout) = norm(scsLoc(iscout,:) - scsLoc(jscout,:));
    end
end

max_separation_mm = max(max(sep_dist));


