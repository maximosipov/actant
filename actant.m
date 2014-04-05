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

% Last Modified by GUIDE v2.5 05-Apr-2014 14:38:30

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


% --- Executes during object creation, after setting all properties.
function figure_main_CreateFcn(hObject, eventdata, handles)
% hObject    handle to figure_main (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called
    addpath('./formats');
    addpath('./sleep');
    %addpath('./wake');
    addpath('./rhythm');
    addpath('./other');
    addpath('./plot');

    %---------------------------------------------------------------------
    % Constant or internal data
    global g_file_types;
    global g_type_idx;
    global g_plot_handle;
    g_file_types = {
        '*.mat', 'Actant MAT files (*.mat)';...
        '*.awd', 'Actiwatch-L text files (*.awd)';...
        '*.csv', 'GENEActiv CSV files (*.csv)';...
        '*.bin', 'GENEActiv BIN files (*.bin)';...
        '*.csv', 'Actopsy CSV files (*.csv)'
    };
    g_type_idx = struct(...
        'actant_mat', 1, ...
        'actiwatch_awd', 2, ...
        'geneactiv_csv', 3, ...
        'geneactiv_bin', 4, ...
        'actopsy_csv', 5 ...
    );
    g_plot_handle = -1;

    %---------------------------------------------------------------------
    % Loadable context
    global actant_sources;
    global actant_datasets;
    global actant_plot;
    global actant_analysis;

    actant_sources = {};
    actant_datasets = {};
    actant_plot = struct(...
        'subs', 5, ...
        'days', 1, ...
        'overlap', 0, ...
        'main_lim', [], ...
        'top_lim', [] ...
    );
    actant_analysis = struct(...
        'method', '_', ...
        'args', [], ...
        'diary', [],...
        'results', [] ...
    );


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

    update_slider(handles, 0);


% --------------------------------------------------------------------
% Load dataset
function actant_open_dataset(fname, fi, handles)
    global g_type_idx;
    global actant_datasets;
    global actant_sources;
    
    % Load dataset
    if fi == g_type_idx.actiwatch_awd,
        h = waitbar(0, 'Please wait while the data is loaded...');
        data = load_actiwatch(fname);
        waitbar(1, h);
        close(h);
    elseif fi == g_type_idx.geneactiv_csv,
        h = waitbar(0, 'Please wait while the data is loaded...');
        data = load_geneactiv(fname);
        waitbar(1, h);
        close(h);
    elseif fi == g_type_idx.actant_mat,
        h = waitbar(0, 'Please wait while the data is loaded...');
        data = load(fname);
        waitbar(1, h);
        close(h);
    elseif fi == g_type_idx.actopsy_csv,
        h = waitbar(0, 'Please wait while the data is loaded...');
        data = load_actopsy(fname);
        waitbar(1, h);
        close(h);
    else
        errordlg('Format is not supported!', 'Error', 'modal');
        return;
    end
    
    % Update internal data
    n = length(actant_datasets);
    field_names = fieldnames(data);
    for i = 1:numel(field_names)
        tmp = getfield(data, char(field_names(i)));
        if strcmpi(class(tmp), 'timeseries')
            n = n + 1;
            actant_datasets{n} = tmp;
            actant_sources{n} = fname;
        end
    end


% --------------------------------------------------------------------
% Perform analysis
function actant_analyze(method, args, handles)
    global actant_sources;
    global actant_datasets;
    global actant_analysis;
    
    % Perform analysis
    h = waitbar(0, 'Please wait while analysis completes...');
    [data, actant_analysis.results] = method(args);
    waitbar(1, h);
    close(h);
    
    % Update internal state
    if ~isempty(data),
        n = length(actant_datasets);
        for i = 1:length(data),
            actant_datasets{n+i} = data{i};
            actant_sources{n+i} = func2str(method);
        end
    end


% --------------------------------------------------------------------
% Load datasets to UI
function actant_update_datasets(handles)
    global actant_datasets;
    global actant_sources;
    datasets = get(handles.uitable_data, 'Data');
    nums = {};
    for i = 1:length(actant_datasets),
        % If added new dataset, set Show field to No
        if i > size(datasets, 1),
            datasets{i, 1} = 'No';
        end
        datasets{i, 2} = [actant_datasets{i}.Name ' (' ...
                          actant_datasets{i}.DataInfo.Units ')'];
        datasets{i, 3} = datestr(min(actant_datasets{i}.Time));
        datasets{i, 4} = datestr(max(actant_datasets{i}.Time));
        datasets{i, 5} = actant_sources{i};
        nums{i} = num2str(i);
    end
    set(handles.uitable_data, 'Data', datasets);
    set(handles.popupmenu_dataset, 'String', nums);


% --------------------------------------------------------------------
% Update plot UI
function actant_update_plot(slide, handles)
    global actant_plot;
    if ~chknum(handles.edit_plots) || ~chknum(handles.edit_days) ||...
            ~chknum(handles.edit_overlap),
        return;
    end
    % get timeseries to display
    ts_main = get_plot_data('Main', handles);
    ts_top = get_plot_data('Top', handles);
    ts_markup = get_plot_data('Markup', handles);
    if isempty(ts_main),
        errordlg('Please select the main plot!', 'Error', 'modal');
        return;
    end
    % Update limits
    actant_update_limits(ts_main, ts_top, handles);
    % Update screen title
    title = ts_main.Name;
    if ~isempty(ts_top),
        title = [title ' : ' ts_top.Name];
    end
    if ~isempty(ts_markup),
        title = [title ' : ' ts_markup.Name];
    end
    set(handles.uipanel_plot, 'Title', title);
    % get plot start time
    if slide == 0,
        update_slider(handles, 1, floor(min(ts_main.Time)), floor(max(ts_main.Time)), 1);
    end
    start = floor(min(ts_main.Time));
    sval = get(handles.slider_v, 'Value');
    smax = get(handles.slider_v, 'Max');
    smin = get(handles.slider_v, 'Min');
    % Plot
    plot_days(handles.uipanel_plot, start + smax - sval,...
                actant_plot.subs, actant_plot.days, actant_plot.overlap,...
                ts_main, ts_top, ts_markup,...
                actant_plot.main_lim, actant_plot.top_lim);

    
% --------------------------------------------------------------------
% Update plot UI
function actant_update_limits(ts_main, ts_top, handles)
    global actant_plot;
    if ~isempty(ts_main),
        % Update limits
        if isempty(get(handles.edit_main_min, 'String')) ||...
                isempty(get(handles.edit_main_max, 'String')),
            actant_plot.main_lim = [min(min(ts_main.Data)) max(max(ts_main.Data))];
            set(handles.edit_main_min, 'String', num2str(actant_plot.main_lim(1)));
            set(handles.edit_main_max, 'String', num2str(actant_plot.main_lim(2)));
        elseif ~chknum(handles.edit_main_min) || ~chknum(handles.edit_main_max)
            return;
        end
        main_min = get(handles.edit_main_min, 'String');
        main_max = get(handles.edit_main_max, 'String');
        actant_plot.main_lim = [str2double(main_min) str2double(main_max)];
    end
    if ~isempty(ts_top),
        % Update limits
        if isempty(get(handles.edit_top_min, 'String')) ||...
                isempty(get(handles.edit_top_max, 'String')),
            actant_plot.top_lim = [min(min(ts_top.Data)) max(max(ts_top.Data))];
            set(handles.edit_top_min, 'String', num2str(actant_plot.top_lim(1)));
            set(handles.edit_top_max, 'String', num2str(actant_plot.top_lim(2)));
        elseif ~chknum(handles.edit_top_min) || ~chknum(handles.edit_top_max)
            return;
        end
        top_min = get(handles.edit_top_min, 'String');
        top_max = get(handles.edit_top_max, 'String');
        actant_plot.top_lim = [str2double(top_min) str2double(top_max)];
    end


% --------------------------------------------------------------------
% Update slider UI
function update_slider(handles, enable, first, last, step, handler)
    global actant_sources;
    if enable == 0 || size(actant_sources, 2) < 1,
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


% --------------------------------------------------------------------
% Get index of plot with specified display type
function ts = get_plot_data(show, handles)
    global actant_datasets;
    ts = [];
    dataset = get(handles.uitable_data, 'Data');
    for i=1:size(dataset, 1),
        if strcmp(dataset{i}, show),
            ts = actant_datasets{i};
            return;
        end
    end


% --------------------------------------------------------------------
% Check if edit control contains number
function status = chknum(h)
    status = false;
    str = get(h, 'String');
    val = str2double(str);
    if isnan(val) || ~isreal(val),
        set(h, 'BackgroundColor', [1 0 0]);
        uicontrol(h);
        status = false;
        errordlg('Value shall be numeric!', 'Error', 'modal');
    else
        set(h, 'BackgroundColor', [1 1 1]);
        status = true;
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
    global g_file_types;
    
    % Get file name
    [fn, fp, fi] = uigetfile(g_file_types, 'Select the data file');
    if fp == 0,
        return;
    end
    
    % Get and check data file
    fname = [fp fn];
    fhandle = fopen(fname, 'r');
    if fhandle == -1,
        errordlg(['Could not open file' fname], 'Error', 'modal');
        return;
    end
    fclose(fhandle);
    
    % Load data
    actant_open_dataset(fname, fi, handles);
    
    % Update datasets
    actant_update_datasets(handles);


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
function menu_sleep_analysis_Callback(hObject, eventdata, handles)
% hObject    handle to menu_sleep_analysis (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global actant_datasets;
    global actant_sources;
    global actant_plot;
    global actant_analysis;
    
    % set analysis label
    actant_analysis.method = 'actant_oakley';
    
    % specify values
    vals = {};
    vals{1,1} = 'Algorithm';   vals{1, 2} = 'oakley';
    vals{2,1} = 'ts_data';     vals{2, 2} = '1';
    vals{3,1} = 'Method';      vals{3, 2} = 'i';
    vals{4,1} = 'Sensitivity'; vals{4, 2} = 'm';
    vals{5,1} = 'Snooze';      vals{5, 2} = 'on';
    vals{6,1} = 'Time window'; vals{6, 2} = 10; 
    actant_analysis.args = vals;
    
    % update the main GUI and store variabeles
    set(handles.uitable_analysis, 'Data', actant_analysis.args);
    
    setappdata(0, 'actant_datasets', actant_datasets);
    setappdata(0, 'actant_sources', actant_sources);
    setappdata(0, 'actant_plot', actant_plot);
    setappdata(0, 'actant_analysis', actant_analysis); 
    
    % open the sleep consensus diary UI
    sleep_consensus_diary()

    actant_datasets = getappdata(0, 'actant_datasets');
    actant_sources = getappdata(0, 'actant_sources');
    actant_plot = getappdata(0, 'actant_plot');
    actant_analysis = getappdata(0, 'actant_analysis');


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
    global actant_analysis;
    actant_analysis.method = 'actant_activity';
    [~, actant_analysis.args] = actant_activity();
    set(handles.uitable_analysis, 'Data', actant_analysis.args);


% --------------------------------------------------------------------
function menu_rhythm_l5m10_Callback(hObject, eventdata, handles)
% hObject    handle to menu_rhythm_l5m10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global actant_analysis;
    actant_analysis.method = 'actant_l5m10';
    [~, actant_analysis.args] = actant_l5m10();
    set(handles.uitable_analysis, 'Data', actant_analysis.args);


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
    global actant_analysis;
    actant_analysis.method = 'actant_sampen';
    [~, actant_analysis.args] = actant_sampen();
    set(handles.uitable_analysis, 'Data', actant_analysis.args);


% --------------------------------------------------------------------
function menu_entropy_mse_Callback(hObject, eventdata, handles)
% hObject    handle to menu_entropy_mse (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global actant_analysis;
    actant_analysis.method = 'actant_mse';
    [~, actant_analysis.args] = actant_mse();
    set(handles.uitable_analysis, 'Data', actant_analysis.args);


% --------------------------------------------------------------------
function menu_rhythm_nonparam_w_Callback(hObject, eventdata, handles)
% hObject    handle to menu_rhythm_nonparam_w (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --------------------------------------------------------------------
function menu_entropy_sampen_w_Callback(hObject, eventdata, handles)
% hObject    handle to menu_entropy_sampen_w (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global actant_analysis;
    actant_analysis.method = 'actant_sampen_w';
    [~, actant_analysis.args] = actant_sampen_w();
    set(handles.uitable_analysis, 'Data', actant_analysis.args);


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
    global actant_datasets;
    global actant_analysis;
    global actant_sources;
    
    % Get arguments
    actant_analysis.args = get(handles.uitable_analysis, 'Data');

    % Check if method is defined
    if strcmp(actant_analysis.method, '_'),
        errordlg('Please select analysis method!', 'Error', 'modal');
        return;
    end
    
    % Convert timeseries index into object
    for i=1:length(actant_analysis.args(:,1)),
        if strncmpi(actant_analysis.args{i,1}, 'ts_', 3),
            try
                n = str2num(actant_analysis.args{i,2});
                actant_analysis.args{i,2} = actant_datasets{n};
            catch ME
                % Give more information for mismatch.
                if (strcmp(ME.identifier,'MATLAB:badsubscript'))
                    errordlg('Please select a valid dataset!', 'Error', 'modal');
                    return
                end
            end
        end
    end

    % Perform analysis
    if strcmpi(actant_analysis.method, 'actant_oakley')
        % get additional args from Sleep Consensus Diary
        %args2 = get(handles.uitable_results, 'Data');
        %args2 = actant_analysis.diary
        [ts actant_analysis.results] = actant_oakley(actant_analysis.args, actant_analysis.diary);

        % Update internal state
        if ~isempty(ts),
            n = length(actant_datasets);
            for i = 1:length(ts),
                actant_datasets{n+i} = ts(i);
                actant_sources{n+i} = 'actant_oakley';
            end
        end
    else
        method = str2func(actant_analysis.method);    
        args = actant_analysis.args;
        actant_analyze(method, args, handles);
    end

    % Update datasets table
    actant_update_datasets(handles);

    % Update results table
    set(handles.uitable_results, 'Data', actant_analysis.results);


% --- Executes on button press in pushbutton_s.
function pushbutton_update_plots_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton_update_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    actant_update_plot(0, handles);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Edit
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
function edit_plots_Callback(hObject, eventdata, handles)
% hObject    handle to edit_plots (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit_plots as text
%        str2double(get(hObject,'String')) returns contents of edit_plots as a double
    global actant_plot;
    if chknum(handles.edit_plots), 
        val = get(handles.edit_plots, 'String');
        actant_plot.subs = str2double(val);
    end


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
    global actant_plot;
    if chknum(handles.edit_days),
        val = get(handles.edit_days, 'String');
        actant_plot.days = str2double(val);
    end


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
    global actant_plot;
    if chknum(handles.edit_overlap),
        val = get(handles.edit_overlap, 'String');
        actant_plot.overlap = str2double(val);
    end


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
    if ~isempty(get(handles.edit_main_min, 'String')),
        chknum(handles.edit_main_min);
    end


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
    if ~isempty(get(handles.edit_main_max, 'String')),
        chknum(handles.edit_main_max);
    end


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
    if ~isempty(get(handles.edit_top_min, 'String')),
        chknum(handles.edit_top_min);
    end


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
    if ~isempty(get(handles.edit_top_max, 'String')),
        chknum(handles.edit_top_max);
    end


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
    actant_update_plot(1, handles);


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


% --------------------------------------------------------------------
function file_menu_load_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu_load (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global actant_datasets;
    global actant_sources;
    global actant_plot;
    global actant_analysis;
    global g_file_types;
    global g_type_idx;
    % Load input file
    [fn, fp, fi] = uigetfile(g_file_types(g_type_idx.actant_mat,:),...
        'Select data file');
    if fp == 0,
        return;
    end
    file = [fp fn];
    load(file, 'actant_datasets', 'actant_sources', 'actant_plot', 'actant_analysis');

    % Update GUI
    actant_update_datasets(handles);
    set(handles.edit_plots, 'String', num2str(actant_plot.subs));
    set(handles.edit_days, 'String', num2str(actant_plot.days));
    set(handles.edit_overlap, 'String', num2str(actant_plot.overlap));
    if length(actant_plot.main_lim) > 1,
        set(handles.edit_main_min, 'String', num2str(actant_plot.main_lim(1)));
        set(handles.edit_main_max, 'String', num2str(actant_plot.main_lim(2)));
    end
    if length(actant_plot.top_lim) > 1,
        set(handles.edit_top_min, 'String', num2str(actant_plot.top_lim(1)));
        set(handles.edit_top_max, 'String', num2str(actant_plot.top_lim(2)));
    end
    set(handles.uitable_analysis, 'Data', actant_analysis.args);
    set(handles.uitable_results, 'Data', actant_analysis.results);


% --------------------------------------------------------------------
function file_menu_save_Callback(hObject, eventdata, handles)
% hObject    handle to file_menu_save (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
    global actant_datasets;
    global actant_sources;
    global actant_plot;
    global actant_analysis;
    global g_file_types;
    global g_type_idx;
    % Select output file
    [fn, fp, fi] = uiputfile(g_file_types(g_type_idx.actant_mat,:),...
        'Select data file');
    if fp == 0,
        return;
    end
    file = [fp fn];
    save(file, 'actant_datasets', 'actant_sources', 'actant_plot',...
        'actant_analysis', '-v7.3');
