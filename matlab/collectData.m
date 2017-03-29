
% ========================================================================
% Grabs elasticity data and output data from 
% data/2017_elasticities_outputs.xlsx and calculates the alpha and beta
% coefficients of the model: Q = \alpha + \beta*P
% ========================================================================

%% Get elasticity data from the following file:

disp('Collecting elasticity data...')

file_name = 'data/Elasticity_Data.xlsx';
elas_data = [collectElasticityData(file_name, 1, 2, 3, 4, 6, 7)];


%% Get price and quantity data from the following file:

disp('Collecting price and quantity data...')

file_name   = 'data/FAO_Production_Data.xlsx';
pq_data = collectPriceQuantityData(file_name, 1,  1, 2, 11, 4, 15, 13);

        
%% Combine elasticity data with price and quantity data

disp('Merging data...')

data = collectAllData(pq_data, elas_data);
