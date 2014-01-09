function Figure_Save(save_name,save_path,fig)
% Just a quick way to save the current fig (as a png)
%
% save_name[OPTIONAL] = String of information to put in the file name (will add a time stamp to the file name)
% save_path[OPTIONAL] = Path, will default to a path based on computer info if added to the list
%
% EXAMPLE:
%   Figure_Run_on_All_Open_Figs('Figure_Save')
%
% Foldes [2012-09-11]
% UPDATES:
% 2012-09-24 Foldes: change
% 2012-09-25 Foldes: Now is a function and you can add any unique file-name information (or not, up to you)
% 2012-10-04 Foldes: Now closes figure but opens up saved .png file
% 2013-07-13 Foldes: Fixed windows bug w/ .png file name
% 2013-07-31 Foldes: MAJOR Changed default path, no longer open saved file, Renamed from Save_Fig, General update
% 2013-08-14 Foldes: Gives a unque name if needed

% DEFAULTS
if ~exist('save_path') || isempty(save_path)
    % Default is based off Computer Info
    computer_name = computer_info;
    switch computer_name
        case 'FoldesPC'
            % save_path='/home/foldes/Data/Results/';
            save_path='/home/foldes/Dropbox/Code/figs/';
    end
    
end
if ~exist('save_name') || isempty(save_name)
    save_name = '';
else
    save_name = [save_name '_'];
end
if ~exist('fig') || isempty(fig)
    fig = gcf;
end


try
    figure(fig);
    save_name_full = [save_path save_name datestr(now, 'yyyy.mm.dd_HHMMSS')];    
    % If file already exists, give it a unique number
    cnt = 1;
    while exist([save_name_full '.png'])==2 
        if cnt == 1 % first time needs to add _X to the end
            save_name_full=[save_name_full '_' num2str(cnt)];
        else % remove last number, add new
            save_name_full=[save_name_full(1:end-length(num2str(cnt-1))) num2str(cnt)];
        end
        cnt = cnt+1;
    end
        
    set(fig,'Units','inches')
    org_pos = get(fig,'Position');
    set(fig,'PaperPosition',org_pos)
    
    drawnow; % sometimes the pictures have errors, maybe pausing will help
    print('-dpng',[save_name_full '.png'])
    %     saveas(fig,save_name_full,'png');
    
    disp(['...SAVED FIG: ' save_name_full])
    %     close
    %     figure;
    %     imshow(save_name_full,'InitialMagnification',50);
catch
    disp('No Figure Saved (Check Paths)')
end


% % to squish all subplots together (SUCKS, labels overlap with neighboring subplots)
% subplot_handles = get(fig,'Children');
%
% for isubplot=1:length(subplot_handles)
%     set(subplot_handles(isubplot),'LooseInset',get(subplot_handles(isubplot),'TightInset'))
% end
