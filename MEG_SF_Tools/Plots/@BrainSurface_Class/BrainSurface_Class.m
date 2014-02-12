% Brain Surface Class
%
%
% 2014-01-27 Foldes
% UPDATES
% 2014-02-06 Foldes: still developing

classdef BrainSurface_Class
    properties
        
        fig =           []; % handel for figure
        ax =            []; % handel for axis
        hPatch =        []; % handel for the surface
        
        subject =       [];
        task_name =   	[];
        underlay_file = [];

        % For the 3D plot
        Faces =         []; % [~(2*nverticies) x 3]
        Vertices =      []; % [nverticies x 3]
        VerticesColor = [];
        
        
        % Overlay
        nOverlays =     0;        
        
        % From SurfaceFile (SurfaceFile = BST_Load_File(Extract,'surface');)
        Comment =           [];
        VertConn =          [];
        VertNormals =       [];
        Curvature =         [];
        SulciMap =          []; % mask of each vertex if it is a sulci <--- NOT IMPLEMENTED YET
        tess2mri_interp =   [];
        tess2tess_interp =  [];
        Reg =               [];
        History =           [];
        Atlas =             [];
        iAtlas =            [];        
        
        % Method Info
        
    end
    
    
    properties (Hidden)
        
        % History?
        
    end
    
    %%
    methods
%         function obj = BrainSurface_Class(SurfaceFile)
%             if ~exist('SurfaceFile')
%                 
%                return 
%             end
%             
%             field_list = fieldnames(SurfaceFile);
%             for ifield = 1:length(field_list)
%                 current_field_name = field_list{ifield};
%                 obj.(field_list)
%                 copy_fields
%             
% %             copy_object_properties(SurfaceFile,obj);
%         end
            
        % Plot the Underlay (just the brain)
        obj = Plot_Underlay(obj,varargin);
        
        % Plot Overlays (activity)
        obj = Plot_Overlay(obj,NewOverlay,varargin);
        
        % Genaric plotter of a surface
        obj = Update_Surf(obj,parms);
                
        function [x] = isfield(obj,input_field)
            % isfield for objects
            % Needed for tools that will work for both structs AND objects
            % 2013-08-22 Foldes
            x = isprop(obj,input_field);
        end % isfield
        
        
        
    end
end