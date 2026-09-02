function pulse = PulseStruct(tagID, freqMHz, lat, lon, altAGL, roll, pitch, yaw, time, timeNext, snrdB, stftMag2, groupSeqCount, groupIndex, groupsnrdB, noisePSD,detectStatus , confirmStatus, antennaOffset)

%PULSESTRUCT Generates a Pulse structure
%   This function generates a standard pulse structure with the
%   following fields:
%
%   position   Position as a PositionStruct
%   euler      Euler angles as a EulerAngleStruct
%   time       Time of received pulse in seconds
%   time_next  Expected time of next pulse
%   snrdB        Pulse signal to noise ratio in dB
%   freqMHz    Frequency of received pulse in MHz
%   tagID      Tag ID number of received pulse

%   If input vectors are provided, they must be the same size size. In that
%   case, the output is a vector of structures.
%
%INPUTS:
%   pos       -   n x 1 vector of positions (as PulseStructs)
%   euler     -   n x 1 vector of eulerangles (as EulerAngleStructs)
%   time      -   n x 1 vector of time of arrival of pulse
%   timeNext  -   n x 1 vector of predicted time of arrival of next pulse
%   snrdB     -   n x 1 vector of pulse snr  (doubles)
%   freqMHz   -   n x 1 vector of pulse frequencies in MHz (doubles)
%   tagID     -   n x 1 vector of pulse tag IDs (doubles)
%
%OUTPUTS:
%   pulse   -   n x 1 vector of pulse structures
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

% localPosition = PositionStruct();
% localEuler    = EulerAngleStruct();
localLat    = 0;
localLon    = 0;
localAltAGL = 0;
localRoll    = 0;
localPitch    = 0;
localYaw = 0;
localTime     = 0;
localSNR = 0;
localStftMag2 = 0;
localGroupSeqCount = 0;
localGroupIndex = 0;
localGroupSNRdB = 0;
localNoisePSD = 0;
localDetectionStatus = false;
localConfirmationStatus = false;
localAntennaOffset = 0;

localFreqMHz  = 0;
localTagID  = 0;

if nargin ~= 0 & nargin ~= 19
    fprintf('UAV-RT: Input to ReceivedPulse class must either be empty of contain 15 inputs. ')
    return
end

pulseInit.tagID    = localTagID;
pulseInit.freqMHz  = localFreqMHz;
pulseInit.time     = localTime;
pulseInit.timeNext = localTime;
pulseInit.snrdB    = localSNR;
pulseInit.stftMag2 = localStftMag2;
pulseInit.groupSeqCount = localGroupSeqCount;
pulseInit.groupIndex   = localGroupIndex;
pulseInit.groupsnrdB   = localGroupSNRdB;
pulseInit.noisePSD = localNoisePSD;
pulseInit.detectStatus = localDetectionStatus;
pulseInit.confirmStatus = localConfirmationStatus;
% pulseInit.position = localPosition;
% pulseInit.euler    = localEuler;
pulseInit.lat  = localLat;
pulseInit.lon = localLon;
pulseInit.AltAGL = localAltAGL;
pulseInit.roll = localRoll;
pulseInit.pitch = localPitch;
pulseInit.yaw = localYaw;

pulseInit.antennaOffset = localAntennaOffset;



coder.varsize('pulse');
pulse = pulseInit;

if nargin > 0
    if ~all((size(lat) ==  size(freqMHz)) | ...
            (size(lat) ==  size(tagID))| ... %(size(lat) ==  size(euler)) | ...
            (size(lat) ==  size(time))  | ...
            (size(lat) ==  size(timeNext))  | ...
            (size(lat) ==  size(snrdB)) | ...
            (size(lat) ==  size(stftMag2)) | ...
            (size(lat) ==  size(groupSeqCount)) | ...
            (size(lat) ==  size(groupIndex)) | ...
            (size(lat) ==  size(groupsnrdB)) | ...
            (size(lat) ==  size(noisePSD)) | ...
            (size(lat) ==  size(detectStatus)) | ...
            (size(lat) ==  size(detectStatus)) | ...
            (size(lat) ==  size(confirmStatus)) | ...
            (size(lat) ==  size(lon)) | ...
            (size(lat) ==  size(altAGL)) | ...
            (size(lat) ==  size(roll)) | ...
            (size(lat) ==  size(pitch)) | ...
            (size(lat) ==  size(yaw)) | ...
            (size(lat) ==  size(antennaOffset)))
        fprintf('UAV-RT: All inputs must be the same size. ')
        return
    end

    nRows = size(lat,1);
    nCols = size(lat,2);
    %pulse(nRows,nCols) = pulse; %Coder doesn't like this
    pulse = repmat(pulse,nRows,nCols);

    for i = 1:nRows
        for j = 1:nCols
            pulse(i,j).tagID  = tagID(i,j);
            pulse(i,j).freqMHz  = freqMHz(i,j);
            pulse(i,j).time     = time(i,j);
            pulse(i,j).timeNext = timeNext(i,j);
            pulse(i,j).snrdB    = snrdB(i,j);
            pulse(i,j).stftMag2    = stftMag2(i,j);
            pulse(i,j).groupSeqCount    = groupSeqCount(i,j);
            pulse(i,j).groupIndex    = groupIndex(i,j);
            pulse(i,j).groupsnrdB    = groupsnrdB(i,j);
            pulse(i,j).noisePSD    = noisePSD(i,j);
            pulse(i,j).detectStatus  = logical(detectStatus(i,j));
            pulse(i,j).confirmStatus = logical(confirmStatus(i,j));
            % pulse(i,j).position = pos(i,j);
            % pulse(i,j).euler    = euler(i,j);
            pulse(i,j).lat = lat(i,j);
            pulse(i,j).lon = lon(i,j);
            pulse(i,j).altAGL = altAGL(i,j);
            pulse(i,j).roll = roll(i,j);
            pulse(i,j).pitch = pitch(i,j);
            pulse(i,j).yaw = yaw(i,j);
            pulse(i,j).antennaOffset  = antennaOffset(i,j);
           
        end
    end
    
end
end

