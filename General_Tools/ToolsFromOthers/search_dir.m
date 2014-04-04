function result = search_dir(rootdir, searchstr, varargin)
% function result = search_dir(rootdir, searchstr, varargin) % 'SingleFile','Strict', 'CaseInsensitive'
% Searches the directories recursively for files or folders matching pattern.
% Outputs a cell array of full path names
%
% INPUTS:
%   rootdir:            directory to begin recursive search
%   searchstr:          can include *, ., separators, etc
%   SingleFile:         Returns a char instead of a cell, but only one file can be returned
%                       If more than one match found, a UI will help
%   Strict:             [OPTIONAL] 1 = search needs a perfect match to pattern [DEFAULT = 0]
%                       Use if you DON'T want subfolder search
%   CaseInsensitive:    [OPTIONAL] 1 = search is not sensitive to case [DEFAULT = 0]
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
%       files = search_dir(rootdir, searchstr, 'CaseInsensitive',true);
%   
%   All jpg files in C:\ (no subfolders)
%       rootdir = 'C:\';
%       searchstr = '*.jpg';
%       files = search_dir(rootdir, searchstr, 'Strict',true);
%
%   All folders only (complete directory tree of the C-drive)
%       rootdir = 'C:\';
%       searchstr = ['*' filesep];
%       files = search_dir(rootdir, searchstr, 'Strict',true);
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
% 2014-02-04 Foldes: Varargin

parms.Strict =          false;
parms.CaseInsensitive = false;
parms.SingleFile =      false;
parms = varargin_extraction(parms,varargin);

% Remove double separators (will mess regexp) 2014-01-07
double_sep_idx = strfind(rootdir,[filesep filesep]);
rootdir(double_sep_idx) = [];

% Create the regular expression
beginstr='('; endstr=')';

if parms.Strict; beginstr=['^' beginstr]; 
    endstr=[endstr '$']; 
end

if ~parms.CaseInsensitive; 
    beginstr = ['(?-i)' beginstr]; 
end

regexpstr=[beginstr strrep(regexptranslate('wildcard', searchstr), pathsep, [endstr '|' beginstr]) endstr];

% Search
result = regexpdir(rootdir, regexpstr, true);

if parms.SingleFile == true
    % Can only have one file
    if length(result)>1
        [FileName,PathName] = uigetfile([search_str '.mat'],['Multiple files found. Select one.'],rootdir);
        result = fullfile(PathName,FileName);
    else
        result = cell2mat(result);
    end
end
