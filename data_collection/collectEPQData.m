function [ all_data ] = collectEPQData( pq_data, elas_data )

% COLLECTEPQDATA collects all data together in one cell array
% ========================================================================
% INPUT ARGUMENTS:
%   pq_data              (cell array) from collectPriceQuantityData.m
%   elas_data            (cell array) from collectElasticityData.m
% ========================================================================
% OUTPUT:
%   all_data             (cell array) contains an array of cells in the 
%                           following format: {country, commodity, year,
%                           price, quantity, demand_O, demand_C, demand_I,
%                           demand_E, supply}
% ========================================================================

%% Process Data

all_data = {};

% open waitbar
h = waitbar(0,'Collecting all data');
data_size = size(pq_data,1);

for i = 1:size(pq_data,1)
    
    % update wait bar
    waitbar(i/data_size,h);
    
    % from supply and demand data
    c_code       = cell2mat(pq_data(i,1)); % country identification code
    country      = cell2mat(pq_data(i,2));
    commodity    = lower(cell2mat(pq_data(i,3)));
    year         = cell2mat(pq_data(i,4));
    price        = cell2mat(pq_data(i,5));
    quantity     = cell2mat(pq_data(i,6));
    
    % from elasticity data
    demand_O = findElasticity(elas_data, c_code, commodity, 'demand_O');
    demand_C = findElasticity(elas_data, c_code, commodity, 'demand_C');
    demand_I = findElasticity(elas_data, c_code, commodity, 'demand_I');
    demand_E = findElasticity(elas_data, c_code, commodity, 'demand_E');
    supply   = findElasticity(elas_data, c_code, commodity, 'supply');

    if (~isempty(supply) && ~( isempty(demand_O) && isempty(demand_C) ...
                            && isempty(demand_I) && isempty(demand_E) ) )
        
        all_data = [all_data; {c_code,country, commodity, year, price,        ...
                        quantity, averageElas(demand_O),               ...
                        averageElas(demand_C), averageElas(demand_I),  ...
                        averageElas(demand_E), averageElas(supply)}];
    end
    
end

% close waitbar
close(h);

end

%% Local Functions

function [average_elas] = averageElas( data )

% AVERAGEELAS averages the elasticity values of a cell array
% ========================================================================

if (size(data,1) > 0) 
        
    temp_sum = 0;
    for i = 1:size(data,1)
        temp_sum = temp_sum + cell2mat(data(i,6));
    end
    average_elas = temp_sum/size(data,1);
    
else
    
    average_elas = NaN;

end

end




