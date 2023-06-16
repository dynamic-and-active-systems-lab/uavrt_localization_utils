function [pos] = PositionStruct(lat, lon, altAbs, altRel)
%POSITIONSTRUCT Generates a position structure
%   This function generates a standard position structure with the
%   following fields:
%
%   latitude_deg        Latitude in degrees
%   latitude_deg        Longitude in degrees
%   absolute_altitude_m Altitude in meters above ground level
%   relative_altitude_m Altitude in meters above sea level
%   
%   If input vectors are provided, they must be the same size size. In that
%   case, the output is a vector of position structures.
%
%INPUTS:
%   lat    -   n x 1 vector of doubles of latitudes
%   lon    -   n x 1 vector of doubles of longitudes
%   altAbs -   n x 1 vector of doubles of altitudes above sea level in
%              meters
%   altRel -   n x 1 vector of doubles of altitudes above ground level in
%              meters
%
%OUTPUTS:
%   pos    -   n x 1 vector of position structures
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


localLat    = 0;
localLon    = 0;
localAltAbs = 0;
localAltRel = 0;

if nargin ~= 0 & nargin ~= 4
    fprintf('UAV-RT: Input to Position class must either be empty of contain 4 inputs. ')
    return
end

posInit.latitude_deg         = localLat;
posInit.longitude_deg        = localLon;
posInit.absolute_altitude_m  = localAltAbs;
posInit.relative_altitude_m  = localAltRel;

coder.varsize('pos');
pos = posInit;

if nargin > 0
    if ~all((size(lat) ==  size(lon)) | (size(lat) ==  size(altAbs)) | (size(lat) ==  size(altRel)))
        fprintf('UAV-RT: All inputs must be the same size. ')
        return
    end
    
    nRows = size(lat,1);
    nCols = size(lat,2);
    %pos(nRows,nCols) = pos; %Coder doesn't like this
    pos = repmat(pos,nRows,nCols);
    for i = 1:nRows
        for j = 1:nCols
            pos(i,j).latitude_deg         = lat(i,j);
            pos(i,j).longitude_deg        = lon(i,j);
            pos(i,j).absolute_altitude_m  = altAbs(i,j);
            pos(i,j).relative_altitude_m  = altRel(i,j);
        end
    end
    % pos.latitude_deg         = lat;
    % pos.longitude_deg        = lon;
    % pos.absolute_altitude_m  = altAbs;
    % pos.relative_altitude_m  = altRel;
end

end

