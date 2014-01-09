% fig = Plot_TransparentMarker(x,y,radius,color_choice,alpha_choice,fig)
% Stephen Foldes [2012-08-31]
%
% Plots a transparent circle that can be used as a marker
%
% x,y are cartecian locations
% radius(optional) is the radius (default=1)
% color_choice(optional) can be the string (e.g. 'k') or RGB (default gray)
% alpha_choice(optional) = 0(transparent) to 1(opacque), defaults to 0.5
% fig(optional) = figure handle (optional)

function fig = Plot_TransparentMarker(x,y,radius,color_choice,alpha_choice,fig)

%% Set Defaults
if ~exist('radius') || isempty(radius)
    radius = 1;
end

if ~exist('fig') || isempty(fig)
    fig = figure;
end

if ~exist('alpha_choice') || isempty(alpha_choice)
    alpha_choice = 0.5;
end

% Default color if none given
if ~exist('color_choice') || isempty(color_choice)
    color_choice = 0.4*[1 1 1];
end

%% Create Circle

theta = linspace(0,2*pi,20)';
circle_x = radius*cos(theta)+x;
circle_y = radius*sin(theta)+y;

%% Plot
figure(fig)
hold all

fill(circle_x,circle_y,color_choice,'FaceAlpha',alpha_choice,'EdgeColor',color_choice);
% fill(circle_x,circle_y,color_choice,'FaceAlpha',alpha_choice,'EdgeColor','none');
% axis square

% Could do w/o fill, but is same speed
% plot(circle_x,circle_y,'Color',color_choice);










