%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grabs elasticity data and output data from 
% data/2017_elasticities_outputs.xlsx and calculates the alpha and beta
% coefficients of the model: Q = \alpha + \beta*P
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Get elasticity data from the following file:
file_name = 'data/2017_elasticities_outputs.xlsx';
elas_data = [collectElasticityData(file_name, 1, 2, 4, 5, 6)]; %demand data


% Get price and quantity data from the following file:
file_name = 'data/2014_original_dataset.xlsx';
sd_data   = collectSupplyDemandData( file_name, ...
            3, 2, 1, 23, 47); % cols corresponding to data
  
%%

for i = 2:length(sheet_names)
    
    % grab title of the sheet
    title = char(sheet_names(i));
    
    % first element of the title contains commodity crop
    delim_loc = strfind(title,'_');
    crop_name = title(1:(delim_loc-1));
    
    % go through elasticities and search for available countries
    crop_elas_data = findElasticity(elas_data, 'all', crop_name, 'all');
    
    % go through price and quantities and search for availble 
    crop_pq_data = findPriceQuantity(
    
        
    if size(crop_elas_data,1) >= 2 % an entry exists for both demand and supply
        
        countries = unique(cell2table(crop_elas_data(:,1)));
        
        % go through each country
        for j = 1:size(countries,1) 

            % gets jth country name from table
            country = char(countries.(1)(j));

            % supply and demand elasticity
            elas_S = findElasticity(crop_elas_data, country, ...
                                                crop_name, 'supply');
            elas_D = findElasticity(crop_elas_data, country, ...
                                                crop_name, 'demand_O');
                                            
            % check if elasticites found for both
            if (length(S_elasticity)*length(D_elasticity) > 0)
               
                % find price and quantity
                pq_data = findPriceQuantity(
                % calculate demand and supply curves
                [ alpha_d, beta_d, alpha_s, beta_s ]] = ...
                    calculateCoefficients(elas_S, elas_D, price, quantity);
                
                
            end
            
        end
        
    end
    
end
    

