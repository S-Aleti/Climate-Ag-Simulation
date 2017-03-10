%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grabs elasticity data and output data from 
% data/2017_elasticities_outputs.xlsx and calculates the alpha and beta
% coefficients of the model: Q = \alpha + \beta*P
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get elasticity data from the following file:
disp('Collecting elasticity data...')
file_name = 'data/2017_elasticities_outputs.xlsx';
elas_data = [collectElasticityData(file_name, 1, 2, 4, 5, 6)]; %demand data


% Get price and quantity data from the following file:
disp('Collecting price and quantity data...')
file_name = 'data/2014_original_dataset.xlsx';
sd_data   = collectSupplyDemandData( file_name, ...
            3, 2, 1, 23, 47); % cols corresponding to data
  
%% Combine elasticity data with price and quantity data
disp('Merging data...')
data = collectAllData(sd_data, elas_data);

%% Calculate supply and demand model


