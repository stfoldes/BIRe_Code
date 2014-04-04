
% AnalysisParms=Prep_AnalysisParms(AnalysisParms,Extract,ExpDefs)
% Stephen Foldes (2012-01-31)
%
% Used to automatically populate the parameters for doing the analysis struct ("AnalysisParms")
% This Prep_ is not as automatic as others b/c it assumes you know something about the analysis that will be done
%
% AnalysisParms.Event_PSD.event_type
% AnalysisParms.channel_list

function AnalysisParms=Prep_AnalysisParms(AnalysisParms,Extract,ExpDefs,FeatureParms)



%% "Super" required

% NOTHING IS SUPER REQUIRED B/C THE ANALYSIS IS "FREE FORM"
%
% if ~exist('AnalysisParms')
%     AnalysisParms=[];
% end
% if ~isfield(AnalysisParms,'paradigm_type') || isempty(AnalysisParms.paradigm_type)
%     AnalysisParms.paradigm_type= input('Input paradigm type (e.g. Open Loop MEG): ');
% end

    if ~isfield(Extract,'channel_list') || isempty(Extract.channel_list)
       	disp('Extract.channel_list needed (@Prep_AnalysisParms)')% 03-06-2012
    end
            
    for ichannel = 1:length(AnalysisParms.Event_PSD.channel_list)
        channel_valid_check(ichannel)=max(AnalysisParms.Event_PSD.channel_list(ichannel)==Extract.channel_list);
    end
    
    if min(channel_valid_check)==0 % Some of the channels are not valid, get new ones
        AnalysisParms.Event_PSD.channel_list = input('Enter valid channel list to look at(@Prep_AnalysisParms): ');
    end
        

%%
    AnalysisParms.Event_PSD.event_target_code=[];
    for itarg=1:size(AnalysisParms.Event_PSD.event_type,2)
        eval(['AnalysisParms.Event_PSD.event_target_code(itarg) = ExpDefs.target_code.' AnalysisParms.Event_PSD.event_type{itarg} ';'])
    end
    eval(['AnalysisParms.Event_PSD.baseline_target_code = ExpDefs.target_code.' AnalysisParms.Event_PSD.baseline_type ';'])
  
%     % populate the index that links the desired channels to plot to the list that was extracted (it better be there)
%     AnalysisParms.channel_idx=[];
%     for ichannel=1:length(AnalysisParms.channel_list)
%         AnalysisParms.channel_idx(ichannel) = find(Extract.channel_list==AnalysisParms.channel_list(ichannel)); % channels to use in analysis (related to whole MEG numbering)
%         if isempty(AnalysisParms.channel_idx(ichannel))
%             warning('Crap, you picked a channel that wasnt extracted @AnalysisParms.channel_idx')
%         end
%     end    

%         AnalysisParms.freq_idx = [find(FeatureParms.actual_freqs>=AnalysisParms.freq_range(:,1),1,'first'):find(FeatureParms.actual_freqs<=AnalysisParms.freq_range(:,2),1,'last')];
%         AnalysisParms.actual_freqs=FeatureParms.actual_freqs(AnalysisParms.freq_idx); % what freqs are actually used
    
    
    if isfield(AnalysisParms.Mod_Depth,'ideal_freq_range') && ~isempty(AnalysisParms.Mod_Depth.ideal_freq_range)       
        for ifreq_set=1:size(AnalysisParms.Mod_Depth.ideal_freq_range,1)
            AnalysisParms.Mod_Depth.freq_idx{ifreq_set} = [find(FeatureParms.actual_freqs>=AnalysisParms.Mod_Depth.ideal_freq_range(ifreq_set,1),1,'first'):find(FeatureParms.actual_freqs<=AnalysisParms.Mod_Depth.ideal_freq_range(ifreq_set,2),1,'last')];
            AnalysisParms.Mod_Depth.actual_freqs{ifreq_set}=FeatureParms.actual_freqs(AnalysisParms.Mod_Depth.freq_idx{ifreq_set}); % what freqs are actually used
        end
    end
    
    try
        AnalysisParms.Event_PSD.pre_event_time=round(AnalysisParms.Event_PSD.pre_event_timeS*FeatureParms.timeS_to_feature_sample);
        AnalysisParms.Event_PSD.post_event_time=round(AnalysisParms.Event_PSD.post_event_timeS*FeatureParms.timeS_to_feature_sample);
    end
    
    % populate the index that links the desired channels to plot to the list that was extracted (it better be there)
    AnalysisParms.Event_PSD.channel_idx=[];
    for ichannel=1:length(AnalysisParms.Event_PSD.channel_list)
        try
            AnalysisParms.Event_PSD.channel_idx(ichannel) = find(Extract.channel_list==AnalysisParms.Event_PSD.channel_list(ichannel)); % channels to use in analysis (related to whole MEG numbering)
            if isempty(AnalysisParms.Event_PSD.channel_idx(ichannel))
                warning('Crap, you picked a channel that wasnt extracted @AnalysisParms.Event_PSD.channel_idx')
            end
        catch
            warning('Crap, you picked a channel that wasnt extracted @AnalysisParms.Event_PSD.channel_idx')
        end
    end    
    
    
