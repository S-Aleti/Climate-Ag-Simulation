function [price, quantity, elas_D, elas_S] = importKDIData( commodities,...
                               filename_elasticities, filename_production )
                           
% IMPORTKDIDATA loads the data for the KDI Project
% ========================================================================
% INPUT ARGUMENTS:
%   commodities           (cell array) names (string) of commodities to get
%                                      data for
%   filename_elasticities (string) name of file containing elasticity data
%   filename_production   (string) name of file containing production data
% ========================================================================
% OUTPUT:
%   price                (vector)  current price ($/tonnes)
%   quantity             (vector)  current quantity (tonnes)
%   elas_D               (matrix)  diagonal entries are own price
%                                  elasticities of demand and non-diagonal 
%                                  entries are cross elas
%   elas_S               (matrix)  same as elas_D but for supply
% ========================================================================

%% Load elasticity and production data

filename  = filename_elasticities;
elas_data = collectElasticityData(filename, 1, 2, 3, 4, 5, 6);

filename  = filename_production;
pq_data   = collectPriceQuantityData(filename, 'main', 1, 2, 3, 8, 4, 6);


%% Organize all data for specified commodities

[price,quantity, elas_D,elas_S] = ...
    organizeData(commodities,elas_data,pq_data);


end

