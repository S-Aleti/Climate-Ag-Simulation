function [ data ] = collectPriceQuantityData( file_name, sheet,        ...
                                             c_code_col, country_col,  ...
                                             commodity_col, year_col,  ...
                                             price_col, quantity_col)

% COLLECTPRICEQUANTITYDATA collects price and quantity data from an xls 
% ========================================================================
% INPUT ARGUMENTS:
%   file name            (string) location of xls file 
%   c_code_col           (int)    column corresponding to the country code
%   country_col          (int) column corresponding to country
%   commodity_col        (int) column corresponding to the commodity
%   year_col             (int) column corresponding to year of data
%   price_col            (int) column corresponding to price
%   quantity_col         (int) column corresponding to quantity
% ========================================================================
% OUTPUT:
%   data                 (cell array) contains an array of cells in the 
%                           following format: {country, commodity, year,
%                           supply, demand}
% ========================================================================

%% Read data file

[~, ~, xls_raw] = xlsread(file_name,sheet);

%% Process data

data = {};

% open waitbar
h = waitbar(0, ['Collecting price and quantity data']);
data_size = size(xls_raw,1);

for i = 3:size(xls_raw,1)
   
    % update wait bar
    if (rand()<0.1) waitbar(i/data_size,h); end;
    
    % if none of the cells are empty
    if ( ~(   isequal(cell2mat(xls_raw(i,c_code_col)),'')     || ...
              isCellEmpty(xls_raw(i,country_col))             || ...
              isCellEmpty(xls_raw(i,commodity_col))           || ...
              isCellEmpty(xls_raw(i,year_col))                || ...
              isCellEmpty(xls_raw(i,price_col))               || ...
              isCellEmpty(xls_raw(i,quantity_col))))
        
        % process code and extract elasticity
        output = {cell2mat(xls_raw(i,c_code_col)),    	...
                  cell2mat(xls_raw(i,country_col)),     ...
                  cell2mat(xls_raw(i,commodity_col)),   ...
                  cell2mat(xls_raw(i,year_col)),        ...
                  cell2mat(xls_raw(i,price_col)),       ...
                  cell2mat(xls_raw(i,quantity_col)) };
        
        % add information collected to data (cell array)
        data = [data; output]; %#ok<AGROW>
                  
    else % if no data 
        
        continue; %move on to next cell
        
    end
    
end

% sort by country code
data = sortrows(data,1);

% close waitbar
close(h)

end

%% Local Functions

function [ boolean ] = isCellEmpty( c )

% ISCELLEMPTY checks if a given cell c is empty or contains '.'
% ========================================================================

% check if cell is completly empty
boolean = cellfun(@(C) isequaln(C, NaN), c) || ...
            cellfun(@(C) isequaln(C, '.'), c);

% check if cell is an empty string
if (~boolean)
    boolean = length(cell2mat(c)) == 0;
end

end