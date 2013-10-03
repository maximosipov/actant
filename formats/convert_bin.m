function convert_bin
    % get file name
    [fn, fp] = uigetfile({'*.bin',...
        'GENEActiv BIN files (*.bin)'},...
        'Select the data file');
    if fp == 0,
        return;
    end
    
    % display message that conversion can take a while
    % option for different save folder
    sel = questdlg({'The time reuqired for conversion will depend on your'...
        'system specifications (CPU, RAM) and the file size. Please be patient.'},...
        'Convert',...
        'Cancel', 'Ok', 'Ok');
    
    if strcmpi(sel, 'Ok')
        [fp, fn, ext] = fileparts([fp fn]);  
    else
        return;
    end
    
    % display wait message
    h = msgbox('Please wait while data is being converted.', 'Converting...');
    
    % read .bin file and convert to .mat variables
    [header, time, xyz, light, button, prop_val] = read_bin([fp fn ext]);
    
    % convert variables to time series objects
    acc_x = timeseries(xyz(:,1), time, 'name', 'acc_x');
    acc_x.DataInfo.Unit = 'g';
    acc_y = timeseries(xyz(:,2), time, 'name', 'acc_y');
    acc_y.DataInfo.Unit = 'g';
    acc_z = timeseries(xyz(:,3), time, 'name', 'acc_z');
    acc_z.DataInfo.Unit = 'g';
    light = timeseries(light, time, 'name', 'light');
    light.DataInfo.Unit = 'lux';
    temp = timeseries(prop_val(:,2), time, 'name', 'temp');
    temp.DataInfo.Unit = 'degC';
    button = timeseries(button, time, 'name', 'button');
    button.DataInfo.Unit = 'binary';
    
    % save file
    save([fp fn '.mat'], 'acc_x', 'acc_y', 'acc_z', 'light',...
        'temp', 'button', 'header', '-v7.3');
    close(h)
end