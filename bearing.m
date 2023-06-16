function [bearing] = bearing(filePath)
%BEARING generates bearing estimates from pulse files
%   This function generates bearing estimates from pulses within a pulse
%   file provided by the file path. If a bearing.csv file doesn't exists in
%   the same directory as the provided file path, it will generate the
%   bearing file. If a bearing file already exists, this function will read
%   the file and determine if a bearing estimate has already been made for
%   the provided filePath. If so, the function will replace that bearing in
%   the file. If not, the new bearing will be appended to the file. 
%
%INPUTS
%   filePath - a char array of the path the pulse file
%OUTPUTS
%   bearing - double of the bearing estimate in degrees from North
%
%   Note that this program also generates/modifies bearings.csv
%
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

coder.cinclude('stdio.h');%Needed for remove and move file commands

[pulseStructVec, ~] = readpulsecsv(filePath);

tagIDs   = [pulseStructVec(:).tagID];

tagID = uint32(0);%Define so coder knows types. 
tagID = uint32(mode(tagIDs, 'all')); %In case some other tags' pulses got into the dataset somehow. 
otherTagPulseInds = (tagIDs ~= tagID);
pulseStructVec = pulseStructVec(~otherTagPulseInds);

[bearing, tau] = doapca(pulseStructVec,'power','linear');

% if any(tagIDs ~= tagIDs(1))
%     fprintf('UAV-RT: All tags in pulse list file path must have the same tag ID integer')
%     bearing = NaN;
%     return
% else 
%     tagID = tagIDs(1);
% end

posVec  = [pulseStructVec(:).position];
timeVec = [pulseStructVec(:).time];

latitude_deg  = median([posVec(:).latitude_deg],'all');
longitude_deg = median([posVec(:).longitude_deg],'all');
alt_AGL_m     = median([posVec(:).relative_altitude_m],'all');
alt_ASL_m     = median([posVec(:).absolute_altitude_m],'all');
time_start_s  = min(timeVec,[],'all');
time_end_s    = max(timeVec,[],'all');

sepInds = strfind(filePath, filesep);

fileName = filePath(sepInds(end)+1:end);

fileDirectory = filePath(1:sepInds(end)-1);

bearingFilePath = [fileDirectory, filesep, 'bearings.csv'];

tempBearingFilePath = [fileDirectory, filesep, 'bearings_temp.csv'];

bearingFileAlreadyExists = isfile(bearingFilePath);

tag_id_fspec = '%u';
parentFileName_fspec = '%s';
bearing_fspec = '%f';
tau_fspec = '%f';
latitude_fspec = '%f';
longitude_fspec = '%f';
alt_AGL_fspec = '%f';
alt_ASL_fspec = '%f';
startTime_fspec = '%f';
endTime_fspec = '%f';

d = ',';

total_fspec = [tag_id_fspec, d, ...
               parentFileName_fspec, d, ...
               bearing_fspec, d, ...
               tau_fspec, d, ...
               latitude_fspec, d, ...
               longitude_fspec, d, ...
               alt_AGL_fspec, d, ...
               alt_ASL_fspec, d, ...
               startTime_fspec, d, ...
               endTime_fspec,'\n'];

currParentFileName = fileName;

if bearingFileAlreadyExists
    %Read bearing file and see if a bearing for this parent file has already been written
    %If so, append new estimate and remove the old ones - then rewrite the
    %bearing file contents
    %If not, simply append new bearing to the end of the entries. 
    
    [tableIn] = readbearingcsv(bearingFilePath);
    
    nTableInRows = size(tableIn, 1);

    %Logical vector - true for all entries with the same parent file as filepath
    alreadyInBearingList = false(nTableInRows,1);
    for i = 1:nTableInRows
        alreadyInBearingList(i) = strcmp(currParentFileName, tableIn.parentFileName{i});
    end
    
    %Build temp table with new entry and append to old table
    parentFileName = {''};%So coder knows the type
    parentFileName{1} = currParentFileName;
    
    variableNames = {'tagID','parentFileName','bearing','tau',...
                'latitude_deg','longitude_deg',...
                'alt_AGL_m','alt_ASL_m',...
                'time_start_s','time_end_s'};

    tableTemp = table(tagID,parentFileName, bearing, tau,...
                      latitude_deg, longitude_deg, ...
                      alt_AGL_m, alt_ASL_m,...
                      time_start_s, time_end_s, ...
                      'VariableNames', variableNames);
    tableOut = [tableIn;tableTemp];

    %Delete any entries that were from this file
    %Append false so we don't delete the entry we just added
    rowDeletionLogic = [alreadyInBearingList; false];
    rowKeepLogic = ~rowDeletionLogic;
    tableOut = tableOut(rowKeepLogic,:);
    
%     if any([alreadyInBearingList; false])
%         tableOut(alreadyInBearingList,:) = [];
%     end
    nTableOutRows = size(tableOut, 1);

    %Write out the table to the temp bearing file. 
    %We use a temp file so that if there is an error or system shutdown
    %during the write, we don't lose the original file. 
    fid = fopen(tempBearingFilePath,'w');
    for i = 1:nTableOutRows
        fprintf(fid, total_fspec, tableOut.tagID(i),...
                                  tableOut.parentFileName{i},...
                                  tableOut.bearing(i),...
                                  tableOut.tau(i), ...
                                  tableOut.latitude_deg(i), ...
                                  tableOut.longitude_deg(i), ...
                                  tableOut.alt_AGL_m(i), ...
                                  tableOut.alt_ASL_m(i), ...
                                  tableOut.time_start_s(i), ...
                                  tableOut.time_end_s(i));
    end

    fclose(fid);
    %Delete the original bearing file, then rename the temp as the primary
    %file
    if coder.target('MATLAB')
        [status1, cmdout1] = system(['rm "', bearingFilePath,'"']);
        [status2, cmdout2] = system(['mv "', tempBearingFilePath,'" "', bearingFilePath, '"']);
    else
        
        %retVal = coder.ceval('getcwd', coder.ref(untokenizedDir), 200);
        originalBearingPathStringinQuotes = bearingFilePath;% ['"', bearingFilePath,'"'];
        tempBearingPathStringinQuotes = tempBearingFilePath;%['"', tempBearingFilePath,'"'];
        status1 = int8(0);%Assigned so coder knowns expected data type. 
        status2 = int8(0);        
        status1 = coder.ceval('remove', coder.ref(originalBearingPathStringinQuotes));
        status2 = coder.ceval('rename', coder.ref(tempBearingPathStringinQuotes) , coder.ref(originalBearingPathStringinQuotes));
        cmdout1 = sprintf('%d',status1);
        cmdout2 = sprintf('%d',status2);
    end
    

    if status1~=0
        fprintf('UAV-RT: Unable to delete original bearing file. System reported: %s ', cmdout1);
        return
    end
    if status2~=0
        fprintf('UAV-RT: Unable to rename temp bearing file as primary bearing file. System reported: %s ', cmdout2);
        return
    end
else
    %Create the bearing file and print the data
    fid = fopen(bearingFilePath,'a');
    fprintf(fid, total_fspec, tagID, currParentFileName, bearing, tau,...
                              latitude_deg, longitude_deg, ...
                              alt_AGL_m, alt_ASL_m, ...
                              time_start_s, time_end_s);
    fclose(fid);

end

end