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

% Last Modified by GUIDE v2.5 08-Oct-2013 11:41:57

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

global g_file_types;

global g_data_file;
global g_data_ts;
global g_data_handle;

global g_plot_subs;
global g_plot_days;
global g_plot_overlap;
global g_plot_handle;
global g_main_lim;
global g_top_lim;

global g_analysis_func;

g_file_types = {
    '*.awd', 'Actiwatch-L text files (*.awd)';...
    '*.csv', 'GENEActiv CSV files (*.csv)';...
    '*.mat', 'GENEActiv MAT files (*.mat)';...
    '*.csv', 'Actopsy CSV files (*.csv)'
    };

g_data_file = {};
g_data_ts = {};
g_data_handle = [];

g_plot_subs = 5;
g_plot_days = 1;
g_plot_overlap = 0;
g_plot_handle = -1;
g_main_lim = [];
g_top_lim = [];

g_analysis_func = [];

update_vslider(handles, 0);

function load_file(handles)
    global g_data_handle g_data_file g_data_ts g_plot_handle...
        g_file_types g_main_lim;
    % get file name
    [fn, fp, fi] = uigetfile(g_file_types, 'Select the data file');
    if fp == 0,
        return;
    end
    % Get and open data file
    new_file = [fp fn];
    new_handle = fopen(new_file, 'r');
    if new_handle == -1,
        warndlg(['Could not open file' new_file]);
        return;
    end
    g_data_file{size(g_data_file, 2)+1} = new_file;
    g_data_handle{size(g_data_handle, 2)+1} = new_handle;
    % Load dataset
    h = waitbar(0, 'Please wait while the data is loaded...');
    if fi == 1,
        data = load_actiwatch(new_file);
    elseif fi == 2,
        data = load_geneactiv(new_file);
    elseif fi == 3,
        data = load(new_file);
    else
        data = load_actopsy(new_file);       
    end
    waitbar(1, h);
    close(h);
    % Update data table
    add_dataset(data, new_file, 'No', handles);
    % Update analysis dataset selector
    nums = {};
    for i=1:size(g_data_ts, 2),
        nums{i} = num2str(i);
    end
    set(handles.popupmenu_dataset, 'String', nums);

  
function update_plot(handles, slide)
    global g_data_ts g_plot_subs g_plot_days g_plot_overlap...
           g_main_lim g_top_lim;
    % get timeseries to display
    ts_main = [];
    idx_main = get_plot_index('Main', handles);
    if idx_main > 0,
        ts_main = g_data_ts{idx_main};
        % Update limits
        main_min = get(handles.edit_main_min, 'String');
        main_max = get(handles.edit_main_max, 'String');
        if isempty(main_min) || isempty(main_max),
            g_main_lim = [min(min(ts_main.Data)) max(max(ts_main.Data))];
            set(handles.edit_main_min, 'String', num2str(g_main_lim(1)));
            set(handles.edit_main_max, 'String', num2str(g_main_lim(2)));
        else
            g_main_lim = [str2num(main_min) str2num(main_max)];
        end
    else
        errordlg('Please select the main plot!');
        return;
    end
    ts_top = [];
    idx_top = get_plot_index('Top', handles);
    if idx_top > 0,
        ts_top = g_data_ts{idx_top};
        % Update limits
        top_min = get(handles.edit_top_min, 'String');
        top_max = get(handles.edit_top_max, 'String');
        if isempty(top_min) || isempty(top_max),
            g_top_lim = [min(min(ts_top.Data)) max(max(ts_top.Data))];
            set(handles.edit_top_min, 'String', num2str(g_top_lim(1)));
            set(handles.edit_top_max, 'String', num2str(g_top_lim(2)));
        else
            g_top_lim = [str2num(top_min) str2num(top_max)];
        end
    end
    ts_markup = [];
    idx_markup = get_plot_index('Markup', handles);
    if idx_markup > 0,
        ts_markup = g_data_ts{idx_markup};
    end
    % Update screen title
    dataset = get(handles.uitable_data, 'Data');
    set(handles.uipanel_plot, 'Title', dataset{idx_main, 5});
    % get plot start time
    if slide == 0,
        update_vslider(handles, 1, floor(min(ts_main.Time)), floor(max(ts_main.Time)), 1);
    end
    start = floor(min(ts_main.Time));
    sval = get(handles.slider_v, 'Value');
    smax = get(handles.slider_v, 'Max');
    smin = get(handles.slider_v, 'Min');
    % get number of plots, days and overlap
    val = get(handles.edit_plots, 'String');
    g_plot_subs = str2num(val);
    val = get(handles.edit_days, 'String');
    g_plot_days = str2num(val);
    val = get(handles.edit_overlap, 'String');
    g_plot_overlap = str2num(val);
    % Plot
    plot_days(handles.uipanel_plot, start + smax - sval,...
                g_plot_subs, g_plot_days, g_plot_overlap,...
                ts_main, ts_top, ts_markup,...
                g_main_lim, g_top_lim);

    
function setup_analysis(func, handles)
    global g_analysis_func;
    g_analysis_func = func;
    [~, ~, args] = g_analysis_func();
    set(handles.uitable_analysis, 'Data', args);


function analyze(handles)
    global g_data_ts g_analysis_func;
    analysis_args = get(handles.uitable_analysis, 'Data');
    n = get(handles.popupmenu_dataset, 'Value');
    if isempty(g_analysis_func),
        errordlg('Please select analysis method!');
        return;
    end
    h = waitbar(0, 'Please wait while analysis completes...');
    [ts, markup, vals] = g_analysis_func(g_data_ts{n}, analysis_args);
    waitbar(1, h);
    close(h);
    if ~isempty(ts),
        add_dataset(ts, analysis_args{1,2}, 'Top', handles);
    end
    if ~isempty(markup),
        add_dataset(markup, analysis_args{1,2}, 'No', handles);
    end
    set(handles.uitable_results, 'Data', vals);


function update_vslider(handles, enable, first, last, step, handler)
    global g_data_handle;
    if enable == 0 || size(g_data_handle, 1) < 1,
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


function index = get_plot_index(type, handles)
    index = 0;
    dataset = get(handles.uitable_data, 'Data');
    for i=1:size(dataset, 1),
        if strcmp(dataset{i}, type),
            index = i;
            return;
        end
    end


function add_dataset(data, new_name, new_show, handles)
    global g_data_ts;
    datasets = get(handles.uitable_data, 'Data');
    row = size(datasets, 1) + 1;
    % number of time series in the loaded file
    field_names = fieldnames(data);
    for i = 1:numel(field_names)
        % get the first field
        ts_tmp = getfield(data, char(field_names(i))); 
        % check if field is a time series
        if strcmpi(class(ts_tmp), 'timeseries')
            datasets{row, 1} = new_show;
            datasets{row, 2} = [ts_tmp.Name ' (' ts_tmp.DataInfo.Units ')'];
            datasets{row, 3} = datestr(min(ts_tmp.Time));
            datasets{row, 4} = datestr(max(ts_tmp.Time));
            datasets{row, 5} = new_name;           
            row = row + 1;
            g_data_ts{size(g_data_ts, 2)+1} = ts_tmp;
        end
        set(handles.uitable_data, 'Data', datasets);
    end            


% --- Outputs from this function are returned to the command line.
function varargout = actant_OutputFcn(hObject, eventdata, handles)
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Menu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
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
    load_file(handles);


% --------------------------------------------------------------------
function menu_file_convert_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_convert (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    convert();


% --------------------------------------------------------------------
function menu_file_export_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_file_print_Callback(hObject, eventdata, handles)
% hObject    handle to menu_file_print (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    printdlg;


% --------------------------------------------------------------------
function menu_sleep_Callback(hObject, eventdata, handles)
% hObject    handle to menu_sleep (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_sleep_scoring_Callback(hObject, eventdata, handles)
% hObject    handle to menu_sleep_scoring (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    setup_analysis(@actant_sleepscoring, handles)


% --------------------------------------------------------------------
function menu_sleep_consensus_diary_Callback(hObject, eventdata, handles)
% hObject    handle to menu_sleep_consensus_diary (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_wake_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wake (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_wake_bins_Callback(hObject, eventdata, handles)
% hObject    handle to menu_wake_bins (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_rhythm_Callback(hObject, eventdata, handles)
% hObject    handle to menu_rhythm (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_rhythm_nonparam_Callback(hObject, eventdata, handles)
% hObject    handle to menu_rhythm_nonparam (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    setup_analysis(@actant_activity, handles)


% --------------------------------------------------------------------
function menu_entropy_Callback(hObject, eventdata, handles)
% hObject    handle to menu_entropy (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_entropy_sampen_Callback(hObject, eventdata, handles)
% hObject    handle to menu_entropy_sampen (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    setup_analysis(@actant_sampen, handles)


% --------------------------------------------------------------------
function menu_entropy_mse_Callback(hObject, eventdata, handles)
% hObject    handle to menu_entropy_mse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    setup_analysis(@actant_mse, handles)


% --------------------------------------------------------------------
function menu_help_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_help_about_Callback(hObject, eventdata, handles)
% hObject    handle to menu_help_about (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    about();


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Button
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on button press in pushbutton_analyze.
function pushbutton_analyze_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_analyze (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    analyze(handles);


% --- Executes on button press in pushbutton_update_plots.
function pushbutton_update_plots_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_update_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    update_plot(handles, 0);


% --- Executes on button press in pushbutton_export.
function pushbutton_export_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_export (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_plots_Callback(hObject, eventdata, handles)
% hObject    handle to edit_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_plots as text
%        str2double(get(hObject,'String')) returns contents of edit_plots as a double
    chknum(handles.edit_plots);


% --- Executes during object creation, after setting all properties.
function edit_plots_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_days_Callback(hObject, eventdata, handles)
% hObject    handle to edit_days (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_days as text
%        str2double(get(hObject,'String')) returns contents of edit_days as a double
    chknum(handles.edit_days);


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


function edit_overlap_Callback(hObject, eventdata, handles)
% hObject    handle to edit_overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_overlap as text
%        str2double(get(hObject,'String')) returns contents of edit_overlap as a double
    chknum(handles.edit_overlap);


% --- Executes during object creation, after setting all properties.
function edit_overlap_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_overlap (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_main_min_Callback(hObject, eventdata, handles)
% hObject    handle to edit_main_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_main_min as text
%        str2double(get(hObject,'String')) returns contents of edit_main_min as a double
    chknum(handles.edit_main_min);


% --- Executes during object creation, after setting all properties.
function edit_main_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_main_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_main_max_Callback(hObject, eventdata, handles)
% hObject    handle to edit_main_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_main_max as text
%        str2double(get(hObject,'String')) returns contents of edit_main_max as a double
    chknum(handles.edit_main_max);


% --- Executes during object creation, after setting all properties.
function edit_main_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_main_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_top_min_Callback(hObject, eventdata, handles)
% hObject    handle to edit_top_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_top_min as text
%        str2double(get(hObject,'String')) returns contents of edit_top_min as a double
    chknum(handles.edit_top_min);


% --- Executes during object creation, after setting all properties.
function edit_top_min_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_top_min (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


function edit_top_max_Callback(hObject, eventdata, handles)
% hObject    handle to edit_top_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_top_max as text
%        str2double(get(hObject,'String')) returns contents of edit_top_max as a double
    chknum(handles.edit_top_max);


% --- Executes during object creation, after setting all properties.
function edit_top_max_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit_top_max (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Popup
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes on selection change in popupmenu_dataset.
function popupmenu_dataset_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu_dataset contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu_dataset


% --- Executes during object creation, after setting all properties.
function popupmenu_dataset_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu_dataset (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main display screen
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% --- Executes during object creation, after setting all properties.
function uipanel_plot_CreateFcn(hObject, eventdata, handles)
% hObject    handle to uipanel_plot (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    global g_plot_handle;
    g_plot_handle = subplot(1, 1, 1, 'Parent', hObject);
    set(g_plot_handle, 'Visible', 'off');

    
% --- Executes on slider movement.
function slider_v_Callback(hObject, eventdata, handles)
% hObject    handle to slider_v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
    update_plot(handles, 1);


% --- Executes during object creation, after setting all properties.
function slider_v_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider_v (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --------------------------------------------------------------------
function menu_view_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_view_zoom_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view_zoom (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    f = handles.uipanel_plot;
    while ~isempty(f) & ~strcmp('figure', get(f,'type')),
        f = get(f, 'parent');
    end
    pan(f, 'off');
    zoom(f, 'on');
    set(handles.menu_view_pan, 'Checked', 'off');
    set(handles.menu_view_zoom, 'Checked', 'on');

% --------------------------------------------------------------------
function menu_view_pan_Callback(hObject, eventdata, handles)
% hObject    handle to menu_view_pan (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    f = handles.uipanel_plot;
    while ~isempty(f) & ~strcmp('figure', get(f,'type')),
        f = get(f, 'parent');
    end
    zoom(f, 'off');
    pan(f, 'on');
    set(handles.menu_view_zoom, 'Checked', 'off');
    set(handles.menu_view_pan, 'Checked', 'on');
