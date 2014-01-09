% Feature Parameter Class
% Parameters for feature analysis like MEM and FFT
%
% For MEM, see Prep_MEM_parms.m
%
% Replaces the super fancy Prep_FeatureParms.m :o(
%
%
% 2013-06-26 Foldes
% UPDATES
% 2013-07-09 Foldes: .freq_bins + 1
% 2013-07-25 Foldes: MEM parameters added (as hidden) and setting MEM parameters added
% 2013-10-24 Foldes: small update

classdef FeatureParms_Class
    properties
        
        % Method Info
        feature_method = char([]);
        order = double(-1);
        nfft = double(-1);
        
        % Feature Info
        ideal_freqs = double(-1); % zero is valid
        actual_freqs = double(-1);
        freq_bins = double(-1);
        feature_resolution = double(-1);
        
        % Timing Info
        sample_rate = double(-1);
        window_lengthS = double(-1);
        actual_window_lengthS = double(-1);
        window_length = double(-1);
        feature_update_rateS = double(-1);
        actual_feature_update_rateS = double(-1);
        feature_update_rate = double(-1);
        timeS_to_feature_sample = double(-1);
        
    end
    
    
    properties (Hidden)
        
        % FOR MEM
        MEM_firstBinCenter = double(-1);
        MEM_lastBinCenter = double(-1);
        MEM_NumOfEvaluation = double(-1);
        MEM_Trend = double(-1);
    end
    
%%    
    methods
        function obj = Prep_FeatureParms(obj)
        % Prepared the class for use. Must have basic info
        
            % Make sure you have the basics; set defaults
            if strcmp(obj.feature_method, char([]))
                obj.feature_method = 'MEM';
                warning('@FeatureParms.feature_method: Setting to default = MEM');
            end
            if obj.sample_rate == -1
                obj.sample_rate = 1000;
                warning('@FeatureParms.sample_rate: Setting to default = 1000');
            end
            if obj.ideal_freqs(1) == -1 && obj.freq_bins(1) == -1 % can just use freq_bins straight up
                obj.ideal_freqs = [0:200];
                warning('@FeatureParms.ideal_freqs: Setting to default = [0:200]');
            end
            if obj.window_lengthS == -1 && obj.window_length == -1
                obj.window_lengthS = 1;
                warning('@FeatureParms.window_lengthS: Setting to default = 1');
            end
            
            % ---Conversition---
            % Turn nfft into resolution (***nfft trumps resolution***)
            if obj.nfft ~= -1
                obj.feature_resolution=obj.sample_rate/obj.nfft;
            end
            % no nfft or res, then set default
            if obj.feature_resolution == -1 && obj.nfft == -1
                obj.feature_resolution = 1;
                warning('@FeatureParms.feature_resolution: Setting to default = 1');
            end
            
            % Bin indicies based on ideal
            if obj.freq_bins(1) == -1
                obj.freq_bins = unique(round(obj.ideal_freqs/obj.feature_resolution))+1; % 2013-07-09 Foldes +1
            end
            obj.actual_freqs = obj.feature_resolution*(obj.freq_bins-1); % SHOULD BE SET IN CALC_FEATURE
            
            % ---Convert Time---
            obj.window_length=floor(obj.window_lengthS*obj.sample_rate);
            obj.actual_window_lengthS=obj.window_length/obj.sample_rate;
            if obj.feature_update_rateS~=-1
                obj.feature_update_rate=floor(obj.feature_update_rateS*obj.sample_rate);
                obj.actual_feature_update_rateS=obj.feature_update_rate/obj.sample_rate;
                obj.timeS_to_feature_sample=1/(obj.feature_update_rate/obj.sample_rate); % used to turn time in seconds to feature-samples (e.g. time = floor(timeS * obj.timeS_to_feature_sample); )
            end
            
            %% Method Specific Parameters
            
            % MEM
            switch lower(obj.feature_method)
                case {'mm'}
                    obj = Prep_MEM_parms(obj);
                    
                case {'fft','welch'}
                    if obj.nfft == -1
                        obj.nfft = obj.sample_rate/obj.feature_resolution;
                        warning(['@FeatureParms.nfft: Setting to default = ' num2str(obj.nfft) ]);
                    end
                    
                case {'burg'}
                    if obj.order == -1
                        obj.order = 30;
                        warning(['@FeatureParms.order: Setting to default = ' num2str(obj.order) ]);
                    end
            end
            
            
        end % END Prep_FeatureParms
        
        % Calculate the features
        [feature_data,obj] = Calc_Features(obj,current_raw_data);
        
            
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