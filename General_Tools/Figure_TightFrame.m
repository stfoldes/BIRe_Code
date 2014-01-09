% Figure_TightFrame
%
% Quickly removes most of the borders around a figure (really its around an axis).
% Works on an "axis" so you can do on subplots, but one each one.
%
% Foldes 2012-10-05
% UPDATES:
% 2013-02-28 Foldes: Renamed from TightenFigureFrame.m
% 2013-07-03 Foldes: Added pause for gca...its needed.

function Figure_TightFrame(ax_handle)

if ~exist('ax_handle') || isempty(ax_handle)
%     %pause(0.01) % ?! This is needed...why?
%     drawnow % <-- this is screwy to the visuals
    ax_handle = gca;
end
try
    set(ax_handle,'LooseInset',get(ax_handle,'TightInset'));
end