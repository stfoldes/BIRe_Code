% Class to hold info and pointers to pre processing information
% Designed to be used with Metadata_Class
%
% 2013-04-24 Foldes
% UPDATES
% 2013-07-11 Foldes: Added Rx times
% 2013-08-12 Foldes: Changed
% 2013-08-22 Foldes: datatype_ moved to here, hidden

classdef PreprocInfo_Class
    properties
        
        
        % Basics
        %         emg_chan = double([]);
        %         photodiode_chan = double([]);
        %         accerometer_chan = double([]);
        %         headmovement_amount = double([]);
        head_center = double([]);
        chpi_flag = double([]);
        Rx_photodiode_from_move_cue = double([]);
        Rx_EMG_from_move_cue = double([]);
        Rx_ACC_from_move_cue = double([]);
        bad_chan_list = double([]);  % Order Numbering, not Neuromag DSP number (like it is in prebad)
        sensorimotor_chan_quality = double([]); % Portion of good sensors (grad only) in sensorimotor area (DEF_sensorimotor)
        %data_quality = double(1); % 0-1 bad to good [default of good]
        data_usable = double(1); % 0 = not usable or 1 = usable [default of good]

        % Pointers
        Pointer_prebadchan = char([]);
        Pointer_processed_data_for_events = char([]);
        Pointer_Events = char([]);
        Pointer_SSP = char([]);

        % You can do this, but then writing and reading the data from standard-txt file is tough
        %         Pointers=struct(...
        %             'prebadcha        %         bad_chan_list_timestamp = char([]);n',                   char([]),...
        %             'processed_data_for_events',    char([]),...
        %             'Events',                       char([]),...
        %             'SSP',                          char([]) );
        
        
    end
    
    properties (Hidden)
        % Data Types (type 'logical' is hard to work with)
        datatype_fif = double(0);
        datatype_sss = double(0);
        datatype_sss_trans = double(0);
        datatype_tsss = double(0);
        datatype_tsss_trans = double(0);
        datatype_crx = double(0);
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