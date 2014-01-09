function h=Plot_MEG_chan_locations(chan_num,varargin) % ,MarkerType,Color,fig,helmet_flag)
%
% Plots where the given channels are located on the standard 306 channel MEG. Requires sensors102.mat
%
% chan_num: Ordered Sensor Number [1:306]. See NeuromagCode2ChanNum.m for translation from other numbering
%           No input will plot all sensors w/ labels
% VARARGIN:
%   Color: color string (e.g. 'k') or 1x3 RGB vector for the color. [default: red]
%   parms.MarkerType:
%       0 = Disc: display only input channels as a transparent disc of a given color,
%       1 = Dot: display input channels as a dot of a given color [default]
%       2 = All: display input channels as given color, display unused channels as black,
%       3 = Labeled: same as 1, but display channel numbers for given channels
%
%   helmet_flag: 1[default] = plot outline of helmet
%   fig: figure handle to plot to [default: new figure]
%
% Nose is up, left is left (and indicated)
%
% EXAMPLES:
%     Plot_MEG_chan_locations([1:306],'MarkerType',1,'Color','r');
%
% SEE: Plot_MEG_Helmet.m
%
% Stephen Foldes (02-21-2011)
% UPDATES:
% 2012-02-01 SF: Renamed function from MEG_chan_locations.m
% 2012-04-06 SF: only chan_num needed now
% 2012-09-25 Foldes: axis tight for better ploting
% 2013-06-13 Foldes: changed display options
% 2013-08-13 Foldes: MAJOR varargin method applied
% 2013-12-18 Foldes: no inputs will plot all sensors w/ labels

%% DEFAULTS

defaults.Color          = 'k'; % red
defaults.MarkerType     = 2; % all shown black, given is colored
defaults.helmet_flag    = 1; %
defaults.fig            = []; % default is new figure
parms = varargin_extraction(defaults,varargin);

chan_font_size = 8; % this is set b/c channel name offsets are dependent on size

if isempty(parms.fig)
    parms.fig = gcf;
end

% if you dont input anything, then plot all sensors w/ labels
if ~exist('chan_num') || isempty(chan_num)
    chan_num            = [1:306];
    parms.MarkerType    = 3;
end
%%

% Load sensor location (okay for now, 2013-08)
load sensors102.mat
sensor_pos(:,1) = c102(:,2);
sensor_pos(:,2) = c102(:,3);

% MEG sensors are in groups of 3s
sensor_num = ceil(chan_num./3);

figure(parms.fig)
hold all
axis off

if parms.MarkerType > 1
    % Plot all sensor locations
    for isensor=1:size(sensor_pos,1)
        plot(sensor_pos(isensor,1), sensor_pos(isensor,2), '.','MarkerSize',10,'Color',0*[1 1 1])
    end
end

if chan_num>0
    for ichan=1:size(chan_num,2)
        
        % Make the sensor location
        if parms.MarkerType==0 % Disc option
            if strcmp(parms.Color,'none')
                Plot_TransparentMarker(sensor_pos(sensor_num(ichan),1), sensor_pos(sensor_num(ichan),2),2,'k',0,parms.fig);
            else
                Plot_TransparentMarker(sensor_pos(sensor_num(ichan),1), sensor_pos(sensor_num(ichan),2),2,parms.Color,0.25,parms.fig);
            end
        else % Dot option
            plot(sensor_pos(sensor_num(ichan),1), sensor_pos(sensor_num(ichan),2), '.','MarkerSize',30,'Color',parms.Color);
        end
        
        % Only plot channel numbers if user wanted it
        if parms.MarkerType == 3
            % Put channel number next to highlighted sensors
            sensor_type = mod(chan_num(ichan),3);
            chan_name_size = size(num2str(chan_num(ichan)),2); % how many characters are going to be displayed?
            
            switch sensor_type
                case 0
                    text(sensor_pos(sensor_num(ichan),1)+1, sensor_pos(sensor_num(ichan),2), num2str(chan_num(ichan)), 'FontSize', chan_font_size)
                case 1
                    text(sensor_pos(sensor_num(ichan),1)-(chan_name_size*1.2), sensor_pos(sensor_num(ichan),2), num2str(chan_num(ichan)), 'FontSize', chan_font_size)
                case 2
                    text(sensor_pos(sensor_num(ichan),1)-(chan_name_size*0.5), sensor_pos(sensor_num(ichan),2)-2, num2str(chan_num(ichan)), 'FontSize', chan_font_size)
            end
        end
        
    end
end

text(min(sensor_pos(:,1))-10, mean(sensor_pos(:,2)), 'L', 'FontSize', 16, 'FontWeight', 'bold')

% axis([min(sensor_pos(:,1)) max(sensor_pos(:,1)) min(sensor_pos(:,2)) max(sensor_pos(:,2))])
axis equal
% axis tight

if parms.helmet_flag
    Plot_MEG_Helmet(parms.fig);
end

drawnow

% Only send outputs if requested
if nargout
    h = parms.fig;
end

