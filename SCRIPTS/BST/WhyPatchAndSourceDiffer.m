
% Change patch to discrete
TessInfo = getappdata(gcf,'Surface');
set(TessInfo.hPatch,'FaceColor','flat')
% set(TessInfo.hPatch,'FaceColor','interp')



% Normalize
iDataCmap = round( ((size(sColormap.CMap,1)-1)/(DataLimit(2)-DataLimit(1))) * (Data - DataLimit(1))) + 1;



% toBlend is correct


%%

 thanks for your constant love and support even when i push you away. you are the most amazing hu


%%


UpdateSurfaceColor(hFig, iTess)

    % Apply data threshold
    [DataSurf, ThreshBar] = ThresholdSurfaceData(DataSurf, TessInfo(iTess).DataLimitValue, TessInfo(iTess).DataThreshold, sColormap);
    % Get clusters that are above the threshold
    iVertOk = bst_cluster_threshold(abs(DataSurf), TessInfo(iTess).SizeThreshold, sSurf.VertConn);
    DataSurf(~iVertOk) = 0;
    
    % OKAY AT THIS POINT
    
    % Compute RGB values
    FaceVertexCdata = BlendAnatomyData(SulciMap, ...   % Anatomy: Sulci map
        TessInfo(iTess).AnatomyColor([1,end], :), ...  % Anatomy: color
        DataSurf, ...                                  % Data: values map
        TessInfo(iTess).DataLimitValue, ...            % Data: limit value
        TessInfo(iTess).DataAlpha,...                  % Data: transparency
        sColormap);                                    % Colormap
    % Set surface colors
    set(TessInfo(iTess).hPatch, 'FaceVertexCdata', FaceVertexCdata, ...
        'FaceColor',       'interp', ...
        'EdgeColor',       EdgeColor);
    
    
    %function mixedRGB = BlendAnatomyData(SulciMap, AnatomyColor, Data, DataLimit, DataAlpha, sColormap)
        iDataCmap = round( ((size(sColormap.CMap,1)-1)/(DataLimit(2)-DataLimit(1))) * (Data - DataLimit(1))) + 1;
        toBlend = find(Data ~= 0); % Find vertex indices holding non-zero activation (after thresholding)
        mixedRGB(toBlend,:) = DataAlpha * anatRGB(toBlend,:) + (1-DataAlpha) * dataRGB(toBlend,:);
    
%%


tissue1=find(FaceVertexCdata(:,1)==TessInfo(1).AnatomyColor(1,1) & FaceVertexCdata(:,2)==TessInfo(1).AnatomyColor(1,2) & FaceVertexCdata(:,3)==TessInfo(1).AnatomyColor(1,3));
tissue2=find(FaceVertexCdata(:,1)==TessInfo(1).AnatomyColor(2,1) & FaceVertexCdata(:,2)==TessInfo(1).AnatomyColor(2,2) & FaceVertexCdata(:,3)==TessInfo(1).AnatomyColor(2,3));
tissue = sort(unique([tissue1; tissue2]));

disp(['   ' num2str(TessInfo(1).nVertices) ' Total Vertices'])
disp(['   ' num2str(length(find(DataSurf>0))) ' Calculated Above Thresh'])
disp(['   ' num2str(TessInfo(1).nVertices - length(tissue)) ' Colored Above Thresh'])

%%

panel_scout('PlotScouts')
line: 3470
% vertMask works
% Picking faces doesn't make sense

% Get all the full faces in the scout patch
vertMask = false(length(Vertices),1);
vertMask(iScoutVert) = true;
% This syntax is faster but equivalent to:
% patchFaces = Faces(all(vertMask(Faces),2),:);
% THIS IS DOING A INTERSECTION/AND
iFacesTmp = find(vertMask(Faces(:,1)));
iFacesTmp = iFacesTmp(vertMask(Faces(iFacesTmp,2)));
iFacesTmp = iFacesTmp(vertMask(Faces(iFacesTmp,3)));
patchFaces = Faces(iFacesTmp,:);
% Renumber vertices in patchFaces
vertMask = zeros(length(Vertices),1);
vertMask(iScoutVert) = 1:length(iScoutVert);
patchFaces = vertMask(patchFaces);


iFacesTmp = find(vertMask(Faces(:,1)) | vertMask(Faces(:,2)) | vertMask(Faces(:,3)));
patchFaces = Faces(iFacesTmp,:);
patchFaces_flat = sort(reshape(patchFaces,1,[]));
% Renumber vertices in patchFaces
vertMask = zeros(length(Vertices),1);
vertMask(patchFaces_flat) = 1:length(patchFaces_flat);
patchFaces = vertMask(patchFaces);

sScouts(i).Handles(iHnd).hPatch = patch(...
    'Faces',            patchFaces, ...
    'Vertices',         patchVertices, ...
    'FaceVertexCData',  scoutColor, ...
    'FaceColor',        scoutColor, ...
    'EdgeColor',        'none',...
    'FaceAlpha',        1 - ScoutsOptions.patchAlpha, ...
    'BackFaceLighting', 'lit', ...
    'Tag',              'ScoutPatch', ...
    'Parent',           hAxes) ;


% What does this mean

% Each Face has 3 points.
% Step 1: You check if the FIRST point is in the scout (i.e. vertMask)
%   13 Faces pass
% Step 2: Of these Faces that fit the 1st point of the scout, which also fit the 2nd
%   3 Faces pass
% Step 3: Same but for 3rd
%   2 Faces pass
%
% This is doing an intersection (i.e. AND) opperation to determine if a Face belongs in a Scout
% Shouldn't this be a union (i.e. OR) to include all faces which have at least one point within the Scout
% This approach is more liberal (and really doesn't matter much), but it the source plots are more of a union
% coloring. When users are drawing/inspecting Scouts they may over estimate the 



% sSurf.Faces


%{
scout-patch vs. source-patch

I have a very technical question about the differences between the patches for surface and scout.

Should the Scout-patches include the surrounding faces since the surrounding faces are included in the Surface-patch?

For the surface-patch, all the faces for the whole brain are defined and it uses FaceColor 'interp' 
(figure_3d('UpdateSurfaceColor') (line 1929)). The means the faces around a vertex will be colored with a gradient. On the
other hand, scout-patches are independent of the whole brain and each face is defined only if all three corners of a
face are valid vertices (panel_scout('PlotScouts') (line 3493)). This means the visualization of the same data in a
scout will be smaller than if it were shown in a surface. 

Just for my own sake, I did check that a single active source/vertex will show up as a gradient across all adjecent faces
for a surface-patch, but only a single point for a scout.

I realize this discrepency is just about how the data is displayed and the real information is at the vertices, but I'm 
wondering if the visuals may confuse people when they are creating scouts. That is, someone might think a scout should
include the gradent when in fact this would be too big. Of course there may be a reason to do it this way, but I'm not
experienced enough to understand. 

I don't have a good solution to this. The gradient for the source-patch seems critical for display while the scout
is more percise. Displaying all faces connected to each scout-vertex would 'look' more correct compared to the source,
but it would perhaps be deceptive.


%}

             sScouts(i).Handles(iHnd).hPatch = patch(...
                                'Faces',            patchFaces, ...
                                'Vertices',         patchVertices, ...
                                'FaceVertexCData',  scoutColor, ...
                                'FaceColor',        scoutColor, ...
                                'EdgeColor',        'none',...
                                'FaceAlpha',        1 - ScoutsOptions.patchAlpha, ...
                                'BackFaceLighting', 'lit', ...
                                'Tag',              'ScoutPatch', ...
                                'Parent',           hAxes) ;
                            
                            
                            
                % This syntax is faster but equivalent to: 
                % patchFaces = Faces(all(vertMask(Faces),2),:);
                iFacesTmp = find(vertMask(Faces(:,1)));
                iFacesTmp = iFacesTmp(vertMask(Faces(iFacesTmp,2)));
                iFacesTmp = iFacesTmp(vertMask(Faces(iFacesTmp,3)));
                patchFaces = Faces(iFacesTmp,:);
                % Renumber vertices in patchFaces
                vertMask = zeros(length(Vertices),1);
                vertMask(iScoutVert) = 1:length(iScoutVert);
                patchFaces = vertMask(patchFaces);


             sScouts(i).Handles(iHnd).hPatch = patch(...
                                'Faces',            patchFaces, ...
                                'Vertices',         patchVertices, ...
                                'FaceVertexCData',  repmat(scoutColor,length(patchVertices),1), ...
                                'FaceColor',        'flat', ...
                                'EdgeColor',        'none',...
                                'FaceAlpha',        1 - ScoutsOptions.patchAlpha, ...
                                'BackFaceLighting', 'lit', ...
                                'Tag',              'ScoutPatch', ...
                                'Parent',           hAxes) ;

                            
                            
                            
        set(TessInfo(iTess).hPatch, 'FaceVertexCdata', FaceVertexCdata, ...
                                    'FaceColor',       'interp', ...
                                    'EdgeColor',       EdgeColor);
get(TessInfo(iTess).hPatch,'CDataMapping') = 'scaled';
size(get(TessInfo(iTess).hPatch,'Faces')) = [29986 x 3]
                                