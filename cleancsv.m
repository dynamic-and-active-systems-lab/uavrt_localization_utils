function [] = cleancsv(filePath)
%CLEANCSV Looks for bad data in a file numeric csv file and inserts -99999
%in those locations that have text but should have a number. 

fid = fopen(filePath);
%Putting in cell array in case there are others later
badDataStrings = {'#NAME?'};

rawRead = fread(fid,'*char');

charRow = rawRead(:)'; %Force to be a single row

for i = numel(badDataStrings)
    charRow = strrep(charRow,badDataStrings{i},'-9999');
end

fclose(fid);

fid  = fopen(filePath,'w');

fprintf(fid,'%s',charRow);

fclose(fid);

end