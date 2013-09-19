function varargout = actant(varargin)
% ACTANT M-file for actant.fig
%      ACTANT, by itself, creates a new ACTANT or raises the existing
%      singleton*.
%
%      H = ACTANT returns the handle to a new ACTANT or the handle to
%      the existing singleton*.
%
%      ACTANT('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in ACTANT.M with the given input arguments.
%
%      ACTANT('Property','Value',...) creates a new ACTANT or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before actant_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to actant_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES
%
% Copyright (C) 2011-2013, Maxim Osipov
%
% All rights reserved.
%
% Redistribution and use in source and binary forms, with or without modification,
% are permitted provided that the following conditions are met:
%
%  - Redistributions of source code must retain the above copyright notice, this
%    list of conditions and the following disclaimer.
%  - Redistributions in binary form must reproduce the above copyright notice,
%    this list of conditions and the following disclaimer in the documentation
%    and/or other materials provided with the distribution.
%  - Neither the name of the University of Oxford nor the names of its
%    contributors may be used to endorse or promote products derived from this
%    software without specific prior written permission.
%
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
% ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
% WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
% IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT,
% INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
% BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
% DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
% OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED
% OF THE POSSIBILITY OF SUCH DAMAGE.

% Edit the above text to modify the response to help actant

% Last Modified by GUIDE v2.5 19-Sep-2013 16:39:05

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @actant_OpeningFcn, ...
                   'gui_OutputFcn',  @actant_OutputFcn, ...
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

% --- Executes just before actant is made visible.
function actant_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to actant (see VARARGIN)

% Choose default command line output for actant
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes actant wait for user response (see UIRESUME)
% uiwait(handles.figure_main);

addpath('./formats');
addpath('./sleep');
addpath('./wake');
addpath('./rhythm');
addpath('./other');
addpath('./plot');

global g_data_file;
global g_data_ts;
global g_data_handle;

global g_plot_subs;
global g_plot_days;
global g_plot_handle;

g_data_file = '';
g_data_ts = timeseries;
g_data_handle = -1;

g_plot_subs = 5;
g_plot_days = 1;
g_plot_handle = -1;

update_vslider(handles, 0);


function update_vslider(handles, enable, first, last, step, handler)
global g_data_handle;
if enable == 0 || g_data_handle == -1,
    set(handles.slider_v, 'Enable', 'off');
else
    set(handles.slider_v, 'Enable', 'on');
    if exist('first', 'var') && exist('last', 'var') && exist('step', 'var'),
        set(handles.slider_v, 'Max', last);
        set(handles.slider_v, 'Min', first);
        set(handles.slider_v, 'SliderStep', [1/(last - first) 5/(last - first)]);
        set(handles.slider_v, 'Value', last);
    end
end


function update_data(handles)
global g_data_file g_data_ts g_plot_handle g_plot_subs g_plot_days;
% Update data table
t_data = get(handles.uitable_data, 'Data');
i = size(t_data, 1) + 1;
t_data{i, 1} = 'Main';
t_data{i, 2} = [g_data_ts.Name ' (' g_data_ts.DataInfo.Units ')'];
t_data{i, 3} = datestr(min(g_data_ts.Time));
t_data{i, 4} = datestr(max(g_data_ts.Time));
t_data{i, 5} = g_data_file;
set(handles.uitable_data, 'Data', t_data);
% Update data plot
g_plot_handle = subplot(1, 1, 1, 'Parent', handles.uipanel_plot);
plot_days(g_plot_handle, floor(min(g_data_ts.Time)), g_plot_subs, g_plot_days, g_data_ts);
update_vslider(handles, 1, floor(min(g_data_ts.Time)), floor(max(g_data_ts.Time)), 1);


function update_analysis(handles)
global g_data_ts g_plot_handle;
m = round(str2double(get(handles.edit_mse_m, 'String')));
r = str2double(get(handles.edit_mse_r, 'String'));
s1 = round(str2double(get(handles.edit_mse_s1, 'String')));
sn = round(str2double(get(handles.edit_mse_sn, 'String')));
scales = s1:sn;
method = get(handles.popupmenu_method, 'Value');
if method == 1,
    h = waitbar(0, 'Please wait...');
    result = mse(g_data_ts.data(:,1), m, r, scales,...
        @(n,s)waitbar(s/n, h));
    close(h);
end
if get(handles.checkbox_mse_hold, 'Value'),
    hold on;
else
    hold off;
end
g_plot_handle = subplot(1, 1, 1, 'Parent', handles.uipanel_plot);
plot(g_plot_handle, scales, result);
title(['Multiscale Entropy (m=' num2str(m) ', r=' num2str(r) ')']);
xlabel('Scale (minutes)');
ylabel('SampEn');
update_vslider(handles, 0);
update_vslider(handles, 0);


% --- Outputs from this function are returned to the command line.
function varargout = actant_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;

% --- Executes on button press in pushbutton_load.
function pushbutton_load_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_data_handle g_data_file g_data_ts;
[fn, fp] = uigetfile('*.*', 'Select the data file');
if fp ~= 0,
    g_data_file = [fp fn];
    g_data_handle = fopen(g_data_file, 'r');
    if g_data_handle == -1,
        warndlg(['Could not open file' g_data_file]);
        g_data_file = '';
    else
        set(handles.figure_main, 'Name', ['ACTANT - ' g_data_file]);
        g_data_ts = load_actiwatch(g_data_file);
        update_data(handles);
        %plot_heat24(g_data_ts, 'Activity', handles.axis_plot);
    end
end

% --------------------------------------------------------------------
function FileMenu_Callback(hObject, eventdata, handles)
% hObject    handle to FileMenu (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function OpenMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to OpenMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
file = uigetfile('*.fig');
if ~isequal(file, 0)
    open(file);
end

% --------------------------------------------------------------------
function PrintMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to PrintMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
printdlg(handles.figure_main)

% --------------------------------------------------------------------
function CloseMenuItem_Callback(hObject, eventdata, handles)
% hObject    handle to CloseMenuItem (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
selection = questdlg(['Close ' get(handles.figure_main,'Name') '?'],...
                     ['Close ' get(handles.figure_main,'Name') '...'],...
                     'Yes','No','Yes');
if strcmp(selection,'No')
    return;
end

delete(handles.figure_main)


% --- Executes on selection change in popupmenu1.
function popupmenu1_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = get(hObject,'String') returns popupmenu1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu1


% --- Executes during object creation, after setting all properties.
function popupmenu1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
     set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton_analyze.
function pushbutton_analyze_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
update_analysis(handles);

% --- Executes on button press in pushbutton_save.
function pushbutton_save_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider_h_Callback(hObject, eventdata, handles)
% hObject    handle to slider_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider


% --- Executes during object creation, after setting all properties.
function slider_h_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_h (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on slider movement.
function slider_v_Callback(hObject, eventdata, handles)
% hObject    handle to slider_v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global g_data_ts g_plot_subs g_plot_days;
start = floor(min(g_data_ts.Time));
sval = get(hObject, 'Value');
smax = get(hObject, 'Max');
smin = get(hObject, 'Min');
% fprintf(1, ['Min: ' num2str(smin) ' Val: ' num2str(sval) ' Max:' num2str(smax) '\n']);
plot_days(handles.uipanel_plot, start + smax - sval, g_plot_subs, g_plot_days, g_data_ts);


% --- Executes during object creation, after setting all properties.
function slider_v_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in popupmenu_method.
function popupmenu_method_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_method contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_method


% --- Executes during object creation, after setting all properties.
function popupmenu_method_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_method (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mse_m_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mse_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mse_m as text
%        str2double(get(hObject,'String')) returns contents of edit_mse_m as a double


% --- Executes during object creation, after setting all properties.
function edit_mse_m_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mse_m (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mse_r_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mse_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mse_r as text
%        str2double(get(hObject,'String')) returns contents of edit_mse_r as a double


% --- Executes during object creation, after setting all properties.
function edit_mse_r_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mse_r (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mse_s1_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mse_s1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mse_s1 as text
%        str2double(get(hObject,'String')) returns contents of edit_mse_s1 as a double


% --- Executes during object creation, after setting all properties.
function edit_mse_s1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mse_s1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit_mse_sn_Callback(hObject, eventdata, handles)
% hObject    handle to edit_mse_sn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_mse_sn as text
%        str2double(get(hObject,'String')) returns contents of edit_mse_sn as a double


% --- Executes during object creation, after setting all properties.
function edit_mse_sn_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_mse_sn (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in checkbox_mse_hold.
function checkbox_mse_hold_Callback(hObject, eventdata, handles)
% hObject    handle to checkbox_mse_hold (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of checkbox_mse_hold


% --------------------------------------------------------------------
function menu_file_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_file_open_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_open (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global g_data_handle g_data_file g_data_ts;
[fn, fp] = uigetfile('*.*', 'Select the data file');
if fp ~= 0,
    g_data_file = [fp fn];
    g_data_handle = fopen(g_data_file, 'r');
    if g_data_handle == -1,
        warndlg(['Could not open file' g_data_file]);
        g_data_file = '';
    else
        set(handles.figure_main, 'Name', ['ACTANT - ' g_data_file]);
        g_data_ts = load_actiwatch(g_data_file);
        update_data(handles);
        %plot_heat24(g_data_ts, 'Activity', handles.axis_plot);
    end
end


% --------------------------------------------------------------------
function menu_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_analysis_mse_Callback(hObject, eventdata, handles)
% hObject    handle to menu_analysis_mse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_file_convert_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
