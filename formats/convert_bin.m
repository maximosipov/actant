function status = convert_bin(fin, fout)
    status = false;
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

    actant_datasets{1} = acc_x;
    actant_datasets{2} = acc_y;
    actant_datasets{3} = acc_z;
    actant_datasets{4} = light;
    actant_datasets{5} = temp;
    actant_datasets{6} = button;
    actant_sources{1} = fin;
    actant_sources{2} = fin;
    actant_sources{3} = fin;
    actant_sources{4} = fin;
    actant_sources{5} = fin;
    actant_sources{6} = fin;

    % save file
    save(fout, 'actant_datasets', 'actant_sources',...
        'acc_x', 'acc_y', 'acc_z', 'light',...
        'temp', 'button', 'header', '-v7.3');
    close(h)
    status = true;
end