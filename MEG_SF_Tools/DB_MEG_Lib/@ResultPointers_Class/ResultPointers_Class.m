% Class to hold pointers to results files.
% Designed to be used with Metadata_Class
%
% 2013-04-24 Foldes
% UPDATES
% 2013-06-08 Foldes: Added sss_trans ModDepth
% 2013-07-18 Foldes: Added Power_*
% 2013-08-19 Foldes: clean
% 2014-03-25 

classdef ResultPointers_Class
    properties
        
        % Pointers
        %         prebadchan = char([]);
        %         processed_data_for_events = char([]);
        %         Events = char([]);
        %         SSP = char([]);
        %
        % Results Pointers
        %         Power_sss_trans_Cue = char([]);
        %         Power_tsss_trans_Cue = char([]);
        %         Power_tsss_trans_Cue_o30 = char([]);
        %         Power_tsss_trans_Cue_burg = char([]);
        
        %         Power_tsss_Cue = char([]);
        
        SensorModDepth_tsss_Cue = char([]);
        SourceModDepth_tsss_Cue = char([]);

        
        %         ModDepth_sss_EMG = char([]);
        %         ModDepth_sss_trans_EMG = char([]);
        %         ModDepth_tsss_EMG = char([]);
        
        
        %         Pointer_ModDepth_sss_EMG = char([]);
        %         Pointer_ModDepth_sss_pport = char([]);
        %         Pointer_ModDepth_sss_EMGorAcc = char([]);
        %         Pointer_ModDepth_tsss_EMG = char([]);
        %         Pointer_ModDepth_tsss_pport = char([]);
        %         Pointer_ModDepth_tsss_EMGorAcc = char([]);
        %         ModDepth_sss_trans_Cue = char([]);
        %         Pointer_ModDepth_sss_trans_EMG = char([]);
        %         Pointer_ModDepth_sss_trans_pport = char([]);
        %         Pointer_ModDepth_sss_trans_EMGorAcc = char([]);
        %         Pointer_ModDepth_tsss_trans_EMG = char([]);
        %         Pointer_ModDepth_tsss_trans_pport = char([]);
        %         Pointer_ModDepth_tsss_trans_EMGorAcc = char([]);
        %
        
        
        % You can do this, but then writing and reading the data from standard-txt file is tough
        %         Pointers=struct(...
        %             'prebadchan',                   char([]),...
        %             'processed_data_for_events',    char([]),...
        %             'Events',                       char([]),...
        %             'SSP',                          char([]) );
        
        
    end
    
    properties (SetAccess = protected)
        
    end % properties - protected
    
    methods
        % CONSTRUCTOR
        %         function obj = Metadata(x)
        %         end
        %
        %         %% Populate Metadata with
        %         function obj = Metadata_Populate
        
        function [x] = isfield(obj,input_field)
            % isfield for objects
            % Needed for tools that will work for both structs AND objects
            % 2013-08-22 Foldes
            x = isprop(obj,input_field);
        end % isfield
    end
    
    
    
end