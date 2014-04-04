% Class Definition for Functional Evaluation
%
% 2013-06-28 Randazzo & Foldes
% Updates: 
% 2013-08 Randazzo: added more basic info
% 2013-08-08 Foldes: added subject_type
% 2013-09-30 Foldes: Added Injury Age and sensory levels

classdef Function_Screening_Class
    
    properties
        % Basic Info
        subject = '';
        date = '';
        session = '';
        OT='';
        subject_type='';
        Age='';
        Gender='';
        Veteran='';
        Ethnic='';
        Height='';
        Weight='';
        Injury_Duration='';
        Injury_Age = '';
        
        % Functional Screening Numbers
        
        % Finger Flex
        Finger_Flex_LT_MMT = '';
        Finger_Flex_RT_MMT = '';
        Finger_Flex_RT_Strength = '';
        Finger_Flex_LT_Strength = '';
        Finger_Flex_RT_ROM = '';
        Finger_Flex_LT_ROM = '';
        
        %Finger Ext
        Finger_Ext_LT_MMT = '';
        Finger_Ext_RT_MMT = '';
        Finger_Ext_RT_Strength = '';
        Finger_Ext_LT_Strength = '';
        Finger_Ext_RT_ROM = '';
        Finger_Ext_LT_ROM = '';
        
        % Wrist Flex
        Wrist_Flex_LT_MMT = '';
        Wrist_Flex_RT_MMT = '';
        Wrist_Flex_RT_Strength = '';
        Wrist_Flex_LT_Strength = '';
        Wrist_Flex_RT_ROM = '';
        Wrist_Flex_LT_ROM = '';
       
        % Wrist Ext
        Wrist_Ext_LT_MMT = '';
        Wrist_Ext_RT_MMT = '';       
        Wrist_Ext_RT_Strength = '';
        Wrist_Ext_LT_Strength = '';
        Wrist_Ext_RT_ROM = '';
        Wrist_Ext_LT_ROM = '';
        
        % Elbow Flex
        Elbow_Flex_LT_MMT = '';
        Elbow_Flex_RT_MMT = '';
        Elbow_Flex_RT_Strength = '';
        Elbow_Flex_LT_Strength = '';
        Elbow_Flex_RT_ROM = '';
        Elbow_Flex_LT_ROM = '';
        
        % Elbow Ext
        Elbow_Ext_LT_MMT = '';
        Elbow_Ext_RT_MMT = '';
        
        Elbow_Ext_RT_Strength = '';
        
        Elbow_Ext_LT_Strength = '';
        Elbow_Ext_RT_ROM = '';
        Elbow_Ext_LT_ROM = '';
       
        % Grip 
        Grip_RT_Strength = '';
        Grip_LT_Strength = '';
        
        % Notes
        Notes = '';
        
        % KVIQ
        Dominant_Hand = '';
        Visual_Shoulder_Flex ='';
        Visual_Thumb_Finger =''
        Visual_Trunk_Flex='';
        Visual_Hip_Abduction='';
        Visual_Foot_Tapping='';
        
        Kinesthetic_Shoulder_Flex ='';
        Kinesthetic_Thumb_Finger =''
        Kinesthetic_Trunk_Flex ='';
        Kinesthetic_Hip_Abduction ='';
        Kinesthetic_Foot_Tapping ='';
        
        Kinesthetic_total = 0;
        Visual_total = 0;
        KVIQ_total = 0;
        
        % Level of Impairment
        Injury_Level = '';
        ASIA = '';
        SensoryHand_RT = NaN;
        SensoryHand_LT = NaN;
        
        
    end % properties
    
    properties (Hidden)
         % Finger Flex
        Finger_Flex_RT_Strength_1 = '';
        Finger_Flex_RT_Strength_2 = '';
        Finger_Flex_RT_Strength_3 = '';
        Finger_Flex_LT_Strength_1 = '';
        Finger_Flex_LT_Strength_2 = '';
        Finger_Flex_LT_Strength_3 = '';
        
        %Finger Ext
        
        Finger_Ext_RT_Strength_1 = '';
        Finger_Ext_RT_Strength_2 = '';
        Finger_Ext_RT_Strength_3 = '';
       
        Finger_Ext_LT_Strength_1 = '';
        Finger_Ext_LT_Strength_2 = '';
        Finger_Ext_LT_Strength_3 = '';
        
        
        % Wrist Flex

        Wrist_Flex_RT_Strength_1 = '';
        Wrist_Flex_RT_Strength_2 = '';
        Wrist_Flex_RT_Strength_3 = '';
       
        Wrist_Flex_LT_Strength_1 = '';
        Wrist_Flex_LT_Strength_2 = '';
        Wrist_Flex_LT_Strength_3 = '';

       
        % Wrist Ext
       
        Wrist_Ext_RT_Strength_1 = '';
        Wrist_Ext_RT_Strength_2 = '';
        Wrist_Ext_RT_Strength_3 = '';
       
        Wrist_Ext_LT_Strength_1 = '';
        Wrist_Ext_LT_Strength_2 = '';
        Wrist_Ext_LT_Strength_3 = '';
        
        
        % Elbow Flex
        
        Elbow_Flex_RT_Strength_1 = '';
        Elbow_Flex_RT_Strength_2 = '';
        Elbow_Flex_RT_Strength_3 = '';
       
        Elbow_Flex_LT_Strength_1 = '';
        Elbow_Flex_LT_Strength_2 = '';
        Elbow_Flex_LT_Strength_3 = '';
        
        % Elbow Ext
       
        Elbow_Ext_RT_Strength_1 = '';
        Elbow_Ext_RT_Strength_2 = '';
        Elbow_Ext_RT_Strength_3 = '';
        
        Elbow_Ext_LT_Strength_1 = '';
        Elbow_Ext_LT_Strength_2 = '';
        Elbow_Ext_LT_Strength_3 = '';
       
       
        % Grip 
        Grip_RT_Strength_1 = '';
        Grip_RT_Strength_2 = '';
        Grip_RT_Strength_3 = '';
       
        Grip_LT_Strength_1 = '';
        Grip_LT_Strength_2 = '';
        Grip_LT_Strength_3 = '';
       
        % Sensory Ability
        Light_Touch_RT_C6 = '';
        Light_Touch_RT_C7 = '';
        Light_Touch_RT_C8 = '';
        Light_Touch_LT_C6 = '';
        Light_Touch_LT_C7 = '';
        Light_Touch_LT_C8 = '';
        Pin_Prick_RT_C6 = '';
        Pin_Prick_RT_C7 = '';
        Pin_Prick_RT_C8 = '';
        Pin_Prick_LT_C6 = '';
        Pin_Prick_LT_C7 = '';
        Pin_Prick_LT_C8 = '';
    end
    
    methods
        
        function [x] = isfield(obj,input_field)
            % isfield for objects
            % Needed for tools that will work for both structs AND objects
            % 2013-08-22 Foldes
            x = isprop(obj,input_field);
        end % isfield
    end
    

end
    