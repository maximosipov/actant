function varargout = sleep_consensus_diary(varargin)
% SLEEP_CONSENSUS_DIARY MATLAB code for sleep_consensus_diary.fig
%      SLEEP_CONSENSUS_DIARY, by itself, creates a new SLEEP_CONSENSUS_DIARY or raises the existing
%      singleton*.
%
%      H = SLEEP_CONSENSUS_DIARY returns the handle to a new SLEEP_CONSENSUS_DIARY or the handle to
%      the existing singleton*.
%
%      SLEEP_CONSENSUS_DIARY('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SLEEP_CONSENSUS_DIARY.M with the given input arguments.
%
%      SLEEP_CONSENSUS_DIARY('Property','Value',...) creates a new SLEEP_CONSENSUS_DIARY or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sleep_consensus_diary_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sleep_consensus_diary_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sleep_consensus_diary

% Last Modified by GUIDE v2.5 05-Apr-2014 15:53:41

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sleep_consensus_diary_OpeningFcn, ...
                   'gui_OutputFcn',  @sleep_consensus_diary_OutputFcn, ...
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


% --- Executes just before sleep_consensus_diary is made visible.
function sleep_consensus_diary_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sleep_consensus_diary (see VARARGIN)

% Choose default command line output for sleep_consensus_diary
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% Check for uitable data
if nargin<4,
    data = {'dd-mm-yy', 2300, 2315, 10, 4, 25, 0700, 0715};
    set(handles.uitable_scd, 'Data', data);
else
    data = {'dd-mm-yy', 2300, 2315, 10, 4, 25, 0700, 0715};
    set(handles.uitable_scd, 'Data', data);
end

% UIWAIT makes sleep_consensus_diary wait for user response (see UIRESUME)
uiwait(handles.scd);


% --- Outputs from this function are returned to the command line.
function varargout = sleep_consensus_diary_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

data = get(handles.uitable_scd, 'Data');
labels = {'Date', 'Bed time', 'Lights off', 'Latency', 'Wake times',...
               'Wake duration', 'Wake time', 'Out of bed'};

varargout{1} = data;
delete(handles.scd);



function edit_days_Callback(hObject, eventdata, handles)
% hObject    handle to edit_days (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_days as text
%        str2double(get(hObject,'String')) returns contents of edit_days as a double


% --- Executes during object creation, after setting all properties.
function edit_days_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_days (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_add.
function pushbutton_add_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_add (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % get txt_days value
    global days
    days = str2double(get(handles.edit_days,'String'));
    
    % get uitable data
    data = get(handles.uitable_scd,'Data');
    
    % add empty columns
    for i = 1:days
        data{size(data,1)+i, 1} = '';
    end
    
    % update UI table
    set(handles.uitable_scd, 'Data', data)


% --- Executes on button press in pushbutton_remove.
function pushbutton_remove_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_remove (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    % get edit_days value
    global days
    days = str2double(get(handles.edit_days, 'String'));
    
    % get uitable data
    data = get(handles.uitable_scd, 'Data');
    
    % subtract columns from table
    rows = size(data, 1);
    rows = rows-days;
    
    if rows <= 0
        return
    else
        data = data(1:rows, :);
        
        % update UI table
        set(handles.uitable_scd, 'Data', data)
    end
    
% --- Executes on button press in pushbutton_cancel.
function pushbutton_cancel_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_cancel (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    
    % close figure
    close(handles.scd)

    
% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

    % close figure
    close(handles.scd)


% --- Executes on button press in pushbutton_reset.
function pushbutton_reset_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_reset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
            
% questdlg
choice = questdlg('Are you sure you want to reset the sleep diary?', ...
    'Warning', ...
    'Yes','No','No');
    
% Handle response
switch choice
    case 'Yes'
        % remove any data from main GUI results table
        set(handle, 'Data', {});
    case 'No'
end


% --- Executes when user attempts to close scd.
function scd_CloseRequestFcn(hObject, eventdata, handles)
% hObject    handle to scd (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

if isequal(get(hObject, 'waitstatus'), 'waiting')
    % The GUI is still in UIWAIT, us UIRESUME
    uiresume(hObject);
else
    % The GUI is no longer waiting, just close it
    delete(hObject);
end
