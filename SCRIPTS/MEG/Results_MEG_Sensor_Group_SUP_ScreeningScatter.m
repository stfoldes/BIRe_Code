%% Grip vs. Hand Screening
clear indep_field dep_field_list
indep_field = 'Screening.Grip_RT_Strength';
dep_label = {'Finger_Flex_RT_Strength',...
    'Finger_Flex_RT_MMT',...
    'Finger_Flex_RT_ROM',...
    'SensoryHand_RT'};
% Make dep_field_list from labels
for ilabel= 1:length(dep_label)
    eval(['dep_field_list{ilabel} = ''Screening.' dep_label{ilabel} ''';']);
end

fig=figure;hold all
Figure_Stretch(2.5)
for iplot=1:length(dep_field_list)
    subplot(1,4,iplot);hold all
    %Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list{iplot},'subject_type','fit_line','group','dep_label',dep_label{iplot},'fig',fig)
    %Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list{iplot},'subject_type','fit_line','cat','dep_label',dep_label{iplot},'fig',fig)
    Plot_Scatter_wStruct(GroupResults_SCI,indep_field,dep_field_list{iplot},'subject_type',...
        'fit_line','cat','dep_label',dep_label{iplot},'fig',fig,'marker_field','subject')
end
Figure_Position(0)

%% Grip vs. Other Strengths (RIGHT)
clear indep_field dep_field_list
indep_field = 'Screening.Grip_RT_Strength';
dep_label = {'Finger_Flex_RT',...
    'Wrist_Flex_RT'...
    'Wrist_Ext_RT'...
    'Elbow_Flex_RT'...
    'Elbow_Ext_RT'};
% Make dep_field_list from labels
for ilabel= 1:length(dep_label)
    eval(['dep_field_list{ilabel} = ''Screening.' dep_label{ilabel} '_Strength'';']);
end

fig=figure;hold all
Figure_Stretch(2,2)
for iplot=1:length(dep_field_list)
    subplot(2,3,iplot);hold all
    Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list{iplot},'subject_type','fit_line','group','dep_label',dep_label{iplot},'fig',fig)
end


title_figure(['Strength'])
Figure_Position(0)


%% Grip vs. Hand Screening
clear indep_field dep_field_list
indep_field = 'Screening.Age';
dep_label = {'Grip_RT_Strength'};
% Make dep_field_list from labels
for ilabel= 1:length(dep_label)
    eval(['dep_field_list{ilabel} = ''Screening.' dep_label{ilabel} ''';']);
end

fig=figure;hold all
subplot(1,2,1);hold all
    Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list,'subject_type','fit_line','group','dep_label',dep_label,'fig',fig)
subplot(1,2,2);hold all
    Plot_Scatter_wStruct(GroupResults_ALL,indep_field,dep_field_list,'Screening.Gender','fit_line','group','dep_label',dep_label,'fig',fig)

Figure_Stretch(2)
Figure_Position(0)
