function csvwriteh( filename, data, header )
% CVSWRITEH write matrix to a csv file with header
% Source: https://www.nesono.com/node/415
% ========================================================================
% INPUT ARGUMENTS:
%   filename             (str)        filename for csv output file
%   data                 (matrix)     matrix with data for csv file
%   header               (cell array) contains names per column
% ========================================================================

%% Check parameters

% filename parameter
if exist( 'filename', 'var' )
    if ~ischar( filename )
        error('filename not char')
    end
else
    error('filename does not exists')
end

% data parameter
if exist( 'data', 'var' )
    if ~isnumeric( data )
        error('data not numeric')
    end
else
    error('data does not exist')
end

% header parameter
if exist( 'header', 'var' )
    if ~iscellstr( header )
        error('header no cell str')
    end
else
    error('header does not exist')
end

% check dimensions of data and header
[drow dcol] = size (data);
[hrow hcol] = size (header);
if hcol ~= dcol
    error( 'header not of same length as data (columns)' )
end

%% Write CSV
outid = fopen (filename, 'w+');

% write header
for idx = 1:hcol
    fprintf (outid, '%s', header{idx});
    if idx ~= hcol
        fprintf (outid, ',');
    else
        fprintf (outid, '\n' );
    end
end
% close file
fclose(outid);

% write data
dlmwrite (filename, data, '-append' );

end