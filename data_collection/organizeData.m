function [ price, quantity, elas_D, elas_S ] = organizeData( ...
                                         commodities, elas_data, pq_data )

% ORGANIZEDATA converts the cell arrays produced by the other fuctions into
% matricies for the shock simulation
% ========================================================================
% INPUT ARGUMENTS:
%   commodities          (cell array) commodities to collect data for
%   elas_data            (cell array) contains elasticity data
%   pq_data              (cell array) contains price & quantity data
% ========================================================================
% OUTPUT:
%   price                (vector)  current price ($/tonnes)
%   quantity             (vector)  current quantity (tonnes)
%   elas_D               (matrix)  diagonal entries are elasticity of demand
%                                  and non-diagonal entries are cross elas
%   elas_S               (matrix)  same as elas_D but for supply
% ========================================================================

commodities = lower(commodities);

%% Elasticity Data
elas_D = getElasticities(elas_data, 'demand', commodities);    
elas_S = getElasticities(elas_data, 'supply', commodities);

%% Price and Quantity Data

price = zeros(size(commodities,2),1);
quantity = price;

for i = 1:size(pq_data,1)
    
    commodity = lower(pq_data{i,3});
    index = find(strcmp(commodities, commodity));
    
    if size(index,2) == 1
        price(index)    = pq_data{i,5};
        quantity(index) = pq_data{i,6};
    end
        
end

%% Check for missing data

n = size(commodities,2);
elas_D_own = diag(elas_D);
elas_S_own = diag(elas_S);

for i = 1:n
    
    if (elas_D_own(i) == 0)
        error(['Missing demand elasticity for ', commodities{i}]);
    elseif (elas_S_own(i) == 0)
        error(['Missing supply elasticity for ', commodities{i}]);
    elseif (price(i) == 0)
        error(['Missing price data for ', commodities{i}]);
    elseif (quantity(i) == 0)
        error(['Missing quantity data for ', commodities{i}]);
    end
    
end

end

function [elas] = getElasticities(elas_data, type, commodities)

% GETELASTICITIES returns the particular elasticity matrix of a given type
% ========================================================================

elas = zeros(size(commodities, 2));

% parse elas_data for demand elasticities of commodities desired
for i = 1:size(elas_data,1) 
    
    elas_type = elas_data{i,5};
    
    if ~isequal(elas_type(1:6), type)
        continue
    end
    
    commodity = elas_data{i,3};
    cross     = elas_data{i,4};
    index = [find(strcmp(commodities, commodity)), ...
             find(strcmp(commodities, cross))];
    
    % index variable will only be 2D if desired commodities are in row i
    % of the elasticity data

    if size(index,2) == 2
        elas(index(1),index(2)) = elas_data{i,6};
    end
    
end

end
