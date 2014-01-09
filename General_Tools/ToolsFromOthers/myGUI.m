% GUI with check boxes

function myGUI

% Create figure
h.f = figure('units','normalized','position',[0.5,0.5,.05,.2],...
    'toolbar','none','menu','none');

% Create yes/no checkboxes
h.c(1) = uicontrol('style','checkbox','units','normalized',...
    'position',[.10,.80,.5,.1],...
    'string','Plot Raw');

h.c(2) = uicontrol('style','checkbox','units','normalized',...
    'position',[.10,.60,.5,.1],...
    'string','SSP?');



% Create OK pushbutton
h.p = uicontrol('style','pushbutton','units','normalized',...
    'position',[0,0,1,.1],'string','GO!',...
    'callback',@p_call);

checked = get(h.p,'Value');


% Pushbutton callback
    function checked = p_call(varargin)
        vals = get(h.c,'Value');
        checked = find([vals{:}]);
        %         if isempty(checked)
        %             checked = 'none';
        %         end
        %         disp(checked)
        
        
    end
end



