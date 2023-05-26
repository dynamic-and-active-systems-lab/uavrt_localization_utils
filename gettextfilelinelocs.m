function lineLocRecord = gettextfilelinelocs(fname)

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