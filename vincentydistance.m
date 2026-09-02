function [s] = vincentydistance(lat1, lon1, lat2, lon2)
%VICENTYDISTANCE calculates the distance in meters between two points using
%the Vicenty formulea method.
%   Inputs are in degrees
%
%INPUTS:
%   lat1 - 1 x 1 latitude of position 1 in degrees
%   lon1 - 1 x 1 longitude of position 1 in degrees
%   lat2 - 1 x 1 latitude of position 2 in degrees
%   lon2 - 1 x 1 longitude of position 2 in degrees
%
%OUPUTS:
%   s - 1 x 1 distance in meters between the two positions
%
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------


if lat1 == lat2 & lon1 == lon2
    s = 0;
else

    %Using WGS-84
    %Test points
    % lat1 = 35.174505555555555; %35 + 10/60 + 28.22/3600;
    % lon1 = 111.6576666666667; % 111+ 39/60 + 27.60/3600;
    %
    % lat2 = 35.174511111111109;    % 35 + 10/60 + 28.24/3600;
    % lon2 = 111.6563944444444; % 111+ 39/60 + 23.02/3600;
    %
    % mapDist = 115.97;

    %s is the ellipsoidal distance between the two points;

    %Length of semi-major axis of the ellipsoid (radius at equator);
    a = 6378137.0;
    %Flattening of the ellipsoid;
    f = 1/298.257223563;
    %Length of semi-minor axis of the ellipsoid (radius at the poles);
    b = 6356752.314245; %(1-f)a
    %Latitude of the points;
    phi1 = lat1 * pi/180;
    phi2 = lat2 * pi/180;
    %Reduced latitude (latitude on the auxiliary sphere)
    U1 = atan((1-f)*tan(phi1));
    U2 = atan((1-f)*tan(phi2));
    %Longitude of the points;
    L1 = lon1 * pi/180;
    L2 = lon2 * pi/180;
    %Difference in longitude of two points;
    L = L2 - L1;

    lamNew = L;
    i = 1;
    residual = 1;
    cosAlphaSquared = NaN;
    sinSigma        = NaN;
    cos2Sigma_m     = NaN;
    cosSigma        = NaN;
    sigma           = NaN;
    % figure
    while residual > 10^-12
        lam = lamNew;
        sinSigma = sqrt((cos(U2)*sin(lam))^2 +...
            (cos(U1)*sin(U2) - sin(U1)*cos(U2)*cos(lam) )^2);

        cosSigma = sin(U1) * sin(U2) + cos(U1) * cos(U2) * cos(lam);

        sigma = atan2(sinSigma, cosSigma);

        sinAlpha = (cos(U1) * cos(U2) * sin(lam))/sinSigma;

        cos2Sigma_m = cosSigma - ( 2*sin(U1)*sin(U2) ) / (1 - sinAlpha^2);

        cosAlphaSquared = 1 - sinAlpha^2;

        C = f/16 * cosAlphaSquared * (4 - f * (4 - 3*cosAlphaSquared));

        lamNew = L + (1 - C)*f*sinAlpha*( sigma + C*sinSigma*(...
            cos2Sigma_m + C*cosSigma*(-1 + 2*cos2Sigma_m^2)));

        residual = (lamNew - lam)/lam;
        i = i+1;
        % plot(i, residual,'.'); hold on;
        % drawnow
    end

    uSquared = cosAlphaSquared * ((a^2 - b^2) / b^2);
    A = 1 + uSquared/16384 * (4096 + uSquared*(-768 + uSquared*(320 - 175*uSquared)));
    B = uSquared/1024 * ( 256 + uSquared * (-128 + uSquared*(74 - 47*uSquared) ) );
    deltaSigma = B * sinSigma * (cos2Sigma_m + 1/4*B*(...
        cosSigma*(-1 + 2*cos2Sigma_m^2) - B/6 * cos2Sigma_m * (-3-4*sinSigma)*(-3+4*cos2Sigma_m^2)));
    s = b*A*(sigma-deltaSigma);
    % alpha1 = atan2(cos(U2)*sin(lam),...
    %     cos(U1)*sin(U2)-sin(U1)*cos(U2)*cos(lam));
    % alpha2 = atan2(cos(U1)*sin(lam),...
    %     -sin(U1)*cos(U2)+cos(U1)*sin(U2)*cos(lam));

end
end