% Changes I've made to Brainstorm Files
%
% Stephen Foldes [2012-09]
% UPDATES:
% 2012-11-18 Foldes



/toolbox/process/bst_startup.m 
(line 396)
GRACE = 105; 

(line 80)
comment out % set(0,'defaultfiguretoolbar','none'); 

/toolbox/process/bst_process.m 
(line 616)
if ~strcmp(sProcess.SubGroup,'Standardize') % UPDATE 2012-11-18 [Foldes]: Standarization doesn't require equal sizes, turned it off

/io/out_results_volume.m
added option to have exact time point exported (NOT UP TO DATE)

/functions/process_zscore_ab.m
(line 86)
% UPDATED 2012-11-18 Foldes: What if there is only one time point, like in a PSD?
if size(sInputA.A,3) == 1
    iBaseline = 1;
end