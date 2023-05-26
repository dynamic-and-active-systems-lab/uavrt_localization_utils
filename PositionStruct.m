function [pos] = PositionStruct(lat, lon, altAbs, altRel)
%UNTITLED2 Construct an instance of this class
%   Detailed explanation goes here

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

