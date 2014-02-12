function varargout = evaluateOptions(varargin)
% EVALUATEOPTIONS MATLAB code for evaluateOptions.fig
%      EVALUATEOPTIONS, by itself, creates a new EVALUATEOPTIONS or raises the existing
%      singleton*.
%
%      H = EVALUATEOPTIONS returns the handle to a new EVALUATEOPTIONS or the handle to
%      the existing singleton*.
%
%      EVALUATEOPTIONS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in EVALUATEOPTIONS.M with the given input arguments.
%
%      EVALUATEOPTIONS('Property','Value',...) creates a new EVALUATEOPTIONS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before evaluateOptions_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to evaluateOptions_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help evaluateOptions

% Last Modified by GUIDE v2.5 29-Jul-2013 15:16:20

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @evaluateOptions_OpeningFcn, ...
                   'gui_OutputFcn',  @evaluateOptions_OutputFcn, ...
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


% --- Executes just before evaluateOptions is made visible.
function evaluateOptions_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to evaluateOptions (see VARARGIN)

% Choose default command line output for evaluateOptions
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);
% UIWAIT makes evaluateOptions wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = evaluateOptions_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;
fname = fullfile(fileparts(which('regexpBuilder')),'print_defaults.mat');
if exist(fname,'file')
    load(fname,'defaults');
    names = fieldnames(defaults);
    for ii=1:numel(names)
        name = names{ii};
        set(handles.(name),'Value',defaults.(name));
    end
end




% --- Executes on button press in checkStart.
function checkStart_Callback(hObject, eventdata, handles)
% hObject    handle to checkStart (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hint: get(hObject,'Value') returns toggle state of checkStart


% --- Executes on button press in checkEnd.
function checkEnd_Callback(hObject, eventdata, handles)
% hObject    handle to checkEnd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hint: get(hObject,'Value') returns toggle state of checkEnd


% --- Executes on button press in checkMatch.
function checkMatch_Callback(hObject, eventdata, handles)
% hObject    handle to checkMatch (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hint: get(hObject,'Value') returns toggle state of checkMatch


% --- Executes on button press in checktokenExtents.
function checktokenExtents_Callback(hObject, eventdata, handles)
% hObject    handle to checktokenExtents (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hint: get(hObject,'Value') returns toggle state of checktokenExtents


% --- Executes on button press in checkTokens.
function checkTokens_Callback(hObject, eventdata, handles)
% hObject    handle to checkTokens (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hint: get(hObject,'Value') returns toggle state of checkTokens


% --- Executes on button press in checkNames.
function checkNames_Callback(hObject, eventdata, handles)
% hObject    handle to checkNames (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hint: get(hObject,'Value') returns toggle state of checkNames


% --- Executes on button press in checkSplit.
function checkSplit_Callback(hObject, eventdata, handles)
% hObject    handle to checkSplit (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hint: get(hObject,'Value') returns toggle state of checkSplit


% --- Executes on button press in printRegexp.
function printRegexp_Callback(hObject, eventdata, handles)
% hObject    handle to printRegexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hint: get(hObject,'Value') returns toggle state of printRegexp


% --- Executes on button press in printText.
function printText_Callback(hObject, eventdata, handles)
% hObject    handle to printText (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hint: get(hObject,'Value') returns toggle state of printText


% --- Executes on button press in printDefault.
function printDefault_Callback(hObject, eventdata, handles)
% hObject    handle to printDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
%
% Hint: get(hObject,'Value') returns toggle state of printDefault


% --- Executes on button press in saveDefault.
function saveDefault_Callback(hObject, eventdata, handles)
% hObject    handle to saveDefault (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
handles = rmfield(handles,'figure1');
names = fieldnames(handles);
for ii=1:numel(names)
    name = names{ii};
    if ishandle(handles.(name)) && strcmp(get(handles.(name),'Type'),'uicontrol') ...
            && strcmp(get(handles.(name),'Style'),'checkbox')
        defaults.(name) = get(handles.(name),'Value');
    end
end
save(fullfile(fileparts(which('regexpBuilder')),'print_defaults.mat'),'defaults');
