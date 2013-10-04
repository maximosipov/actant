function convert_bin(fin, fout)
    % display message that conversion can take a while
    % option for different save folder
    sel = questdlg({'Epoch length will not be used for this conversion.'...
                    'The time reuqired for conversion will depend on your'...
                    'system specifications (CPU, RAM) and the file size.'...
                    'Please be patient.'},...
        'Convert',...
        'Cancel', 'Ok', 'Ok');
    
    if ~strcmpi(sel, 'Ok')
        return;
    end
    
    % display wait message
    h = msgbox('Please wait while data is being converted.', 'Converting...');
    
    % read .bin file and convert to .mat variables
    [header, time, xyz, light, button, prop_val] = read_bin(fin);
    
    % convert variables to time series objects
    acc_x = timeseries(xyz(:,1), time, 'Name', 'ACCX');
    acc_x.DataInfo.Unit = 'g';
    acc_y = timeseries(xyz(:,2), time, 'Name', 'ACCY');
    acc_y.DataInfo.Unit = 'g';
    acc_z = timeseries(xyz(:,3), time, 'Name', 'ACCZ');
    acc_z.DataInfo.Unit = 'g';
    light = timeseries(light, time, 'Name', 'LIGHT');
    light.DataInfo.Unit = 'lux';
    temp = timeseries(prop_val(:,2), time, 'Name', 'TEMP');
    temp.DataInfo.Unit = 'degC';
    button = timeseries(button, time, 'Name', 'BUTTON');
    button.DataInfo.Unit = 'binary';
    
    % save file
    save(fout, 'acc_x', 'acc_y', 'acc_z', 'light',...
        'temp', 'button', 'header', '-v7.3');
    close(h)
end