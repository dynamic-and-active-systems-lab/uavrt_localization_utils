function [pulses, commands] = readpulsecsv(filepath)
%READPULSECSV Reads in a pulse csv file and outputs a vector of pulses in
%the file and any commands in the file.
%   This function reads a pulse csv file and converts the pulses and
%   commands in the csv to PulseStruct and CommandStructs. It returns a
%   vector of these structures.
%
%INPUTS:
%   filePath - char array of the path to the file
%
%OUPUTS:
%   pusles   - n x 1 vector of PulseStructs from the file
%   commands - n x 1 vector of CommandStructs from the file
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

%Initialize outputs so they are defined for all exectution paths.
pulses = PulseStruct();
commands = CommandStruct();


fid = fopen(filepath);

if fid == -1
    fprintf('UAV-RT: Error opening the bearing csv file. Returning empty pulse and command listings. ')

else
    %Close clean out any bad data, then reopen
    fclose(fid);
    cleancsv(filepath);
    fid = fopen(filepath);

    command_id_fspec                 = '%d';
    tag_id_fspec                     = '%d';
    freq_Hz_fspec                    = '%d';
    start_time_seconds_fspec         = '%f';
    predict_next_start_seconds_fspec = '%f';
    snr_fspec                        = '%f';
    stft_score_fspec                 = '%f';
    group_seq_counter_fspec          = '%f';
    group_in_fspec                   = '%f';
    group_snr_fspec                  = '%f';
    noise_psd_fspec                  = '%f';
    detection_status_fspec           = '%d';
    confirmed_status_fspec           = '%d';
    position_x_fspec                 = '%f';
    position_y_fspec                 = '%f';
    position_z_fspec                 = '%f';
    roll_fspec                       = '%f';
    pitch_fspec                      = '%f';
    yaw_fspec                        = '%f';
    empty_fspec                      = '%f';

    d = ',';%d for delimiter

    nPulseColumns = 20;
    nCommandColumns = 4;

    sizeArray = [nPulseColumns, Inf];

    pulseFormatSpec = [command_id_fspec, d, ...
        tag_id_fspec, d, ...
        freq_Hz_fspec, d, ...
        start_time_seconds_fspec, d, ...
        predict_next_start_seconds_fspec, d, ...
        snr_fspec, d, ...
        stft_score_fspec, d, ...
        group_seq_counter_fspec, d, ...
        group_in_fspec, d, ...
        group_snr_fspec, d, ...
        noise_psd_fspec, d, ...
        detection_status_fspec, d, ...
        confirmed_status_fspec, d, ...
        position_x_fspec, d, ...
        position_y_fspec, d, ...
        position_z_fspec, d, ...
        roll_fspec, d, ...
        pitch_fspec, d, ...
        yaw_fspec, d, ...
        empty_fspec, '\n'];

    commandFormatSpec = [command_id_fspec, d, ...
        position_x_fspec, d, ...
        position_y_fspec, d, ...
        position_z_fspec,'\n'];

    otherFormatSpec = '%s';


    numOfLines = countlines(filepath);
    % lineLocs = gettextfilelinelocs(filepath);
    % nLines = numel(lineLocs);

    pulseArray      = zeros(numOfLines, nPulseColumns);
    pulseLineNums   = zeros(numOfLines, 1);
    commandArray    = zeros(numOfLines, nCommandColumns);
    commandLineNums = zeros(numOfLines, 1);

    currLineNum = 1;
    currentLineFilePosition = ftell(fid);

    dataInd = 1;
    commandInd = 1;

    while ~feof(fid)
        lineStr = fgetl(fid);
        commaLocations = strfind(lineStr,',');
        commandID = str2double( lineStr(1 : (commaLocations(1)-1) ));

        if commandID == 7
            formatSpec = pulseFormatSpec;
        elseif commandID == 10 | commandID == 11
            formatSpec = commandFormatSpec;
        else
            formatSpec = otherFormatSpec;
        end

        seekStatus = fseek(fid, currentLineFilePosition, 'bof');

        if ~seekStatus
            if commandID == 7
                pulseArray(dataInd,:) = fscanf(fid, pulseFormatSpec,[1, nPulseColumns]);
                lineStr = fgetl(fid);
                currColumn = 1;
                pulseLineNums(dataInd) = currLineNum;
                dataInd = dataInd + 1;
            elseif commandID == 10 | commandID == 11
                commandArray(commandInd,:) = fscanf(fid, commandFormatSpec,[1, nCommandColumns]);
                commandLineNums(commandInd) = currLineNum;
                commandInd = commandInd + 1;
            else
                fgetl(fid); % Discard if not commandID 7, 10, or 11
            end
        else
            fprintf('UAV-RT: Error with file rewind');
            fclose(fid);
            return
        end

        currLineNum = currLineNum + 1;
        currentLineFilePosition = ftell(fid);


    end

    pulseArray(dataInd:end,:) = [];
    commandArray(commandInd:end,:) = [];
    pulseLineNums(dataInd:end) = [];
    commandLineNums(commandInd:end) = [];

    fclose(fid);

    %% Now format for table output
    command_id_col = 1;
    tag_id_col = 2;
    freq_Hz_col = 3;
    start_time_seconds_col = 4;
    predict_next_start_seconds_col = 5;
    snr_col = 6;
    stft_score_col = 7;
    group_seq_counter_col = 8;
    group_in_col = 9;
    group_snr_col = 10;
    noise_psd_col = 11;
    detection_status_col = 12;
    confirmed_status_col = 13;
    position_x_col = 14;
    position_y_col = 15;
    position_z_col = 16;
    roll_col = 17;
    pitch_col = 18;
    yaw_col = 19;
    empty_col = 20;

    snrdB = pulseArray(:, snr_col);
    negInds   = find( snrdB <= 0);
    infInds    = find(snrdB == Inf);
    negInfInds = find(snrdB == -Inf);

    %Command has the ASL alt when command was issued.
    if ~isempty(commandArray)
        alt_ASL_m_at_start = commandArray(1,4);
    else
        alt_ASL_m_at_start = NaN;
    end

    badInds = unique([negInds; infInds; negInfInds]);

    pulseArray(badInds, :) = [];

    snrdB = pulseArray(:, snr_col);

    tagID = pulseArray(:, tag_id_col);

    time     = pulseArray(:, start_time_seconds_col);

    time_next = pulseArray(:, predict_next_start_seconds_col);

    freq_MHz = pulseArray(:, freq_Hz_col)/1e6;

    stftMag2 = pulseArray(:, stft_score_col);

    groupSeqCount = pulseArray(:, group_seq_counter_col);

    groupIndex = pulseArray(:, group_in_col);

    groupsnrdB = pulseArray(:, group_snr_col);

    noisePSD = pulseArray(:, noise_psd_col);

    detectStatus = pulseArray(:, detection_status_col);

    confirmStatus = pulseArray(:, confirmed_status_col);

    lat = pulseArray(:, position_x_col);

    lon = pulseArray(:, position_y_col);

    %latMean = mean(lat);
    %lonMean = mean(lon);
    %origin = [latMean, lonMean];

    %quat = pulseArray(:,[orientation_w_col, orientation_x_col, orientation_y_col, orientation_z_col]);

    %eul_deg = 180/pi * quat2eul(quat);

    %Following the 3-2-1 rotation (z-y'-x'') rotation sequence
    % yaw_deg = eul_deg(:,1);
    % pitch_deg = eul_deg(:,2);
    % roll_deg = eul_deg(:,3);
    yaw_deg =  pulseArray(:, yaw_col);

    pitch_deg = pulseArray(:, pitch_col);

    roll_deg = pulseArray(:, roll_col);

    pos_AGL_m = pulseArray(:, position_z_col);

    elevation_of_GCS_m = alt_ASL_m_at_start - pos_AGL_m(1);

    pos_ASL_m = pos_AGL_m + elevation_of_GCS_m;

    positions = PositionStruct(lat, lon, pos_ASL_m, pos_AGL_m);

    eulers_deg = EulerAngleStruct(roll_deg, pitch_deg, yaw_deg);

    pulses = PulseStruct(tagID, freq_MHz, positions, eulers_deg, time, time_next, snrdB, stftMag2, groupSeqCount, groupIndex , groupsnrdB, noisePSD,detectStatus , confirmStatus);

    if ~isempty(commandArray)
        commandIDs    = commandArray(:,1);
        commandLats   = commandArray(:,2);
        commandLons   = commandArray(:,3);
        commandAltASL = commandArray(:,4);
        commandAltAGL = commandAltASL - elevation_of_GCS_m;
        commandPos    = PositionStruct(commandLats, commandLons,...
            commandAltASL, commandAltAGL);
    else
        commandIDs    = NaN;
        commandLats   = NaN;
        commandLons   = NaN;
        commandAltASL = NaN;
        commandAltAGL = NaN;
        commandPos    = PositionStruct(commandLats, commandLons,...
            commandAltASL, commandAltAGL);
    end


    commands = CommandStruct(commandIDs, commandPos);

end

end









