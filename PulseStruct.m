function pulse = PulseStruct(pos, euler, time, strength, freqMHz, tagID)
%PULSESTRUCT Generates a Pulse structure
%   This function generates a standard pulse structure with the
%   following fields:
%
%   position   Position as a PositionStruct
%   euler      Euler angles as a EulerAngleStruct
%   time       Time of received pulse in seconds
%   strength   Strength metric of received pulse
%   freqMHz    Frequency of received pulse in MHz
%   tagID      Tag ID number of received pulse

%   If input vectors are provided, they must be the same size size. In that
%   case, the output is a vector of structures.
%
%INPUTS:
%   position  -   n x 1 vector of positions (as PulseStructs)
%   euler     -   n x 1 vector of eulerangles (as EulerAngleStructs)
%   strength  -   n x 1 vector of pulse strength metrics (doubles)
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

localPosition = PositionStruct();
localEuler    = EulerAngleStruct();
localTime     = 0;
localStrength = 0;
localFreqMHz  = 0;
localTagID  = 0;

if nargin ~= 0 & nargin ~= 6
    fprintf('UAV-RT: Input to ReceivedPulse class must either be empty of contain 5 inputs. ')
    return
end

pulseInit.position = localPosition;
pulseInit.euler    = localEuler;
pulseInit.time     = localTime;
pulseInit.strength = localStrength;
pulseInit.freqMHz  = localFreqMHz;
pulseInit.tagID  = localTagID;

coder.varsize('pulse');
pulse = pulseInit;

if nargin > 0
    if ~all((size(pos) ==  size(euler)) | ...
            (size(pos) ==  size(time))  | ...
            (size(pos) ==  size(strength)) | ...
            (size(pos) ==  size(time)) | ...
            (size(pos) ==  size(tagID)))
        fprintf('UAV-RT: All inputs must be the same size. ')
        return
    end

    nRows = size(pos,1);
    nCols = size(pos,2);
    %pulse(nRows,nCols) = pulse; %Coder doesn't like this
    pulse = repmat(pulse,nRows,nCols);

    for i = 1:nRows
        for j = 1:nCols
            pulse(i,j).position = pos(i,j);
            pulse(i,j).euler = euler(i,j);
            pulse(i,j).time     = time(i,j);
            pulse(i,j).strength = strength(i,j);
            pulse(i,j).freqMHz  = freqMHz(i,j);
            pulse(i,j).tagID  = tagID(i,j);
        end
    end
    % pulse.position = pos;
    % pulse.euler    = euler;
    % pulse.time     = time;
    % pulse.strength = strength;
    % pulse.freqMHz  = freqMHz;

end
end

