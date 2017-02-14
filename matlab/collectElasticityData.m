function [ data ] = collectElasticityData( file_name, ...
                                            code_column, data_column )
%COLLECTELASTICITYDATA collects elasticity data from an excel file
% Reads and processes data from 2017_elasticites_outputs.xlsx and outputs
% a cell array containing data in the format {country, commodity, cross
% commodity, elasticity type, elasticity}
% ========================================================================
% INPUT ARGUMENTS:
%   code column              (int) column corresponding to id codes
%   data column              (int) column corresponding to elasticites
% ========================================================================

%% Read data file

% use '/data/2017_elasticities_outputs.xlsx'
[~, ~, xls_raw] = xlsread(file_name);

%% Process data

data = {};

for i = 2:size(xls_raw,1)
   
    % check if cells contain any data
    if (~cellfun(@(C) isequaln(C, NaN), xls_raw(i,code_column))) && ...
            (~cellfun(@(C) isequaln(C, NaN), xls_raw(i,data_column)))
        
        % process code and extract elasticity
        output = cell(1,5);
        output(1:4) = convertIDcode(char(xls_raw(i,code_column)));
        output(5) = xls_raw(i,data_column);
        
        % add information collected to data (cell array)
        data = [data; output];
                  
    else % if no data 
        
        continue; %move on to next cell
        
    end
    
end

%disp('Elasticity data collection completed');


end

