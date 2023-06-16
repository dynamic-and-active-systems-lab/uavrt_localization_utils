function eul = EulerAngleStruct(roll, pitch, yaw)
%EULERANGLESTRUCT Generates a Euler Angle structure
%   This function generates a standard Euler angle structure with the
%   following fields:
%
%   roll_deg    Roll angle in degrees
%   pitch_deg   Pitch angle in degrees
%   yaw_deg     Yaw angle in degrees

%   If input vectors are provided, they must be the same size size. In that
%   case, the output is a vector of structures.
%
%INPUTS:
%   roll  -   n x 1 vector of roll angles (doubles)
%   pitch -   n x 1 vector of pitch angles (doubles)
%   yaw   -   n x 1 vector of yaw angles (doubles)
%
%OUTPUTS:
%   eul    -   n x 1 vector of Euler angle structures
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------

localRoll   = 0;
localPitch  = 0;
localYaw    = 0;

if nargin ~= 0 & nargin ~= 3
    fprintf('UAV-RT: Input to Position class must either be empty of contain 3 inputs. ')
    return
end

eulInit.roll_deg             = localRoll;
eulInit.pitch_deg            = localPitch;
eulInit.yaw_deg              = localYaw;

coder.varsize('eul');
eul = eulInit;

if nargin>0
    if ~all((size(roll) ==  size(pitch)) | (size(roll) ==  size(yaw)) )
        fprintf('UAV-RT: All inputs must be the same size. ')
        return
    end
    
    nRows = size(roll,1);
    nCols = size(roll,2);
    %eul(nRows,nCols) = eul; %Coder doesn't like this
    eul = repmat(eul,nRows,nCols);

    for i = 1:nRows
        for j = 1:nCols
            eul(i,j).roll_deg  = roll(i,j);
            eul(i,j).pitch_deg = pitch(i,j);
            eul(i,j).yaw_deg   = yaw(i,j);
        end
    end
end

end

