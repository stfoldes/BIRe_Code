
% Calc a scout (or load)
ScoutInfo = BST_SmartScout(gcf,'Threshold','DataThreshold',0.8,...
    'MaskAtlas','Desikan-Killiany','MaskScouts','postcentral L',...
    'NameDesign','[condition]_[DataThreshold]_[MaskScouts]');

ScoutInfo.CenterOfMass.prinprj


data2prj(1,:) = (ScoutInfo.Max.scsLoc/1000)';
data2prj(2,:) = (ScoutInfo.Centroid.scsLoc/1000)';
data2prj(3,:) = (ScoutInfo.CenterOfMass.scsLoc/1000)';

sSurf = bst_memory('GetSurface', ScoutInfo.surface);
Projection.Atlas =          ScoutInfo.parms_in.MaskAtlas;
Projection.Scouts =         ScoutInfo.parms_in.MaskScouts;
Projection.Vertices =       Limit_Vertices_with_Scouts([],sSurf,Projection.Atlas,Projection.Scouts);
Projection.VerticesXYZ =    sSurf.Vertices(Projection.Vertices,:);

[data2prj_1D] = ROIPrincipalProjection(data2prj,Projection.VerticesXYZ,1);













