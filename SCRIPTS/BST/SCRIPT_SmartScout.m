% Script for doing smart scout
%
% 2014-02-22 Foldes

process_SmartScout('Lim



BST_SmartScout(gcf,'View',...
    'MaskAtlas','Desikan-Killiany','MaskScouts','postcentral L',...
    'NameDesign','[condition]_[MaskScouts]');


ScoutInfo = BST_SmartScout(gcf,'MaxPoint',...
    'MaskAtlas','Desikan-Killiany','MaskScouts','postcentral L',...
    'NameDesign','[condition]_[MaskScouts]_[scout_method]');

%%
% % Load in file
% ProtocolInfo = bst_get('ProtocolInfo');
% scout_name = ['SmartScouts ' ProtocolInfo.Comment]; % Name of Atlas; Could use 'User scouts';
% dir_list = bst_get('LastUsedDirs'); % list of paths used in bst (what if ExportAnat = ''?)
% ScoutFiles = fullfile(dir_list.ExportAnat,['scout_',scout_name '.mat']);
% AllScouts = load(ScoutFiles);
% AllScouts.ScoutInfo{1}.Max.mriLoc
% 
% mriLoc = struct_field2mat(AllScouts.ScoutInfo,'Max.mriLoc')
% 
% color_list = colormap('jet');
% color_idx = floor(Normalize(mriLoc(1,:)').*length(color_list));
% color_idx(color_idx==0) = 1;
% new_color_list = color_list(color_idx,:);
% 
% for iscout = 1:length(AllScouts.Scouts)
%     AllScouts.Scouts(iscout).Color = new_color_list(iscout,:);
% end
% save(ScoutFiles,'-struct','AllScouts','Name','TessNbVertices','Scouts','ScoutInfo'); % Also saves ScoutInfo



%%

ScoutInfo = BST_SmartScout(gcf,'Threshold','DataThreshold',0.8,...
    'MaskAtlas','Desikan-Killiany','MaskScouts','postcentral L',...
    'NameDesign','[condition]_[DataThreshold]_[MaskScouts]');


% View, but conservative (not recommended)
% BST_SmartScout([],'View','Conservative',true,'FORCESAVE',true)

ScoutInfo = BST_SmartScout([],'Threshold','DataThreshold',0.4,'MaskAtlas','Desikan-Killiany','MaskScouts','postcentral L|precentral L');

% W/ Theshold that is a value (vs. a proportion)
ScoutInfo = BST_SmartScout([],'Threshold','DataThresholdValue',1e-10,'MaskAtlas','Desikan-Killiany','MaskScouts','postcentral L|precentral L');


%% EXAMPLE: Get CenterOfMass information from all activity in LT Motor Cortex that has a dSPM value above 0.8
ScoutInfo = BST_SmartScout([],'Threshold','DataThresholdValue',0.8,...
    'MaskAtlas','Desikan-Killiany','MaskScouts','precentral L');
% I ERASED THE ATALS, whY?

% Display
fprintf('\nCenter Of Mass:\n');
fprintf('\tVertex:\t %i\n',ScoutInfo.CenterOfMass.vertex)
fprintf('\tValue:\t %i\n',ScoutInfo.CenterOfMass.value)
%fprintf('\tSCS:\t x:%6.2f \ty:%6.2f \tz:%6.2f \n',ScoutInfo.CenterOfMass.scsLoc(1),ScoutInfo.CenterOfMass.scsLoc(2),ScoutInfo.CenterOfMass.scsLoc(3));
fprintf('\tMRI:\t x:%6.2f \ty:%6.2f \tz:%6.2f \n',ScoutInfo.CenterOfMass.mriLoc(1),ScoutInfo.CenterOfMass.mriLoc(2),ScoutInfo.CenterOfMass.mriLoc(3));
if ~isempty(ScoutInfo.CenterOfMass.mniLoc)
    fprintf('\tMNI:\t x:%6.2f \ty:%6.2f \tz:%6.2f \n',ScoutInfo.CenterOfMass.mniLoc(1),ScoutInfo.CenterOfMass.mniLoc(2),ScoutInfo.CenterOfMass.mniLoc(3));
    
    % Talarach (not sure how accepted this is)
    %ScoutInfo.CenterOfMass.talLoc = mni2tal(ScoutInfo.CenterOfMass.mniLoc);
    %fprintf('\tTAL*:\t x:%6.2f \ty:%6.2f \tz:%6.2f \n',ScoutInfo.CenterOfMass.talLoc(1),ScoutInfo.CenterOfMass.talLoc(2),ScoutInfo.CenterOfMass.talLoc(3));
end


%% EXAMPLE: Get the area of activity with an ROI (which is above X%)



%%

% % Change source-patch to discrete
% TessInfo = getappdata(gcf,'Surface');
% set(TessInfo.hPatch,'FaceColor','flat')

%     % MEAN : Average of the patch activity at each time instant
%     case 'mean'
%         Fs = mean(F,1);
%     % STD : Standard deviation of the patch activity at each time instant
%     case 'std'
%         Fs = std(F,1);
%     % STDERR : Standard error
%     case 'stderr'
%         Fs = std(F,1) ./ size(F,1);
%     % RMS
%     case 'rms'
%         Fs = sqrt(sum(F.^2,1)); 
%     % POWER: Average of the square of the all the signals
%     case 'power'
%         if (nComp == 1)
%             Fs = mean(F.^2, 1);
%         else
%             Fs = mean(sum(F.^2, 3), 1);
%         end
% 
% Gamma bst toolbox. Compute time freq plan from trial data auto plot to surface from time or freq selection
% Scout info as cell array stored nexted to scout in atlas file
% 
% Full source better?
% 	do w/ dSPM
% 	
% Plot both conservative and NOT?
% Colors
% 
% Do subdivide automatically