function varargout = regexpBuilder(varargin)
    %% regexpBuilder - GUI to enable easy creation of Matlab regexps
    % 
    %
    % Description:
    %  regexpBuilder() is a GUI that aims to simplify the creation of
    %  regexps in Matlab. It shows exactly what the various outputs are for
    %  the given regexp, text, and input options as you type. All regexp
    %  constructs supported by Matlab are allowed, for help on regexps, see
    %  <a href="matlab:doc regexp">doc regexp</a>. A demo is provided, in
    %  the help, look under 'Other Demos' -> 'rexpBuilder Demo' ->
    %  'regexpBuilder' -> 'Using the regexpBuilder GUI'.
    %
    % Usage:
    %  Enter your regexp in the textbox with "Regexp goes here...".
    %  Optional inputs to the regexp command are enabled using the
    %  checkboxes below. An unchecked box signifies the default is used for
    %  that option. The text to be run on goes in the textbox marked "Text
    %  to parse goes here".
    %  
    %  If you click the Evaluate button, check one of the option
    %  checkboxes, or simply type in either the Regexp or Text textboxes,
    %  the regexp is run against the text and the results are printed in
    %  the Output panel on the right. Each box corresponds to the
    %  particular output of the regexp command. For example, the Match
    %  textbox will contain the same information as |[match] =
    %  regexp(text,regexp,...,'match')|, with the addition of the phrase
    %  'Match #:' signifying which match it corresponds to. You can click
    %  on the button with the Match label to obtain a bigger window for
    %  those results.
    %  
    %  If the regexp can match the text, each match is underlined in the
    %  text and the entire regexp is underlined. If the regexp contains
    %  tokens (named or unnamed), the definition of each token is
    %  highlighted in the regexp and every match of the token is
    %  highlighted in the text with the matching color. Thus, for a regexp
    %  with many tokens that matches often, your text might look rather
    %  rainbowy. If you would like to change the color scheme, see the
    %  highlightText function in this file.
    %  
    %  Lastly, if the you click the Evaluate button, along with the output
    %  mentioned above, the arguments to the regexp command used are
    %  printed to the Command Window in the form 
    %      |output = regexp(TEXT,REGEXP, ARGUMENTS);|
    %
    % See Also:
    %   regexp, regexpi, <a href="matlab:
    %               web(['file:',fileparts(which('regexpBuilder')),'/html/regexpBuilder_create_demo.html'])
    %               ">Using regexpBuilder</a>
    %
    %
    % %CUSTOM_HELP%
    
    % Edit the above text to modify the response to help regexpBuilder
    
    % Last Modified by GUIDE v2.5 30-Sep-2013 10:10:11
    
    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
        'gui_Singleton',  gui_Singleton, ...
        'gui_OpeningFcn', @regexpBuilder_OpeningFcn, ...
        'gui_OutputFcn',  @regexpBuilder_OutputFcn, ...
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
    
    
    % --- Executes just before regexBuilder is made visible.
function regexpBuilder_OpeningFcn(hObject, eventdata, handles, varargin)
    % This function has no output args, see OutputFcn.
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    % varargin   command line arguments to regexBuilder (see VARARGIN)
    
    % Choose default command line output for regexBuilder
    handles.output = hObject;
    
    % Update handles structure
    guidata(hObject, handles);
    set(handles.regex,'TooltipString',sprintf([
        'Place your regexp here.\n',...
        'All valid Matlab regexps are allowed.\n',...
        'Matching tokens will be highlighted, and the \n',...'
        'entire regexp will be underlined if it matches.']));
    set(handles.evaluate,'TooltipString',sprintf([
        'Click to evaluate the regexp.\n',...
        'The actual call to regexp will be \n',...
        'printed in the Command Window.']));
    set(handles.icase,'TooltipString',sprintf([
        'Toggle to ignore case when matching.\n'...
        'Default is to match case.']));
    set(handles.empty,'TooltipString',sprintf([
        'Toggle to allow matching the empty string.\n'...
        'Default is to disallow it.']));
    set(handles.newline,'TooltipString',sprintf([
        'Toggle to allow ''.'' to match any character including newline.\n',...
        'Default is dot does not match newline.']));
    set(handles.m_once,'TooltipString',sprintf([
        'Toggle to have the regexp only match once.\n',...
        'Default is for the regexp to match as many \n',...
        'times as possible.']));
    set(handles.anchors,'TooltipString',sprintf([
        'Toggle to allow ^ and $ to match at line boundaries.\n',...
        'Default is to only match at string boundaries.']));
    set(handles.freespace,'TooltipString',sprintf([
        'Toggle to not match against whitespace and comments.\n',...
        'Use escaped whitespace and comments to match them.\n',...
        'Default is to match on all whitespace and comment symbols.']));
    set(handles.text,'TooltipString',sprintf([
        'Place the text you want to match the regexp against here.\n'...
        'Multi-line text is allowed.\n',...
        'All matches will be underlined, and token matches will be \n',...
        'highlighted with different colors corresponding to different tokens.']));
    set(handles.startButton,'TooltipString',sprintf('Click to view a larger version.'));
    set(handles.Start,'TooltipString',sprintf([
        'The start indices of matching sections are printed here.\n'...
        'Each line corresponds to a different match.']));
    set(handles.endButton,'TooltipString',sprintf('Click to view a larger version.'));
    set(handles.End,'TooltipString',sprintf([
        'The end indices of matching sections are printed here.\n'...
        'Each line corresponds to a different match.']));
    set(handles.matchButton,'TooltipString',sprintf('Click to view a larger version.'));
    set(handles.Match,'TooltipString',sprintf('The different matches are printed here.'));
    set(handles.extentsButton,'TooltipString',sprintf('Click to view a larger version.'));
    set(handles.Extents,'TooltipString',sprintf('The start and end points of each token match are printed here.'));
    set(handles.tokensButton,'TooltipString',sprintf('Click to view a larger version.'));
    set(handles.Tokens,'TooltipString',sprintf('The different token matches are printed here.'));
    set(handles.namesButton,'TooltipString',sprintf('Click to view a larger version.'));
    set(handles.Names,'TooltipString',sprintf('The different named token matches are printed here.'));
    set(handles.splitButton,'TooltipString',sprintf('Click to view a larger version.'));
    set(handles.Split,'TooltipString',sprintf('The unmatched text is printed here.'));
    
    
    % --- Executes when user attempts to close figure1.
function figure1_DeleteFcn(hObject, eventdata, handles)
    % hObject    handle to figure1 (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: delete(hObject) closes the figure
    if isfield(handles,'bo') && ishandle(handles.bo)
        delete(handles.bo);
    end
    if isfield(handles,'eo') && ishandle(handles.eo)
        delete(handles.eo);
    end
    delete(hObject);
    
    % --- Outputs from this function are returned to the command line.
function varargout = regexpBuilder_OutputFcn(hObject, eventdata, handles)
    % varargout  cell array for returning output args (see VARARGOUT);
    % hObject    handle to figure
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Get default command line output from handles structure
    varargout{1} = handles.output;
    
    % Get handle to the jTextPane
    jScrollPane = findjobj(handles.text);
    jText = jScrollPane.getViewport.getComponent(0);
    jText = handle(jText,'CallbackProperties');
    set(jText,'KeyTypedCallback',{@my_Callback,handles.text,hObject});
    handles.jText = jText;
    jScrollPane = findjobj(handles.regex);
    jRegex = jScrollPane.getViewport.getComponent(0);
    jRegex = handle(jRegex,'CallbackProperties');
    set(jRegex,'KeyTypedCallback',{@my_Callback,handles.regex,hObject});
    handles.jRegex = jRegex;
    
    % add timer for computing regexp
    handles.timer = timer('StartDelay',.5,'TimerFcn',@(x,y)doRegexp(handles),...
        'StopFcn',@(x,y)disp('stopping'),'BusyMode','error',...
        'ErrorFcn',@(x,y)disp('ERROR ERROR'));
    guidata(hObject,handles);
    
    % Add icon to ImportFileChooser button
    jImportFileChooserButton = findjobj(handles.ImportFileChooser);
    jEvalOptionsButton = findjobj(handles.evalOptions);
    jImportFileChooserButton = handle(jImportFileChooserButton,'CallbackProperties');
    jEvalOptionsButton = handle(jEvalOptionsButton,'CallbackProperties');
    downArrowIconJarFile = fullfile(matlabroot,'java','jar','common.jar');
    jarIconsFolder = '/com/mathworks/common/icons/resources/';
    downArrowIconURI = ['jar:file:/' downArrowIconJarFile ...
        '!' jarIconsFolder 'documents_black_down_arrow.png'];
    downArrowIcon = javax.swing.ImageIcon(java.net.URL(downArrowIconURI));
    jImportFileChooserButton.setIcon(downArrowIcon);
    bigArrow = downArrowIcon.getImage();
    bigArrow = javax.swing.ImageIcon(bigArrow.getScaledInstance(...
        bigArrow.getWidth()*2,bigArrow.getHeight()*2,...
        java.awt.Image.SCALE_SMOOTH));
    jEvalOptionsButton.setIcon(bigArrow);
    
    importPath = handle(findjobj(handles.ImportPath),'CallbackProperties');
    jImportFileChooserButton.setBorder(importPath.getBorder());
    jEvalOptionsButton.Border = [];
    
    %Disable certain input possibilities based on Matlab version
    ourVer = checkVersion;
    if ourVer<3
        set(handles.empty,'Enable','off');
        if ourVer<1
            set([handles.empty,handles.icase,handles.newline,handles.freespace],...
                'Enable','off');
        end
    end
    
    pause(.5);
    try
        fix_output_pane(handles,'Start');
    catch err
        if false && true
            disp(err.Identifier);
        end
        fix_output_pane(handles,'Start');
    end
    fix_output_pane(handles,'End');
    fix_output_pane(handles,'Match');
    fix_output_pane(handles,'Extents');
    fix_output_pane(handles,'Tokens');
    fix_output_pane(handles,'Names');
    fix_output_pane(handles,'Split');
    
    
function fix_output_pane(handles,pane)
    jScrollPane = findjobj(handles.(pane));
    jText = handle(jScrollPane.getViewport.getComponent(0),'CallbackProperties');
    jText.setEditable(false);
    jText.setDragEnabled(true);
    
function text_Callback(hObject, eventdata, handles)
    % hObject    handle to text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of text as text
    %        str2double(get(hObject,'String')) returns contents of text as a double
    %doRegexp(handles);
    
    % --- Executes during object creation, after setting all properties.
function text_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to text (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'),...
            get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    if ~iscell(get(hObject,'String'))
        set(hObject,'String',{get(hObject,'String')});
    end
    
    
    
function my_Callback(hObject, eventdata, h, handler)
    doRegexp(guidata(handler));

    
function regex_Callback(hObject, eventdata, handles) %#ok<*INUSL>
    % hObject    handle to regex (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hints: get(hObject,'String') returns contents of regex as text
    %        str2double(get(hObject,'String')) returns contents of regex as a double
    doRegexp(handles);
      
    % --- Executes during object creation, after setting all properties.
function regex_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to regex (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    if ~iscell(get(hObject,'String'))
        set(hObject,'String',{get(hObject,'String')});
    end
    
    % --- Executes on button press in evaluate.
function evalOptions_Callback(hObject, eventdata, handles)
    % hObject    handle to evaluate (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    if ~isfield(handles,'eo') || ~ishandle(handles.eo)
        eo = evaluateOptions;
        handles.eo = eo;
        eohand = guidata(eo);
        eohand.handles = handles;
        guidata(eo,eohand);
        guidata(handles.figure1,handles);
        set(eo,'CloseRequestFcn',@(src,evnt)set(src,'Visible','off'));
    end
    set(handles.eo,'Visible','on')
    pause on;pause(0.001);pause off;
  
% --- Executes on button press in printRegexp.
function printRegexpCommandAndClose_Callback(hObject, eventdata, handles)
% hObject    handle to printRegexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evaluate_Callback(hObject, eventdata, handles.handles);
close(handles.figure1);
    
% --- Executes on button press in printRegexp.
function printRegexpCommand_Callback(hObject, eventdata, handles)
% hObject    handle to printRegexp (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
evaluate_Callback(hObject, eventdata, handles.handles);
    
function evaluate_Callback(hObject, eventdata, handles)
    
    regexpCommand = doRegexp(handles);
    fprintf('Using function call:\n%s\n',regexpCommand);
    
    
    % --- Executes on button press in icase.
function icase_Callback(hObject, eventdata, handles)
    % hObject    handle to icase (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of icase
    doRegexp(handles);
    
    % --- Executes on button press in empty.
function empty_Callback(hObject, eventdata, handles)
    % hObject    handle to empty (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of empty
    doRegexp(handles);
    
    % --- Executes on button press in newline.
function newline_Callback(hObject, eventdata, handles)
    % hObject    handle to newline (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of newline
    doRegexp(handles);
    
    
    % --- Executes on button press in m_once.
function m_once_Callback(hObject, eventdata, handles)
    % hObject    handle to m_once (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of m_once
    doRegexp(handles);
    
    % --- Executes on button press in anchors.
function anchors_Callback(hObject, eventdata, handles)
    % hObject    handle to anchors (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of anchors
    doRegexp(handles);
    
    % --- Executes on button press in freespace.
function freespace_Callback(hObject, eventdata, handles)
    % hObject    handle to freespace (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    
    % Hint: get(hObject,'Value') returns toggle state of freespace
    doRegexp(handles);
    
    
function Start_Callback(hObject, eventdata, handles)
    % hObject    handle to Start (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of Start as text
    %        str2double(get(hObject,'String')) returns contents of Start as a double
    
    
    % --- Executes during object creation, after setting all properties.
function Start_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to Start (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function End_Callback(hObject, eventdata, handles)
    % hObject    handle to End (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of End as text
    %        str2double(get(hObject,'String')) returns contents of End as a double
    
    
    % --- Executes during object creation, after setting all properties.
function End_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to End (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function Extents_Callback(hObject, eventdata, handles)
    % hObject    handle to Extents (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of Extents as text
    %        str2double(get(hObject,'String')) returns contents of Extents as a double
    
    
    % --- Executes during object creation, after setting all properties.
function Extents_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to Extents (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function Match_Callback(hObject, eventdata, handles)
    % hObject    handle to Match (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of Match as text
    %        str2double(get(hObject,'String')) returns contents of Match as a double
    
    
    % --- Executes during object creation, after setting all properties.
function Match_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to Match (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function Tokens_Callback(hObject, eventdata, handles)
    % hObject    handle to Tokens (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of Tokens as text
    %        str2double(get(hObject,'String')) returns contents of Tokens as a double
    
    
    % --- Executes during object creation, after setting all properties.
function Tokens_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to Tokens (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function Names_Callback(hObject, eventdata, handles)
    % hObject    handle to Names (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of Names as text
    %        str2double(get(hObject,'String')) returns contents of Names as a double
    
    
    % --- Executes during object creation, after setting all properties.
function Names_CreateFcn(hObject, eventdata, handles)
    % hObject    handle to Names (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
function Split_Callback(hObject, eventdata, handles) %#ok<*INUSD,*DEFNU>
    % hObject    handle to Split (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    structure with handles and user data (see GUIDATA)
    %
    % Hints: get(hObject,'String') returns contents of Split as text
    %        str2double(get(hObject,'String')) returns contents of Split as a double
    
    
    % --- Executes during object creation, after setting all properties.
function Split_CreateFcn(hObject, eventdata, handles) 
    % hObject    handle to Split (see GCBO)
    % eventdata  reserved - to be defined in a future version of MATLAB
    % handles    empty - handles not created until after all CreateFcns called
    
    % Hint: edit controls usually have a white background on Windows.
    %       See ISPC and COMPUTER.
    if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
        set(hObject,'BackgroundColor','white');
    end
    
    
    
    %----------------------------------------------------------------------
function regexpString = doRegexp(handles)
    %DOREGEXP - main processing function of regexpBuilder
        
    %Convert handles to struct array so that we can pull stuff easier
    gui = h2s(handles); % fix handles, curently handle_name -> handle
    
    % Gather inputs for our call to regexp
    rb.regexp = char(gui.('jRegex').properties.Text);
    rb.text = char(gui.('jText').properties.Text);
    
    if strcmp(rb.regexp,sprintf('\n'))||strcmp(rb.text,sprintf('\n'))
        return;
    end
    
    flags = cell(1,6);
    
    if gui.('icase').properties.Value,rb.case = 'ignorecase';flags{1}='ignorecase';
    else rb.case= 'matchcase';end
    if gui.('empty').properties.Value,rb.empty = 'emptymatch';flags{2}='emptymatch';
    else rb.empty='noemptymatch';end
    if gui.('newline').properties.Value,rb.newline = 'dotexceptnewline';flags{3}='dotexceptnewline';
    else rb.newline='dotall';end
    if gui.('m_once').properties.Value,rb.once = true;flags{4}='once';
    else rb.once = false;end
    if gui.('anchors').properties.Value,rb.anchors = 'lineanchors';flags{5}='lineanchors';
    else rb.anchors='stringanchors';end
    if gui.('freespace').properties.Value,rb.freespace = 'freespacing';flags{6}='freespacing';
    else rb.freespace='literalspacing';end
    
    % Do regexp
    try
        if false==true
            args = {'warnings'};
        else 
            args = cell(0);
        end
        if rb.once
            [rb.start, rb.end, rb.extents, rb.match, rb.tokens, rb.names, rb.split] =...
                myregexp(rb.text,rb.regexp,'start','end','tokenExtents','match',...
                'tokens','names','split',rb.case,rb.empty,rb.newline,...
                rb.anchors,rb.freespace,true,args{:});
            rb.extents = {rb.extents};
            rb.match = {rb.match};
            rb.tokens = {rb.tokens};
        else
           [rb.start, rb.end, rb.extents, rb.match, rb.tokens, rb.names, rb.split] =...
               myregexp(rb.text,rb.regexp,'start','end','tokenExtents','match',...
               'tokens','names','split',rb.case,rb.empty,rb.newline,...
               rb.anchors,rb.freespace,false,args{:});
        end
    catch err
        warning(err.identifier,err.message);
    end
   
    % Generate regexp command string based on print options, user default
    % print options, and finally default print options if no others are
    % found.  Needs to be refactored, as it is currently very meesy and
    % possibly fragile.
    args = cell(0);
    for ii=1:numel(flags)
        if ~isempty(flags{ii})
            args{end+1} = ['''',flags{ii},'''']; %#ok<AGROW>
        end
    end
    fname = fullfile(fileparts(which('regexpBuilder')),'print_defaults.mat');
    if isfield(gui,'eo') && ~isempty(gui.eo) && ishandle(gui.eo.handle)
        eo = h2s(guidata(gui.eo.handle));
        names = fieldnames(eo);
        outs='[';
        for ii=1:numel(names)
            if ~isempty(strfind(names{ii},'check')) ...
                && eo.(names{ii}).properties.Value
                name = regexprep(names{ii},'check','');
                args{end+1} = ['''',lower(name),'''']; %#ok<AGROW>
                if ~strcmp(outs ,'['); outs=[outs,',']; end; %#ok<AGROW>
                outs = [outs,upper(name(1)),name(2:end)]; %#ok<AGROW>
            end
        end
        outs=[outs,']'];
        if eo.printRegexp.properties.Value
            args = [{['''',regexprep(rb.regexp,'''',''''''),'''']},args];
        else
            args = [{'REGEXP'},args];
        end
        if eo.printText.properties.Value
            args = [{['''',regexprep(rb.text,'''',''''''),'''']},args];
        else
            args = [{'TEXT'},args];
        end
        if eo.printDefault.properties.Value
            if isempty(flags{1}); args{end+1}=['''',rb.case,'''']; end;
            if isempty(flags{2}); args{end+1}=['''',rb.empty,'''']; end;
            if isempty(flags{3}); args{end+1}=['''',rb.newline,'''']; end;
            if isempty(flags{4}); args{end+1}=['''',rb.anchors,'''']; end;
            if isempty(flags{5});  end;
            if isempty(flags{6}); args{end+1}=['''',rb.freespace,'''']; end;
        end
    elseif exist(fname,'file')
        load(fname,'defaults');
        names = fieldnames(defaults);
        outs='[';
        for ii=1:numel(names)
            name = names{ii};
            if ~isempty(strfind(name,'check')) && defaults.(name)
                name = strrep(name,'check','');
                args{end+1} = [lower(name(1)),name(2:end)]; %#ok<AGROW>
                if ~strcmp(outs ,'['); outs=[outs,',']; end; %#ok<AGROW>
                outs = [outs,upper(name(1)),name(2:end)]; %#ok<AGROW>
            end
        end
        outs=[outs,']'];
        if defaults.printRegexp
            args = [{['''',regexprep(rb.regexp,'''',''''''),'''']},args];
        else
            args = [{'REGEXP'},args];
        end 
        if defaults.printText
            args = [{['''',regexprep(rb.text,'''',''''''),'''']},args];
        else
            args = [{'TEXT'},args];
        end
        if defaults.printDefault
            if isempty(flags{1}); args{end+1}=['''',rb.case,'''']; end;
            if isempty(flags{2}); args{end+1}=['''',rb.empty,'''']; end;
            if isempty(flags{3}); args{end+1}=['''',rb.newline,'''']; end;
            if isempty(flags{4}); args{end+1}=['''',rb.anchors,'''']; end;
            if isempty(flags{5});  end;
            if isempty(flags{6}); args{end+1}=['''',rb.freespace,'''']; end;
        end
    else
        args = [{['TEXT,REGEXP,''start'',''end'',''tokenExtents'',',...
            '''match'',''tokens'',''names'',''split''']},args];
        outs = '[Start,End,TokenExtents,Match,Tokens,Names,Split]';
    end
    if ~isempty(args)
        args = [cellfun(@(x)[x,','],args(1:end-1),'UniformOutput',false),args(end)];
        
    end
    regexpString = [outs,' = regexp(',args{:},');'];
    
    strings = cell(0);
    if isfield(rb,'extents')
        count = 1;
        for ii=1:numel(rb.extents)
            temp = rb.extents{ii};
            strings{count} = sprintf('Match %g:',ii);
            count = count+1;
            string = num2str(temp);
            string = string';
            string = [string;repmat(sprintf('\n'),1,size(string,2))]; %#ok<AGROW>
            string = string(:);
            strings{count} = regexprep(string','  ',' -> ');
            count = count+1;
        end
    end
    rb.extentStrings = strings;
    
    strings = cell(0);
    if isfield(rb,'names')
        fn = fieldnames(rb.names);
        count=1;
        for ii=1:numel(rb.names)
            strings{count} = sprintf('Match %g:',ii);
            count = count+1;
            for jj=1:numel(fn)
                strings{count} = sprintf('%s: %s',fn{jj},rb.names(ii).(fn{jj}));
                count = count+1;
            end
            strings{count} = '';
            count = count+1;
        end
    end
    rb.namesStrings = strings;
    
    strings = cell(0);
    count = 1;
    if isfield(rb,'tokens')
        for ii=1:numel(rb.tokens)
            temp = rb.tokens{ii};
            strings{count} = sprintf('Match %g:',ii);
            count = count+1;
            for jj=1:numel(temp)
                strings{count} = sprintf('%g: %s',jj,temp{jj});
                count = count+1;
            end
            strings{count} = '';
            count = count+1;
        end
    end
    rb.tokensStrings = strings;
    
    if isfield(rb,'match')
        rb.match = [arrayfun(@(x){sprintf('Match %g:',x)},...
            1:numel(rb.match))',rb.match'];
        rb.match = rb.match';
        rb.match = rb.match(:);
    end
    
    if isfield(rb,'split')
        rb.split = [arrayfun(@(x){sprintf('Split %g:',x)},...
            1:numel(rb.split))',rb.split'];
        rb.split = rb.split';
        rb.split = rb.split(:);
    end
    
    highlightText(gui.('jRegex'),gui.('jText'),rb);
    
    % Display output
    try
        if isfield(rb,'start')
            set(gui.('Start').handle,'String',rb.start);
            set(gui.('End').handle,'String',rb.end);
            set(gui.('Extents').handle,'String',rb.extentStrings);
            set(gui.('Match').handle,'String',rb.match);
            set(gui.('Tokens').handle,'String',rb.tokensStrings);
            set(gui.('Names').handle,'String',rb.namesStrings);
            set(gui.('Split').handle,'String',rb.split);
        end
    catch err 
        % If we end up here, it's probably because something went wrong
        % with the regexp invocation.
        warning(err.identifier,err.message);
    end
    
    %setProps(gui([si,ei,xi,mi,ti,ni,spi]));
    
    if isfield(handles,'bo') && ishandle(handles.bo)
        tag = get(handles.bo,'Tag');
        setBigOutputText(tag,handles);
    end
    
    %drawnow expose;

    
function struc = h2s(handles)
    names = fieldnames(handles);
    for ii=1:numel(names)
        if ~ishandle(handles.(names{ii}))
            handles = rmfield(handles,names{ii});
            continue;
        end
        s1.properties = get(handles.(names{ii}));
        s1.handle = handles.(names{ii});
        struc.(names{ii}) = s1;
    end
     
function highlightText(regexP,textP,rb)
    page = textP.properties.Document;
    text = textP.properties.Text;
    page.setCharacterAttributes(0,numel(text),...
        javax.swing.text.SimpleAttributeSet(),true);
    reg = regexP.properties.Document;
    regex = regexP.properties.Text;
    reg.setCharacterAttributes(0,numel(regex),...
        javax.swing.text.SimpleAttributeSet(),true);
    
    jUnderline = javax.swing.text.SimpleAttributeSet();
    javax.swing.text.StyleConstants.setUnderline(jUnderline,true);
    
    if ~isfield(rb,'start')
        rb.start = [];
    end
    
    
    if isfield(rb,'tokens') && ~isempty(rb.tokens)
        %%%%%%%%%%%%%%%%%%
        cmap = jet(128); % Change this to change the highlighting color scheme
        %%%%%%%%%%%%%%%%%%
        cmap = brighten(cmap,.9);
        
        [s,e] = findTokens(regex);
        
        numtok = numel(rb.tokens{1});
        for ii=1:numel(rb.tokens{1})
            ind = floor(ii/numtok*128);
            jColor = javaObject('java.awt.Color',cmap(ind,1),cmap(ind,2),cmap(ind,3));
            jAttributeSet(ii) = javax.swing.text.SimpleAttributeSet(); %#ok<AGROW>
            javax.swing.text.StyleConstants.setBackground(jAttributeSet(ii),jColor);
            reg.setCharacterAttributes(s(ii)-1,e(ii)-(s(ii)-1),jAttributeSet(ii),false);
        end
        
        for ii=1:numel(rb.tokens)
            extents = rb.extents{ii};
            for jj=1:numel(rb.tokens{1})
                page.setCharacterAttributes(extents(jj,1)-1,...
                    extents(jj,2)-(extents(jj,1)-1),jAttributeSet(jj),false);
            end
        end
    end
    
    for ii=1:length(rb.start)
        page.setCharacterAttributes(rb.start(ii)-1,...
            rb.end(ii)-(rb.start(ii)-1),jUnderline,false);
        reg.setCharacterAttributes(0,length(regex)-1,...
            jUnderline,false);
    end
    
function [s,e]=findTokens(regex)    
    regex = regexprep(regex,'#.*\n','\n','dotexceptnewline');
    s=[];
    e=[];
    lvl = 0;
    for ii=1:length(regex)
        c = regex(ii);
        l = regex(max(ii-1,1));
        r = regex(min(ii+1,length(regex)));
        if (c=='(' || c==')') && l=='\'
            bs=1;
            for jj=ii-2:-1:1
                if regex(jj)~='\'
                    break;
                end
                bs = bs+1;
            end
        else
            bs=0;
        end
        if c=='(' && (l~='\' || mod(bs,2)==0)
            lvl = lvl+1;
            if lvl == 1 && r~='?'
                s = [s,ii]; %#ok<AGROW>
            elseif lvl==1
                % out of regex or non-capturing group
                if ii+2>length(regex) || regex(ii+2)==':'
                    continue;
                end
                % check for valid named capture group
                if regex(ii+2)=='<'
                    jj=ii+3;
                    cont = 0;
                    while ~cont
                        if jj>length(regex)
                            cont=2;  %Out of regex
                        end
                        if all(regex(jj)~=['A':'Z','a':'z','_'])
                            cont=2; %invalid character
                        end
                        if regex(jj)=='>'
                            cont=1;
                        end
                        jj=jj+1;
                    end
                    if jj==ii+3 || cont~=1
                        continue;
                    end
                    s = [s,ii]; %#ok<AGROW>
                end
            end
        elseif c==')' && (l~='\' || mod(bs,2)==0)
                lvl = max(lvl-1,0);
                if lvl==0 && length(e)<length(s)
                    e = [e,ii]; %#ok<AGROW>
                end
        end
    end
    if length(s)>length(e)
        s = s(1:end-1);
    end

         
function showBigOutput(hObject,eventdata,handles)
    tag = get(hObject,'Tag');
    tag = regexprep(tag,'[bB]utton','');
    tag = [upper(tag(1)),tag(2:end)];
    setBigOutputText(tag,handles);
    
    
function setBigOutputText(tag,handles)
    if ~isfield(handles,'bo') || ~ishandle(handles.bo)
        bo = bigOutput;
        handles.bo = bo;
        guidata(handles.figure1,handles);
    end
    boh = guidata(handles.bo);
    set(handles.bo,'Tag',tag);
    set(boh.output_name,'Title',[tag,':']);
    set(boh.output_text,'String',get(handles.(tag),'String'));
    pause on;pause(0.001);pause off;

function ver=checkVersion()
    try
        ver = 3;
        if verLessThan('matlab','7.12') %no emptymatch
            ver = 2;
            if verLessThan('matlab','7.5') %no split
                ver = 1;
                if verLessThan('matlab','7.2') %no parsing modes
                    ver = 0;
                end
            end
        end
    catch %#ok<CTCH>
        % No verLessThan function -> we are less than 6.0?
        ver = -1;
    end
    
    
function [start, myend, extents, match, tokens, names, split] =...
        myregexp(textString,regexpString,startOpt,endOpt,tokenExtentsOpt,matchOpt,...
        tokensOpt,namesOpt,splitOpt,mycase,empty,newline,...
        anchors,freespace,once,varargin)
    ourVer = checkVersion;
    if once
        varargin = ['once',varargin];
    end
    switch(ourVer)
        case 3
            [start, myend, extents, match, tokens, names, split] =...
                regexp(textString,regexpString,startOpt,endOpt,tokenExtentsOpt,matchOpt,...
                tokensOpt,namesOpt,splitOpt,mycase,empty,newline,...
                anchors,freespace,varargin{:});
        case 2
            [start, myend, extents, match, tokens, names, split] =...
                regexp(textString,regexpString,startOpt,endOpt,tokenExtentsOpt,matchOpt,...
                tokensOpt,namesOpt,splitOpt,mycase,newline,...
                anchors,freespace,varargin{:});
        case 1
            [start, myend, extents, match, tokens, names] =...
                regexp(textString,regexpString,startOpt,endOpt,tokenExtentsOpt,matchOpt,...
                tokensOpt,namesOpt,mycase,newline,...
                anchors,freespace,varargin{:});
            split = create_split(textString,start,myend);
        case 0
            [start, myend, extents, match, tokens, names] =...
                regexp(textString,regexpString,startOpt,endOpt,tokenExtentsOpt,matchOpt,...
                tokensOpt,namesOpt,anchors,varargin{:});
            split = create_split(textString,start,myend);
        otherwise
            error('Matlab version is probably too low for RegexpBuilder to work!');
    end
    
function split = create_split(textString,start,myend)
    if numel(start)<=0
        split = {textString};
        return;
    end
    split_start = myend(1:end-1)+1;
    split_end = start(2:end)-1;
    if start(1)>1
        split_start = [1 split_start];
        split_end = [start(1)-1 split_end];
    end
    if myend(end)<length(textString)
        split_start = [split_start myend(end)+1];
        split_end = [split_end length(textString)];
    end
    split = cell(numel(match));
    for ii=1:numel(match)
        split{ii} = textString(split_start(ii):split_end(ii));
    end
    warning('Error:Old_Version',['Your version of Matlab does not have',...
        ' the split outSelect mode. The output printed is what would it',...
        ' would be if you did.'])
    
    
% --- Executes on callback in ImportPath
function ImportPath_Callback(hObject, eventdata, handles)
% hObject    handle to ImportButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
importFile(handles);

% --- Executes during object creation, after setting all properties.
function ImportPath_CreateFcn(hObject, eventdata, handles)
% hObject    handle to ImportPath (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in ImportButton.
function ImportButton_Callback(hObject, eventdata, handles)
% hObject    handle to ImportButton (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
importFile(handles)

function importFile(handles)
try
    path = get(handles.ImportPath,'String');
    if isempty(regexp(path,'^(http|ftp)','once'))
        if ~isempty(regexp(path,'^www\.','once'))
            path = ['http://' path];
        else
            path = ['file:' path];
        end
    end
    text = urlread(path);
    text = strrep(text,sprintf('\r'),'');
%     fid = fopen(get(handles.ImportPath,'String'));
%     line = fgets(fid);
%     text='';
%     while line~=-1
%         text=[text line];
%         line = fgets(fid);
%     end
%     fclose(fid);
    set(handles.jText,'Text',text);
    doRegexp(handles);
catch err
    warning(err.identifier,err.message);
end

% --- Executes on button press in ImportFileChooser.
function ImportFileChooser_Callback(hObject, eventdata, handles)
% hObject    handle to ImportFileChooser (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
[file, path] = uigetfile({
    '*.txt'
    '*.rtf'
    });
set(handles.ImportPath,'String',fullfile(path,file));
