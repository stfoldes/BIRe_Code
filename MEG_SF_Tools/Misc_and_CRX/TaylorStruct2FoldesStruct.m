
function [feature_data,FeatureVecs,FeatureParms,Decoder,channel_list]=TaylorStruct2FoldesStruct(Extract)


%%
FeatureVecs=[];
feature_data = [];
% raw_feature_data = [];

for ifile=1:size(Extract.file_name,2)
    
    CursorFileFullName = [Extract.file_path Extract.file_name{ifile} '.cursor'];
    ParameterFileName = [CursorFileFullName(1:length(CursorFileFullName)-7) 'params\ParametersFinal.mat'];
    disp(['Opening File: ' CursorFileFullName])
    
    [Cursor,VR,Parameters,data_normalized] = LoadCursorFile(CursorFileFullName,ParameterFileName);
    % Plot_all_children(Cursor)
    % tilefigs
    
    FeatureParms.spatial_filter = Parameters.SigProc.ReRefMat;
    FeatureParms.freq_bins=Parameters.SigProc.freq_bin;
    FeatureParms.sample_rate=Parameters.SigProc.sample_rate;
    FeatureParms.actual_freqs=Parameters.SigProc.FreqBinsVals;
    FeatureParms.actual_feature_update_rateS=Parameters.timing.loop_intervalS;
    FeatureParms.actual_window_lengthS=Parameters.decode.fft_size/Parameters.SigProc.sample_rate;
    
    Decoder.OLE_weights=squeeze(Parameters.Parameters.Wp(:,:,1));
    Decoder.spatial_filter =Parameters.SigProc.ReRefMat;
    
    %% Get data for this file
    
    FeatureVecs_file.target_pos = Cursor.target_position;
    FeatureVecs_file.cursor_pos = Cursor.cursor_position;
    FeatureVecs_file.target_code = Cursor.targetNums;
    FeatureVecs_file.condition_code = Cursor.UseDAS;
    
    % data_normalized = (time x freqband*channel)  [Channel#1Freq#1,Channel#1Freq#2,Channel#1Freq#3, ...,Channel#2Freq#1,Channel#2Freq#2,...]
    temp = reshape(data_normalized,size(data_normalized,1),length(FeatureParms.freq_bins),[]); % [time x feature x channel]
    feature_data_file = permute(temp,[1 3 2]);
    % feature_data = [time x channel x feature]
    

    
%     % Use the spatial filter to turn data back into channel-wise features
%     % data.raw_current*SigProc.ReRefMat
%     % source = raw*ReRefMat
%     % source*ReRefMat' = raw
%     for ifeature = 1:size(feature_data_file,3)
%         raw_feature_data_file(:,:,ifeature) = squeeze(feature_data_file(:,:,ifeature))*pinv(Parameters.SigProc.ReRefMat);
%     end
    
    
    %% Need to concatinate data
    
    
    
%     FeatureVecs_file.target_pos(end,:) = zeros(size(FeatureVecs_file.target_pos(end,:)));
%     FeatureVecs_file.cursor_pos(end,:) = zeros(size(FeatureVecs_file.cursor_pos(end,:)));
%     FeatureVecs_file.target_code(end,:) = zeros(size(FeatureVecs_file.target_code(end,:)));
%     FeatureVecs_file.condition_code(end,:) = zeros(size(FeatureVecs_file.condition_code(end,:)));
    
    
    
    
    feature_data = cat(1,feature_data,feature_data_file);
%     raw_feature_data = cat(1,raw_feature_data,raw_feature_data_file);
    
    % Need to cleaver about concatinating timing
    if isfield(FeatureVecs,'timeS')
        FeatureVecs_file.timeS=Cursor.timingnow-min(Cursor.timingnow)+max(FeatureVecs.timeS)+mean(diff(Cursor.timingnow-min(Cursor.timingnow))); %mean(diff(Cursor.timingnow-min(Cursor.timingnow))) is needed to have a small increment
    else
        FeatureVecs_file.timeS=Cursor.timingnow-min(Cursor.timingnow);
    end
    
    FeatureVecs = catstructs(FeatureVecs,FeatureVecs_file);
    
    clear FeatureVecs_file feature_data_file %raw_feature_data_file
    
end % file loop


%%
% figure;
% clf
% hold all
% plot(moving_avg(squeeze(mean(feature_data(:,32,:),3)),10),'k')
% plot(moving_avg(squeeze(mean(feature_data(:,end,:),3)),10),'Color',0.6*[1 1 1])
% plot(FeatureVecs.target_pos(:,1),'r','LineWidth',2)
% plot(FeatureVecs.target_pos(:,2),'g','LineWidth',2)
% ylim([-2 2])

channel_list = 1:size(feature_data,2);


%% END FUNCTION







