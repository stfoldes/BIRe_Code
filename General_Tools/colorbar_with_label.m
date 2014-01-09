% colorbar_with_label(label_str,location)
%
% Puts a label on a colorbar. No need to make colorbar before calling this function.
% Can also be used to define the position of the color bar (super easy).
% As many or as few inputs can be used as desired.
% Default is font size of 12. Default position is "EastOutside"
%
% 'location' varible posibilities:
% 'North' =Inside plot box near top
% 'South' =Inside bottom
% 'East' =Inside right
% 'West' =Inside left
% 'NorthOutside' =Outside plot box near top
% 'SouthOutside' =Outside bottom
% 'EastOutside' =Outside right
% 'WestOutside' =Outside left
%
% EXAMPLE: colorbar_with_label('% Change from Baseline')
%
% Stephen Foldes (2012-01-31)
% UPDATES:
% 2012-09-06 Foldes: Now puts label in correct location and orentation for the colorbar location (ONLY DONE FOR "inside" positions)
% 2013-03-28 Foldes: Fixed bug for allowing *Outside as a location
% 2013-12-05 Foldes: Defualt changed to EastOutside

function colorbar_with_label(label_str,location)

% Make Color Bar and Position
if ~exist('location') || isempty(location)
    location='EastOutside';
end

cbar_handle=colorbar('location',location);

% Make Label
if exist('label_str') && ~isempty(label_str)
    
    switch location(1:4) % allow for *Outside as location
        case {'east','west','East','West'}
            set(cbar_handle,'YAxisLocation','right')
            set(get(cbar_handle,'ylabel'),'string',label_str,'FontSize',12,'Rotation',90.0);
            
        case {'nort','sout','Nort','Sout'}
            set(cbar_handle,'XAxisLocation','bottom')
            set(get(cbar_handle,'xlabel'),'string',label_str,'FontSize',12,'Rotation',0.0);
    end
end

