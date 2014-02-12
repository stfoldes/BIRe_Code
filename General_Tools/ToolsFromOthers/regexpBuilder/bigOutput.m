function varargout = bigOutput(varargin)
% BIGOUTPUT MATLAB code for bigOutput.fig
%      BIGOUTPUT, by itself, creates a new BIGOUTPUT or raises the existing
%      singleton*.
%
%      H = BIGOUTPUT returns the handle to a new BIGOUTPUT or the handle to
%      the existing singleton*.
%
%      BIGOUTPUT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in BIGOUTPUT.M with the given input arguments.
%
%      BIGOUTPUT('Property','Value',...) creates a new BIGOUTPUT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before bigOutput_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to bigOutput_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help bigOutput

% Last Modified by GUIDE v2.5 13-May-2013 16:53:38

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @bigOutput_OpeningFcn, ...
                   'gui_OutputFcn',  @bigOutput_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before bigOutput is made visible.
function bigOutput_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to bigOutput (see VARARGIN)

% Choose default command line output for bigOutput
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes bigOutput wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = bigOutput_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;



function output_text_Callback(hObject, eventdata, handles)
% hObject    handle to output_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of output_text as text
%        str2double(get(hObject,'String')) returns contents of output_text as a double


% --- Executes during object creation, after setting all properties.
function output_text_CreateFcn(hObject, eventdata, handles)
% hObject    handle to output_text (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
