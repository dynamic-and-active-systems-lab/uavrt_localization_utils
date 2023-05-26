function command = CommandStruct(commandID, pos)
%UNTITLED Construct an instance of this class
%   Detailed explanation goes here
localPosition = PositionStruct();
%localTime     = 0;
localCommandID = 0;

if nargin ~= 0 & nargin ~= 2
    fprintf('UAV-RT: Input to ReceivedPulse class must either be empty of contain 2 inputs. ')
    return
end

commandInit.commandID = localCommandID;
%commandInit.time      = localTime;
commandInit.position  = localPosition;

coder.varsize('command');
command = commandInit;

if nargin > 0
    if ~all((size(pos) ==  size(commandID)) )
        fprintf('UAV-RT: All inputs must be the same size. ')
        return
    end

    nRows = size(pos,1);
    nCols = size(pos,2);
    %command(nRows,nCols) = command; %Coder doesn't like this
    command = repmat(command,nRows,nCols);

    for i = 1:nRows
        for j = 1:nCols
            command(i,j).position = pos(i,j);
            %command(i,j).time     = time(i,j);
            command(i,j).commandID = commandID(i,j);
        end
    end
    
end
end

