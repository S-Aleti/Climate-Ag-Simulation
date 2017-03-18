% ========================================================================
% Grabs elasticity data and output data from 
% data/2017_elasticities_outputs.xlsx and calculates the alpha and beta
% coefficients of the model: Q = \alpha + \beta*P
% ========================================================================

%% Get elasticity data from the following file:

disp('Collecting elasticity data...')

file_name = 'data/2017_Elasticity_Data.xlsx';
elas_data = [collectElasticityData(file_name, 1, 2, 3, 4, 5, 6)];


%% Get price and quantity data from the following file:

disp('Collecting price and quantity data...')

file_name   = 'data/2017_USDA_FAO_Data.xlsx';
[~, sheets] = xlsfinfo(file_name);
sd_data     = {};

% collects data from each sheet
for i = 1:length(sheets)
    sd_data = [sd_data; collectSupplyDemandData( file_name, i, ...
                                            1, 6, 5, 4, 26, 16);];
end

% sort by country code
sd_data = sortrows(sd_data,1);
        
%% Combine elasticity data with price and quantity data

disp('Merging data...')

data = collectAllData(sd_data, elas_data);


%% Calculate supply and demand model


