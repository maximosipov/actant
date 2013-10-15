function varargout = convert(varargin)
% CONVERT MATLAB code for convert.fig
%      CONVERT by itself, creates a new CONVERT or raises the
%      existing singleton*.
%
%      H = CONVERT returns the handle to a new CONVERT or the handle to
%      the existing singleton*.
%
%      CONVERT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in CONVERT.M with the given input arguments.
%
%      CONVERT('Property','Value',...) creates a new CONVERT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before convert_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to convert_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help convert

% Last Modified by GUIDE v2.5 04-Oct-2013 11:07:08

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @convert_OpeningFcn, ...
                   'gui_OutputFcn',  @convert_OutputFcn, ...
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

global g_file_types;
global g_in_type;
global g_out_type;

g_file_types = {
    '*.awd', 'Actiwatch-L text files (*.awd)';...
    '*.csv', 'GENEActiv CSV files (*.csv)';...
    '*.mat', 'Actant MAT files (*.mat)';...
    '*.bin', 'GENEActiv BIN files (*.bin)';...
    '*.csv', 'Actopsy CSV files (*.csv)'
};


function status = file_convert(handles)
    global g_in_type g_out_type;
    % Get and check arguments
    status = false;
    fin = get(handles.text_input, 'String');
    fout = get(handles.text_output, 'String');
    fin_type = g_in_type;
    fout_type = g_out_type;
    % Perform conversion
    if (fin_type == 4 && fout_type == 3),
        status = convert_bin(fin, fout);
    elseif (fin_type == 5 && fout_type == 3),
        status = convert_actopsy(fin, fout);
    end


% --- Executes just before convert is made visible.
function convert_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to convert (see VARARGIN)

    % Choose default command line output for convert
    handles.output = 'Yes';
    % Update handles structure
    guidata(hObject, handles);
    % Insert custom Title and Text if specified by the user
    % Hint: when choosing keywords, be sure they are not easily confused 
    % with existing figure properties.  See the output of set(figure) for
    % a list of figure properties.
    if(nargin > 3)
        for index = 1:2:(nargin-3),
            if nargin-3==index, break, end
            switch lower(varargin{index})
             case 'title'
              set(hObject, 'Name', varargin{index+1});
             case 'string'
              set(handles.text_input, 'String', varargin{index+1});
            end
        end
    end
    % Determine the position of the dialog - centered on the callback figure
    % if available, else, centered on the screen
    FigPos=get(0,'DefaultFigurePosition');
    OldUnits = get(hObject, 'Units');
    set(hObject, 'Units', 'pixels');
    OldPos = get(hObject,'Position');
    FigWidth = OldPos(3);
    FigHeight = OldPos(4);
    if isempty(gcbf)
        ScreenUnits=get(0,'Units');
        set(0,'Units','pixels');
        ScreenSize=get(0,'ScreenSize');
        set(0,'Units',ScreenUnits);
        FigPos(1)=1/2*(ScreenSize(3)-FigWidth);
        FigPos(2)=2/3*(ScreenSize(4)-FigHeight);
    else
        GCBFOldUnits = get(gcbf,'Units');
        set(gcbf,'Units','pixels');
        GCBFPos = get(gcbf,'Position');
        set(gcbf,'Units',GCBFOldUnits);
        FigPos(1:2) = [(GCBFPos(1) + GCBFPos(3) / 2) - FigWidth / 2, ...
                       (GCBFPos(2) + GCBFPos(4) / 2) - FigHeight / 2];
    end
    FigPos(3:4)=[FigWidth FigHeight];
    set(hObject, 'Position', FigPos);
    set(hObject, 'Units', OldUnits);
    % Make the GUI modal
    set(handles.figure_convert,'WindowStyle','modal')
    % UIWAIT makes convert wait for user response (see UIRESUME)
    uiwait(handles.figure_convert);


% --- Outputs from this function are returned to the command line.
function varargout = convert_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % Get default command line output from handles structure
    varargout{1} = handles.output;
    % The figure can be deleted now
    delete(handles.figure_convert);


% --- Executes on button press in pushbutton_ok.
function pushbutton_ok_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_ok (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % perform conversion
    if (file_convert(handles)),
        handles.output = get(hObject,'String');
        % Update handles structure
        guidata(hObject, handles);
        % Use UIRESUME instead of delete because the OutputFcn needs
        % to get the updated handles structure.
        uiresume(handles.figure_convert);
    end


% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    handles.output = get(hObject,'String');
    % Update handles structure
    guidata(hObject, handles);
    % Use UIRESUME instead of delete because the OutputFcn needs
    % to get the updated handles structure.
    uiresume(handles.figure_convert);


% --- Executes when user attempts to close figure_convert.
function figure_convert_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to figure_convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    if isequal(get(hObject, 'waitstatus'), 'waiting')
        % The GUI is still in UIWAIT, us UIRESUME
        uiresume(hObject);
    else
        % The GUI is no longer waiting, just close it
        delete(hObject);
    end


% --- Executes on key press over figure_convert with no controls selected.
function figure_convert_KeyPressFcn(hObject, eventdata, handles)
% hObject    handle to figure_convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % Check for "enter" or "escape"
    if isequal(get(hObject,'CurrentKey'),'escape')
        % User said no by hitting escape
        handles.output = 'No';

        % Update handles structure
        guidata(hObject, handles);

        uiresume(handles.figure_convert);
    end
    if isequal(get(hObject,'CurrentKey'),'return')
        uiresume(handles.figure_convert);
    end    


% --- Executes on button press in pushbutton_input.
function pushbutton_input_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_input (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global g_file_types g_in_type;
    % get file name
    [fn, fp, fi] = uigetfile(g_file_types, 'Select the data file');
    if fp == 0,
        return;
    end
    set(handles.text_input, 'String', [fp fn]);
    g_in_type = fi;
    % clear output file
    set(handles.text_output, 'String', 'No file selected');


% --- Executes on button press in pushbutton_output.
function pushbutton_output_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_output (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global g_file_types g_out_type;
    % get selected type
    type_sel = get(handles.popupmenu_format, 'Value');
    % get file name
    [fn, fp, fi] = uiputfile(g_file_types(type_sel,:), 'Select the data file');
    if fp == 0,
        return;
    end
    set(handles.text_output, 'String', [fp fn]);
    g_out_type = type_sel;


% --- Executes on selection change in popupmenu_format.
function popupmenu_format_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_format contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_format


% --- Executes during object creation, after setting all properties.
function popupmenu_format_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_format (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end
    global g_file_types;
    set(hObject, 'String', g_file_types(:,2));
