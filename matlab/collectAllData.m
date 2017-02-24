function [ all_data ] = collectAllData( sd_data, elas_data )

% COLLECTALLDATA collects all data together in one cell array
% ========================================================================
% INPUT ARGUMENTS:
%   sd_data              (cell array) from collectSupplyDemandData.m
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
data_size = size(sd_data,1);

for i = 1:size(sd_data,1)
    
    % update wait bar
    waitbar(i/data_size,h);
    
    % from supply and demand data
    country   = cell2mat(sd_data(i,1));
    commodity = lower(cell2mat(sd_data(i,2)));
    year      = cell2mat(sd_data(i,3));
    price     = cell2mat(sd_data(i,4));
    quantity  = cell2mat(sd_data(i,5));
    
    % from elasticity data
    demand_O = findElasticity(elas_data, country, commodity, 'demand_O');
    demand_C = findElasticity(elas_data, country, commodity, 'demand_C');
    demand_I = findElasticity(elas_data, country, commodity, 'demand_I');
    demand_E = findElasticity(elas_data, country, commodity, 'demand_E');
    supply   = findElasticity(elas_data, country, commodity, 'supply');
    
    all_data = [all_data; {country, commodity, year, price, quantity, ...
               	    averageElas(demand_O), averageElas(demand_C),     ...
                    averageElas(demand_I), averageElas(demand_E),     ...
                    averageElas(supply)}];
    
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
        temp_sum = temp_sum + cell2mat(data(i,5));
    end
    average_elas = temp_sum/size(data,1);
    
else
    
    average_elas = NaN;

end

end




