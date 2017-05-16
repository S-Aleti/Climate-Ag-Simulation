function [ supply_shocks ] = collectCommodityShocks( filename, ...
                                          commodity, cause_col, shock_col)

% COLLECTCOMMODITYSHOCKS imports shocks to given commodities from an xlsx
% ========================================================================
% INPUT ARGUMENTS:
%   filename             (string) file name of xlsx
%   commodity            (string) should correspond to a sheetname in the 
%                                 excel file
%   cause_col            (int)    column corresponding to the cause of the
%                                 supply shock
%   shock_col            (int)    column corresponding to the size of the 
%                                 supply shock
% ========================================================================
% OUTPUT:
%   supply_shocks        (matrix) supply shock data from xlsx
% ========================================================================

%% Open xlsx file

% Get raw data
[~, ~, xls_raw]  = xlsread(filename, commodity);


%% Process Data

supply_shocks = {};

% open waitbar
h = waitbar(0,'Collecting counterfactual data');
data_size = size(xls_raw,1);

for i = 2:size(xls_raw,1)
   
    % update wait bar
    waitbar(i/data_size,h);
    
    % if none of the cells are empty
    if ( ~(  isCellEmpty(xls_raw(i, cause_col))       || ...
             isCellEmpty(xls_raw(i, shock_col))))
            
        % process code and extract elasticity 
        output = {strtrim(cell2mat(xls_raw(i, cause_col))),        ...
                  cell2mat(xls_raw(i, shock_col))}; 

        % add information collected to data (cell array)
        supply_shocks = [supply_shocks; output]; %#ok<AGROW>
                  
    else % if no data 
        
        continue; %move on to next cell
        
    end
    
end

% close waitbar
close(h)

end


%% Local Functions

function [ boolean ] = isCellEmpty( c )

% ISCELLEMPTY checks if a given cell c is empty or contains ''
% ========================================================================

boolean = cellfun(@(C) isequaln(C, NaN), c) || ...
            cellfun(@(C) isequaln(C, '.'), c);

% check if cell is an empty string
if (~boolean)
    boolean = isempty(cell2mat(c));
end
        
end


