% function rounded = round_sig(data,sig)
% Returns rounded value given the significant digits
% EXAMPLES: 
%   round_sig(118.223,-2) = 118.22
%   round_sig(118.223,0) = 118
%   round_sig(118.223,2) = 100
%
% Stephen Foldes (2012-04-12)

function rounded = round_sig(data,sig)

rounded = round(data/(10^sig))*(10^sig);



