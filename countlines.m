function count = countlines(fname)
%Based on https://stackoverflow.com/questions/12176519/is-there-a-way-in-matlab-to-determine-the-number-of-lines-in-a-file-without-loop
%Updated to not count multiple new lines after valid text in a line
%Also uses fgetl to read lines so the final line doesn't need a final \n
%character to get counted. 

    fid = fopen(fname, 'r');
    assert(fid ~= -1, 'Could not read: %s', fname);
    x = onCleanup(@() fclose(fid));
    count = 0;
    % while ~feof(fid)
    %     count = count + sum( fread( fid, 16384, 'char' ) == char(10) );
    % end
    emptyLineCounter = 0;
    while ~feof(fid)
        [lineStr] = fgetl(fid);
        if isempty(lineStr)
            emptyLineCounter = emptyLineCounter + 1;
        else
            emptyLineCounter = 0;
        end
        count = count + 1;
    end
    count = count - emptyLineCounter;
end