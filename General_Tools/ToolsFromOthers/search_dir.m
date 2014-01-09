function result = search_dir(rootdir, searchstr, strict, case_insensitive)
% Searches the directories recursively for files or folders matching pattern.
% Outputs a cell array of full path names
%
% INPUTS:
%   rootdir:            directory to begin recursive search
%   searchstr:          can include *, ., separators, etc
%   strict:             [OPTIONAL] 1 = search needs a perfect match to pattern [DEFAULT = 0]
%                       Use if you DON'T want subfolder search
%   case_insensitive:   [OPTIONAL] 1 = search is not sensitive to case [DEFAULT = 0]
%
% EXAMPLES:
%
%   All jpg and tif files on C:\
%       rootdir = 'C:\';
%       searchstr = '*.jpg;*.tif';
%       files = search_dir(rootdir, searchstr);
%   
%   All files or folders with 'matlab' in the name (case insenstive)
%       rootdir = 'C:\';
%       searchstr = 'MatLab';
%       files = search_dir(rootdir, searchstr, [], true);
%   
%   All jpg files in C:\ (no subfolders)
%       rootdir = 'C:\';
%       searchstr = '*.jpg';
%       files = search_dir(rootdir, searchstr, true);
%
%   All folders only (complete directory tree of the C-drive)
%       rootdir = 'C:\';
%       searchstr = ['*' filesep];
%       files = search_dir(rootdir, searchstr, true);
%
%   SEE: REGEXPDIR
%
% 2007 [B.C. Hamans (b.c.hamans@rad.umcn.nl)]
% CHANGED FROM wildcardsearch.m 2014-01-06 Foldes
% http://www.mathworks.com/matlabcentral/fileexchange/16217-wildcardsearch
% UPDATES:
% 2014-01-06 Foldes: MAJOR updated inputs and names, and documentation
% 2014-01-07 Foldes: removes double fileseps in dir. This caused issues with regexp
% 2014-01-09 Foldes: loose --> strict

% Check input
error(nargchk(2, 4, nargin));

% Remove double separators (will mess regexp) 2014-01-07
double_sep_idx = strfind(rootdir,[filesep filesep]);
rootdir(double_sep_idx) = [];

% Create the regular expression
beginstr='('; endstr=')';

if ~exist('strict','var'); 
    strict = false; 
end
if strict; beginstr=['^' beginstr]; 
    endstr=[endstr '$']; 
end

% Changed 2014-01-06 Foldes
if ~exist('case_insensitive','var') || isempty(case_insensitive) 
    case_insensitive = false; 
end
if ~case_insensitive; 
    beginstr = ['(?-i)' beginstr]; 
end

regexpstr=[beginstr strrep(regexptranslate('wildcard', searchstr), pathsep, [endstr '|' beginstr]) endstr];

% Search
result = regexpdir(rootdir, regexpstr, true);

%==========================================================================
% Changelog:
% 03-09-2007 v1.00 (BCH)  Initial release
%==========================================================================