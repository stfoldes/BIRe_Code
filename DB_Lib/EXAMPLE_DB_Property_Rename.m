% Renaming properties in Metadatabase
%
% To delete, just remove property from classdef (Metadata_Class.m) 
%   and load Metadata from txt, then write it back to txt
%
% Foldes 2013-03-06

%% ===STEP 1===
    % Add new property name to classdef (Metadata_Class.m)

%% ===STEP 2===
% Run this 1st chunk of code below
    clear

    %------------------
    property_name = 'Events';
    old_property_name = ['Pointer_' property_name];
    new_property_name = ['Preproc.Pointer_' property_name];
    
%     old_property_name = 'Pointer_prebadchan';
%     new_property_name = 'Preproc.prebadchan';

    %-------------------

    
    %---USER INFO---
    local_base_path = '/home/foldes/Data/MEG/';
    server_base_path = '/home/foldes/Desktop/Katz/experiments/meg_neurofeedback/';
    %local_base_path = 'C:\Data\MEG\';
    % server_base_path = '\\192.168.1.4\data\experiments\meg_neurofeedback\';
    % server_base_path = local_base_path;

    metadatabase_location=[server_base_path filesep 'Neurofeedback_metadatabase.txt'];
    %---END USER INFO---

    % Load Metadata from text file
    Metadata = Metadata_Class();
    Metadata = Load_StandardStruct_from_TXT(Metadata,metadatabase_location);


    
    for i=1:length(Metadata)
        eval(['Metadata(i).' new_property_name ' = Metadata(i).' old_property_name ';'])
    end

    % Check
    [~,completed_idx_list_OLD]=Metadata_Report_Property_Check(Metadata,old_property_name);
    [~,completed_idx_list_NEW]=Metadata_Report_Property_Check(Metadata,new_property_name);
    
    completed_idx_list_OLD==completed_idx_list_NEW

    % Save current metadata entry back to database
    Metadata_Write_to_TXT(Metadata,metadatabase_location);

%% ===STEP 3===
    % Remove old property name to classdef (Metadata_Class.m)

%% ===DONE===

%% =========================================================================================

