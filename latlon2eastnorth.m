function [xEast_m , yNorth_m, range_m, bearing_deg] = latlon2eastnorth(lat1, lon1, lat2, lon2)
%LATLON2EASTNORTH Convert listings of latitudes and longitudes to a
%cartesian grid of east-north in meters.
%   This functions will provide a the position in meters of the lat/lon
%   positions provided as the second set of inputs relative the single
%   lat/lon primary position entry based on the Vicenty distance equation. 
%
%INPUTS:
%   lat1 - 1 x 1 latitude of origin 
%   lon1 - 1 x 1 longitude of origin 
%   lat2 - n x 1 latitude vector of positions to measure to
%   lon2 - n x 1 longitude vector of positions to measure to
%
%OUTPUTS:
%   xEast_m     - n x 1 Position in meters East of the lat/lon2 entries
%                 from the origin position
%   yNorth_m    - n x 1 Position in meters North of the lat/lon2 entries
%                 from the origin position
%   range_m     - n x 1 range in meters of the lat/lon2 entries
%                 from the origin position
%   bearing_deg - n x 1 bearing angle degrees off true North of the 
%                 lat/lon2 entries from the origin position
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

nSecondary = numel(lat2);
xEast_m  = zeros(nSecondary, 1);
yNorth_m = zeros(nSecondary, 1);
range_m  = zeros(nSecondary, 1);
bearing_deg= zeros(nSecondary, 1);

if numel(lat1)~=1 | numel(lon1)~=1 
    fprintf('UAV-RT: Only one lat and lon allowed for pimary position.')
    return
end
if numel(lat2) ~= numel(lon2)
    fprintf('UAV-RT: Secondary latitudes must have name number of elements as secondary longitudes.')
    return
end

lat2 = reshape(lat2, nSecondary,1);
lon2 = reshape(lon2, nSecondary,1);



for i = 1:nSecondary
    currLat2 = lat2(i);
    currLon2 = lon2(i);

    %X east
    theSignEast  = sign(angdiff(lon1, currLon2));
    theSignNorth = sign(angdiff(lat1, currLat2));
    xEast_m(i)   = theSignEast  * vincentydistance(lat1, lon1, lat1, currLon2);
    yNorth_m(i)  = theSignNorth * vincentydistance(lat1, lon1, currLat2, lon1);
    %range1  = sqrt( xEast^2 + yNorth^2 );
    %bearing_deg = 180/pi * atan2(xEast, yNorth);
    range_m(i)  = vincentydistance(lat1, lon1, currLat2, currLon2);

    %Calculate bearing from 1 to 2
    X = cosd(currLat2)*sind(currLon2-lon1);
    Y = cosd(lat1)*sind(currLat2) - sind(lat1)* cosd(currLat2)*cosd(currLon2-lon1);
    bearing_deg(i) = 180/pi * atan2(X,Y);
    %rangecheck = (range1-range)/range
end

end