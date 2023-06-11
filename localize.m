function [outputArg1,outputArg2] = localize(bearingFilePath,method)
%UNTITLED9 Summary of this function goes here
%   Detailed explanation goes here

[bearingTable] = readbearingcsv(bearingFilePath);
    
nBearings = size(bearingTable, 1);

bearingTable = sortrows(bearingTable,{'tagID','time_start_s'});

tagIDs = unique(bearingTable.tagID);

nTags = numel(tagIDs);

for i = 1:nTags
    currTagID = tagIDs(i);

    rowsOfCurrTagLogic = (currTagID == bearingTable.tagID);

    subTable = bearingTable(rowsOfCurrTagLogic, :);
    
    nCurrBearings = size(subTable, 1);
    
    if nCurrBearings > 1
        currLat = subTable.latitude_deg;
        currLon = subTable.longitude_deg;
        tempOriginLat = mean(currLat, "all");
        tempOriginLon = mean(currLon, "all");

        [xEast_m , yNorth_m, range_m, bearing_deg] = ...
            latlon2eastnorth(tempOriginLat, tempOriginLon,...
            currLat, currLon)
        
        positions = localizefrombearings(xEast_m,yNorth_m,bearing_deg,method)

        pause(1);
    end
end