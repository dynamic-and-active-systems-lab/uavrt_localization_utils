function [tableOut] = readbearingcsv(filePath)
%READBEARINGCSV Reads in a bearing csv file and outputs the file as a
%MATLAB table.
%   This function reads a bearing csv file and converts the file to a
%   MATLAB table wit the following headings:
%
%   1 - TagID
%   2 - Filename of parent pulse file 
%   3 - Bearing angle in degrees
%   4 - Tau value
%   5 - lat in deg
%   6 - lon in deg
%   7 - alt AGL in m
%   8 - alt ASL in m
%   9 - start time of bearing measurements in s
%   10 - end time of bearing measurements in s
%
%INPUTS:
%   filePath - char array of the path to the file
%
%OUPUTS:
%   tableOut - Matlab table with the columns specified above. 
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

fid = fopen(filePath,'r');

if fid ~= -1
    %nLines = countlines(filePath);
    lineLocs = gettextfilelinelocs(filePath);
    nLines = numel(lineLocs);
    
    tagID         = uint32(zeros(nLines,1));
    parentFileName = cell(nLines,1);
    %Initialize for coder
    for i = 1:nLines
        parentFileName{i} = '';
    end
    bearing        = zeros(nLines,1);
    tau            = zeros(nLines,1);
    latitude_deg   = zeros(nLines,1);
    longitude_deg  = zeros(nLines,1);
    alt_AGL_m      = zeros(nLines,1);
    alt_ASL_m      = zeros(nLines,1);
    time_start_s   = zeros(nLines,1);
    time_end_s     = zeros(nLines,1);
    

    %while ~feof(fid)
    for i = 1:nLines
        fseek(fid, lineLocs(i), 'bof');

        lineStr = fgetl(fid);
        commaInds = strfind(lineStr,',');
        
        tagID_inds          = 1 : commaInds(1)-1;
        parentFileName_inds = commaInds(1)+1 : commaInds(2)-1;
        bearing_inds        = commaInds(2)+1 : commaInds(3)-1;
        tau_inds            = commaInds(3)+1 : commaInds(4)-1;
        lat_inds            = commaInds(4)+1 : commaInds(5)-1;
        lon_inds            = commaInds(5)+1 : commaInds(6)-1;
        alt_AGL_inds        = commaInds(6)+1 : commaInds(7)-1;
        alt_ASL_inds        = commaInds(7)+1 : commaInds(8)-1;
        time_start_inds     = commaInds(8)+1 : commaInds(9)-1;
        time_end_inds       = commaInds(9)+1 : length(lineStr);

        tagID(i)          = uint32(real(str2double(lineStr(tagID_inds))));
        parentFileName{i} = lineStr(parentFileName_inds);
        bearing(i)        = real(str2double(lineStr(bearing_inds)));
        tau(i)            = real(str2double(lineStr(tau_inds)));
        latitude_deg(i)   = real(str2double(lineStr(lat_inds)));
        longitude_deg(i)  = real(str2double(lineStr(lon_inds)));
        alt_AGL_m(i)      = real(str2double(lineStr(alt_AGL_inds)));
        alt_ASL_m(i)      = real(str2double(lineStr(alt_ASL_inds)));
        time_start_s(i)   = real(str2double(lineStr(time_start_inds)));
        time_end_s(i)     = real(str2double(lineStr(time_end_inds)));

        %i = i+1;
    end
else
    fprintf('UAV-RT: Error opening the bearing csv file.')
    tagID = uint32(NaN);
    parentFileName = {'File not found'};
    bearing = NaN;
    tau = NaN;
    latitude_deg = NaN;
    longitude_deg = NaN;
    alt_AGL_m = NaN;
    alt_ASL_m = NaN;
    time_start_s = NaN;
    time_end_s = NaN;
end

variableNames = {'tagID','parentFileName','bearing','tau',...
                'latitude_deg','longitude_deg',...
                'alt_AGL_m','alt_ASL_m',...
                'time_start_s','time_end_s'};

tableOut = table(tagID, parentFileName, bearing,tau,...
                 latitude_deg, longitude_deg, alt_AGL_m, alt_ASL_m, ...
                 time_start_s, time_end_s,'VariableNames', variableNames);

end