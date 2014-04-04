function [bad_entry_list_out]=Plot_BadChans(obj,varargin)
% Head plots of all bad channels in DB
% Use DB_Find_Entries_By_Criteria to make a smaller DB (see below)
%
% OPTIONAL:
%   quality_thres: only plot for file with % of sensorimotor channels that are GOOD < Threshold [default = 90% good]
%               for example, 'quality_thres',0.9 --> only plot if 10% of the sensorimotor channels are bad
%
% EXAMPLE:
%     clear
%     [DB,DBbase_location,local_path,server_path]=DB_Load_Database_Cheat('meg_neurofeedback');
%
%     % Choose criteria for data set to analyize
%     clear criteria_struct
%     criteria_struct.subject ={'NS07' 'NS01' 'NC02' 'NC07'};
%     criteria_struct.run_type = 'Open_Loop_MEG';
%     criteria_struct.run_task_side = 'Right';
%     criteria_struct.run_action = 'Grasp';
%     DB_short = DB(DB_Find_Entries_By_Criteria(DB,criteria_struct));
%
%     DB_short.Plot_BadChans(server_path)
%         or
%     Plot_BadChans(DB,server_path)
%
% 2013-08-13 Foldes
% UPDATES:
% 2013-08-16 Foldes: Small
% 2013-10-04 Foldes: MAJOR Metadata-->DB

global MY_PATHS

%% DEFAULTS
defaults.quality_thres = 0.9; % only plot for file with % of sensorimotor channels that are GOOD < Threshold [default = 10% bad]
parms = varargin_extraction(defaults,varargin);

%% Plot bad channels
bad_entry_list = [];
for ientry = 1:length(obj)
    %disp([obj(ientry).subject ' ' obj(ientry).session ' ' obj(ientry).run ' ' obj(ientry).run_action ' ' obj(ientry).run_task_side ' ' obj(ientry).run_intention  ' (' num2str(ientry) ')'])
    
    DB_entry = obj(ientry);
    
    %     if isempty(DB_entry.Preproc.Pointer_prebadchan)
    %         warning(['No prebadchan ' obj(ientry).subject ' ' obj(ientry).session ' ' obj(ientry).run ' ' obj(ientry).run_action ' ' obj(ientry).run_task_side ' ' obj(ientry).run_intention  ' (' num2str(ientry) ')'])
    %     end
    
    try
        autobad = DB_entry.Preproc.bad_chan_list;
        % prebad_neuromagcode = load([MY_PATHS.server_base filesep DB_entry.subject filesep 'S' DB_entry.session filesep DB_entry.entry_id '_prebadchan.txt']);
        prebad_neuromagcode = DB_entry.load_pointer('Preproc.Pointer_prebadchan');
        prebad = NeuromagCode2ChanNum(prebad_neuromagcode);
        %
        %     num_prebad = length(prebad);
        %     num_bad = length(autobad);
        %     num_autobad = num_bad-num_prebad;
        quality = DB_entry.Preproc.sensorimotor_chan_quality;%length(find_lists_overlap_idx(autobad,DEF_MEG_sensors_sensorimotor))/length(DEF_MEG_sensors_sensorimotor);
        
        % Only plot if quality is poor (default at show all)
        if quality < parms.quality_thres
            bad_entry_list = [bad_entry_list ientry];
            % PLOT
            figure;hold all
            Plot_MEG_chan_locations(prebad,'MarkerType',2,'Color','r')
            Plot_MEG_chan_locations(autobad,'MarkerType',0,'Color','k')
            title([obj(ientry).run_info ' (S' obj(ientry).session ' R' obj(ientry).run ') [' num2str(quality) ']'])
        end
    end % try
end

% if nargout>0
    bad_entry_list_out = bad_entry_list;
% end

