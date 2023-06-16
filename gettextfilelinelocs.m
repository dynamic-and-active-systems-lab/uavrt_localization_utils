function lineLocRecord = gettextfilelinelocs(fname)
%GETTEXTFILELINELOCS returns the locations in the a text file of the
%beginning of each line. Empty lines are not included in the listing.
%
%INPUTS:
%   fname - char array of file path to be read
%OUTPUTS:
%   lineLocRecord - 1 x n vector of locations of lines with text
%
%--------------------------------------------------------------------------
% Author: Michael Shafer
% Date: 2023-06-12
%--------------------------------------------------------------------------
%--------------------------------------------------------------------------
fid = fopen(fname, 'r');
assert(fid ~= -1, 'Could not read: %s', fname);
x = onCleanup(@() fclose(fid));
lineLocRecord = zeros(1,0);
coder.varsize('lineLocRecord', [1 inf], [0 1])
i = 1;
while ~feof(fid)
    lineLocRecord = [lineLocRecord, ftell(fid)];
    [lineStr] = fgetl(fid);
    if isempty(lineStr)
        lineLocRecord(i) = [];
    else
        i = i+1;
    end
end

end