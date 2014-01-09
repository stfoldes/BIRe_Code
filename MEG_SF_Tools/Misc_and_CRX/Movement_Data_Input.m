%%
%
% PURPOSE: Provides an input GUI for Movement Data and writes the data to
% SCI_Movement_Data_SF
%
%
% UPDATED: Randazzo 2012-10-15
%
%
%
%
%
%%

clc, clear 

movement_file = 'C:\Users\hrnel\Dropbox\SF_Toolbox\meg_analysis\SCI_movement_Info_SF.m';

%Breaking the metadata file into is components
[movement_file_path movement_file_base movement_file_ext]=fileparts(movement_file);

%Saving the back-up file
copyfile(movement_file,[movement_file_path filesep movement_file_base '_previous.m'],'f');

%Opens the Metadata text doucment for writing
data_file = fopen(movement_file,'a+');

%%

%Setting the Window options
options.Resize = 'on';
options.WindowStyle = 'normal';

%GUI for data input
inputGUI_title = 'Input System for Movement Data';
inputGUI_prompt = {'Enter the Subject [NS02]:','Enter the Session [Baseline/S2_Pre]','Enter Average Finger Flex Strength','Enter Average Finger Flex Range of Motion:','Enter Average Finger Extension Strength','Enter Average Finger Flex Range of Motion:','Enter Average Wrist Flex Strength:','Enter Average Wrist Flex Range of Motion:','Enter Average Wrist Extension Strength:','Enter Average Wrist Extension Range of Motion:','Enter Average Elbox Flex Strength','Enter Average Elbox Flex Range of Motion','Enter Average Elbox Extension Strength','Enter Average Elbow Extension Range of Motion','Enter Average Grip Strength'};
number_lines = 1;
default_answers = {'NS01','Baseline','0.0','0.0','0.0','0.0','0.0','0.0','0.0','0.0','0.0','0.0','0.0','0.0','0.0'};
movement_input = inputdlg(inputGUI_prompt,inputGUI_title,number_lines,default_answers,options);

% Writing answers to Movement Info database
fprintf(data_file,'\n%%%% \n');
fprintf(data_file,'%% %s %s \n',movement_input{1},movement_input{2});

%Finding the inputs that are entered
j=1;
irun = 0;
for ifindinputs = 3:15
   if length(movement_input{ifindinputs}) ~= 0;
      irun(j) = ifindinputs;
      j = j+1;
   end
end

%Adds only the input data
for itimes = 1 : length(irun)
switch irun(itimes)
    case 3
%Adding data to the structure
movement_input{3} = str2num(movement_input{3});
fprintf(data_file,'Movement_info.%s.%s.Finger_Flex.Strength = %d ;\n',movement_input{1},movement_input{2},movement_input{3});
    case 4
movement_input{4} = str2num(movement_input{4});
fprintf(data_file,'Movement_info.%s.%s.Finger_Flex.ROM = %d ;\n',movement_input{1},movement_input{2},movement_input{4});
    case 5
movement_input{5} = str2num(movement_input{5});
fprintf(data_file,'Movement_info.%s.%s.Finger_Ext.Strength = %d ;\n',movement_input{1},movement_input{2},movement_input{5});
    case 6
movement_input{6} = str2num(movement_input{6});
fprintf(data_file,'Movement_info.%s.%s.Finger_Ext.ROM = %d ;\n',movement_input{1},movement_input{2},movement_input{6});
    case 7
movement_input{7} = str2num(movement_input{7});
fprintf(data_file,'Movement_info.%s.%s.Wrist_Flex.Strength = %d ;\n',movement_input{1},movement_input{2},movement_input{7});
    case 8
movement_input{8} = str2num(movement_input{8});
fprintf(data_file,'Movement_info.%s.%s.Wrist_Flex.ROM = %d ;\n',movement_input{1},movement_input{2},movement_input{8});
    case 9
movement_input{9} = str2num(movement_input{9});
fprintf(data_file,'Movement_info.%s.%s.Wrist_Ext.Strength = %d ;\n',movement_input{1},movement_input{2},movement_input{9});
    case 10
movement_input{10} = str2num(movement_input{10});
fprintf(data_file,'Movement_info.%s.%s.Wrist_Ext.ROM = %d ;\n',movement_input{1},movement_input{2},movement_input{10});
    case 11
movement_input{11} = str2num(movement_input{11});
fprintf(data_file,'Movement_info.%s.%s.Elbow_Flex.Strength = %d ;\n',movement_input{1},movement_input{2},movement_input{11});
    case 12
movement_input{12} = str2num(movement_input{12});
fprintf(data_file,'Movement_info.%s.%s.Elbow_Flex.ROM = %d ;\n',movement_input{1},movement_input{2},movement_input{12});
    case 13
movement_input{13} = str2num(movement_input{13});
fprintf(data_file,'Movement_info.%s.%s.Elbow_Ext.Strength = %d ;\n',movement_input{1},movement_input{2},movement_input{13});
    case 14
movement_input{14} = str2num(movement_input{14});
fprintf(data_file,'Movement_info.%s.%s.Elbow_Ext.ROM = %d ;\n',movement_input{1},movement_input{2},movement_input{14});
    case 15
movement_input{15} = str2num(movement_input{15});
fprintf(data_file,'Movement_info.%s.%s.Grip.Strength = %d ;\n',movement_input{1},movement_input{2},movement_input{15});

end
end
fclose(data_file);