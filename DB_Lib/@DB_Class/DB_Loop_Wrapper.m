function [DB, ErrorList] = DB_Loop_Wrapper(DB,criteria,save_pointer,save_var,compute_str,varargin)
% Wrapper to do a simple, standard loop through a database.
% Will loop through all 'DB' entries that fit 'criteria'.
% Each iteration will run the code 'compute_str' which can uses the variable placed in 'varargin'
% After this computation, the variable 'save_var' will be saved to the DB in the pointer
% 'save_pointer'
% Meant for very simple loops, but technically compute_str can be as long as you'd like.
% Will do a try-catch and any errors will be reported in ErrorList 
%
% INPUTS
%   DB:             Should be the ENTIRE DB, not a subset 
%   criteria:       Standard formating, see DB_Class
%   save_pointer:   String of the pointer name, e.g. ''ResultPointers.SourceModDepth_tsss_Cue'
%                   This can be blank and it won't save anything (not sure the use of this)
%   save_var:       String name of variable that will be saved to the pointer
%   compute_str:    String of any computation to be done within the loop
%                   code will have access to DB_entry and variables entered into varargin
%   varargin:       Put all variables you want to pass. The variable will be named the same
%                   as the input name. e.g. ...,AnalysisParms);
% OUTPUT:
%   DB:             Full DB, DONT FORGET TO SAVE TO TEXT LATER
%   ErrorList:      Information about what has failed
%
% WARNINGS:
%   Does not save DB to file
%   overwrite_results_flag hardcoded to true
%   Only one variable can be saved to a pointer
%   
% EXAMPLES:
%   When testing, you can use this code to model 1 rep of this loop
%     % ===TESTING SCRIPT===
%     if ~isempty(criteria)
%         DB_short = DB.get_entry(criteria);
%     else
%         DB_short = DB;
%     end
%     ientry = 1;
%     DB_entry = DB_short(ientry);
%     % ====================
%
% 2014-03-27 Foldes
% UPDATES: 
%

overwrite_results_flag = true; % currently HARDCODED

% Get all varibles in varargin into this workspace
narg_max = 5; % HARDCODED: 5 inputs b/f varargin
for inarg = 1:length(varargin)
    var_name = inputname(narg_max + inarg);
    eval([var_name ' = varargin{' num2str(inarg) '};'])
end


% Save DB if a pointer is named
if ~isempty(save_pointer)
    save_DB_flag = true;
else
    save_DB_flag = false;
end


%% Get only valid entries
if ~isempty(criteria)
    DB_short = DB.get_entry(criteria);
else
    DB_short = DB;
end

%% Loop for All Entries
ErrorList = [];
for ientry = 1:length(DB_short)
    % ientry = 1;
    DB_entry = DB_short(ientry);
    disp(' ')
    disp(['===START: File #' num2str(ientry) '/' num2str(length(DB_short)) ' | ' DB_entry.entry_id '==='])
    
    try
        % ================================================================
        % ===COMPUTE======================================================
        % ================================================================
        
        eval(compute_str);
        
        % ================================================================
        
        % ===Save processed data to file & write to DB entry===
        if save_DB_flag == 1
            eval(['[DB_entry,save_success] = DB_entry.save_pointer('...
                save_var ',''' save_pointer ''',''mat'',overwrite_results_flag);'])
            
            % Save current DB entry back to database
            if save_success == 1
                DB = DB.update_entry(DB_entry);
            end
        end
        
    catch
        ErrorList = error_list_manager(ErrorList,[DB_entry.entry_id ' ientry=' num2str(ientry)]);
    end
    disp(' ')
    disp(['===DONE [' num2str(length(ErrorList)) ' Errors]: ' datestr(now,'mm-dd HH:MM:SS') ' | ' DB_entry.entry_id '==='])
end


%% SAVE DB TO FILE OUT OF THIS FUNCTION
% % Save database out to file
% if save_DB_flag == 1 && save_success == 1
%     DB.save_DB;
% end




