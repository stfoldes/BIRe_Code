ScoutInfo = BST_SmartScout(gcf,'Threshold','DataThreshold',0.8,...
    'MaskAtlas','Desikan-Killiany','MaskScouts','postcentral L',...
    'NameDesign','[condition]_[DataThreshold]_[MaskScouts]');



%% Load in atlas
ProtocolInfo = bst_get('ProtocolInfo');
scout_name = ['SmartScouts ' ProtocolInfo.Comment]; % Name of Atlas; Could use 'User scouts';
dir_list = bst_get('LastUsedDirs'); % list of paths used in bst (what if ExportAnat = ''?)
ScoutFiles = fullfile(dir_list.ExportAnat,['scout_',scout_name '.mat']);
AllScouts = load(ScoutFiles);
% EX: AllScouts.ScoutInfo{1}.Max.mriLoc

%%

%mriLoc = struct_field2mat(AllScouts.ScoutInfo,'Max.mriLoc');

% plot Max.mriLoc as a new scout

%%

prinprj = struct_field2mat(AllScouts.ScoutInfo,'Max.prinprj');
