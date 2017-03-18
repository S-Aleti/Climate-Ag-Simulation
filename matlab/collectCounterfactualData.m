function [ data ] = collectCounterfactualData( file_name, c_code_col,   ...
                                              country_col, data_col, sheet)

% COLLECTCOUNTERFACTUALDATA collects counterfactual data from an excel file
% ========================================================================
% INPUT ARGUMENTS:
%   file name            (string) location of xls file 
%   c_code_col           (int)    column corresponding to the country code
%   country_col          (int)    column corresponding to the country name
%   data_col             (int)    column corresponding to first data cell, 
%                                 should be the 'Control' column
%   commodity            (string) name of commodity, corresponds to sheet
%   c_code               (int)    corresponds to country in c_code_col
% ========================================================================
% OUTPUT:
%   data                 (cell array) contains an array of cells in the 
%                           following format: {country, commodity, cross,
%                           elasticity_type, elasticity}
% ========================================================================

%% Read data file

[~, ~, xls_raw] = xlsread(file_name, sheet);

%% Process data

data = {};

% open waitbar
h = waitbar(0,'Collecting counterfactual data');
data_size = size(xls_raw,1);

for i = 2:size(xls_raw,1)
   
    % update wait bar
    waitbar(i/data_size,h);
    
    % if none of the cells are empty
    if ( ~(  isCellEmpty(xls_raw(i,c_code_col))       || ...
             isCellEmpty(xls_raw(i,data_col))))
        
        % if the country produces this sheet's crop
        if (xls_raw{i,data_col} ~= 0) 
            
            % process code and extract elasticity 
            output = {cell2mat(xls_raw(i,c_code_col)),                  ...
                      strtrim(cell2mat(xls_raw(i,country_col)))}; 

            % assumes 11 cols of data      
            output(1,3:13) = xls_raw(i,[data_col:data_col+10]); 

            % add information collected to data (cell array)
            data = [data; output]; %#ok<AGROW>
            
        end
                  
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

boolean = cellfun(@(C) isequaln(C, NaN), c) || ...
            cellfun(@(C) isequaln(C, '.'), c);

end
