function [lats2, lons2] = vincentyendpoint(lat1, lon1, bearings, ranges)
%VICENTYENDPOINT calculates the latitude and longitude from one position
% to another based on the second positions range and bearing using the
%   the Vicenty formulea method.
%   Inputs are in degrees
%
%INPUTS:
%   lat1 - 1 x 1 latitude of position 1 in degrees
%   lon1 - 1 x 1 longitude of position 1 in degrees
%   bearing - n x 1 compass bearing in degrees from North to position 2
%   range - n x 1 range in meters to position 2 
%
%OUPUTS:
%   lat2 - n x 1 latitudes of position 2 in degrees
%   lon2 - n x 1 longitudes of position 2 in degrees
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-21
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


%Using WGS-84
% lat1 = 35 + 10/60 + 24.75/3600;
% lon1 = -111 + 39/60 + 29.11/3600;
%
% lat2 = 35 + 10/60 + 24.82/3600;
% lon2 = -111 + 39/60 + 24.80/3600;

%s is the ellipsoidal distance between the two points;


nPoints = numel(bearings);
if numel(ranges) ~= nPoints
    fprinf('UAV-RT: Number of bearings and ranges must be equal')
    return
end

if numel(lat1)~=1 | numel(lon1)~=1 
    fprinf('UAV-RT: Number of reference latitudes and longitudes must be one.')
    return
end

bearings = bearings(:);

ranges = ranges(:);

lats2 = zeros(size(bearings));

lons2 = zeros(size(bearings));

%Length of semi-major axis of the ellipsoid (radius at equator);
a = 6378137.0;
%Flattening of the ellipsoid;
f = 1/298.257223563;
%Length of semi-minor axis of the ellipsoid (radius at the poles);
b = 6356752.314245; %(1-f)a
%Latitude of the points;
phi1 = lat1 * pi/180;
%Longitude of the points;
L1 = lon1 * pi/180;
%Reduced latitude (latitude on the auxiliary sphere)
U1 = atan((1-f)*tan(phi1));

for j = 1:nPoints
    %Using same variables as documentation
    s = ranges(j);

    alpha1 = bearings(j) * pi/180;
    
    %Angular Separation between point 1 and the equator
    sigma1 = atan2(tan(U1), cos(alpha1));
    
    sinAlpha = cos(U1)*sin(alpha1);
    
    cosAlphaSquared = 1 - sinAlpha^2;
    
    uSquared = (1-sinAlpha^2) * ((a^2 - b^2) / b^2);
    
    A = 1 + uSquared/16384 * (4096 + uSquared*(-768 + uSquared*(320 - 175*uSquared)));
    
    B = uSquared/1024 * ( 256 + uSquared * (-128 + uSquared*(74 - 47*uSquared) ) );
    
    sigmaNew = s/(b*A);
    
    i = 1;
    
    residual = 1;
    
    % figure
    twoSigmaM  = NaN;
    deltaSigma = NaN; 
    sigma = NaN;
    while residual > 10^-12
    
        sigma = sigmaNew;
    
        twoSigmaM = 2*sigma1 + sigma;
        
        deltaSigma = B*sin(sigma)*(cos(twoSigmaM)+1/4*B*(...
                     cos(sigma)*(-1+2*cos(twoSigmaM)^2)-...
                     B/6*cos(twoSigmaM)*(-3+4*sin(sigma)^2)*...
                     (-3+4*cos(twoSigmaM)^2)));
        
        sigmaNew = s/(b*A) + deltaSigma;
        
        residual = (sigmaNew - sigma)/sigma;
        
        i = i+1;
        % plot(i, residual,'.'); hold on;
        % drawnow
    end
    
    sigmaM = twoSigmaM/2;
    
    arg1 = sin(U1)*cos(sigma)+cos(U1)*sin(sigma)*cos(alpha1);
    
    arg2 = (1-f)*sqrt(sinAlpha^2 + (sin(U1)*sin(sigma)-cos(U1)*cos(sigma)*cos(alpha1))^2);
    
    phi2 = atan2(arg1, arg2);
    
    lam  = atan2(sin(sigma)*sin(alpha1),...
                 cos(U1)*cos(sigma)-sin(U1)*sin(sigma)*cos(alpha1));
    
    C = f/16*cosAlphaSquared*(4 + f * (4-3*cosAlphaSquared));
    
    L = lam - (1 - C) * f * sinAlpha * (sigma + C * sin(sigma)*(...
        cos(2*sigmaM) + C * cos(sigma)*(-1 + 2 * cos(2*sigmaM)^2)));
    
    L2 = L + L1;
    %alpha2 = atan2(sinAlpha1,...
    %               -sin(U1)*sin(sigma)+cos(U1)*cos(sigma)*cos(alpha1));
    
    lons2(j) = L2 * 180/pi;
    
    lats2(j) = phi2 * 180/pi;
end

end