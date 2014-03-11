x = process_SmartScout('Compute',sInput,'Threshold',...
    'NameDesign','[condition]_[DataThreshold]_[MaskScouts]_[TimeS]',...
    'DataThreshold',0.8,...
    'TimeS',TimeS,...
    'MaskAtlas','Desikan-Killiany',...
    'MaskScouts','postcentral L',...
    'Conservative',false);

% x = load('/home/foldes/Data/brainstorm_db/Stim/anat/scout_SmartScout_Stim.mat')


%{
new info
file info

always use new
add file info if valid scout exists


remove doubles
OR
only add fileinfo for unpopulated names


ScoutInfo def

ScoutID 
Vertices
Seed
Color
Label
Function
Region
Handles
subject
condition
surface
date_generated
VerticesXYZ
totalArea


Identify scout function
looks at Vertices for full match





%}


% template = struct(...
%     'Name',   'User scouts', ...
%     'Scouts', repmat(db_template('Scout'), 0));

