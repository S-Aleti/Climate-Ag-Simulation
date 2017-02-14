%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Grabs elasticity data and output data from 
% data/2017_elasticities_outputs.xlsx and calculates the alpha and beta
% coefficients of the model: Q = \alpha + \beta*P
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

file_name = 'data/2017_elasticities_outputs.xlsx';
data = [collectElasticityData(file_name, 8, 9);...    % demand data
            collectElasticityData(file_name, 10, 11)]; % supply data
[~, sheet_names] = xlsfinfo('data/2017_elasticities_outputs.xlsx');
        
for i = 2:length(sheet_names)
    
    % grab title of the sheet
    title = char(sheet_names(i));
    
    % first element of the title contains commodity crop
    delim_loc = findstr(title,'_');
    crop_name = title(1:(delim_loc-1));
    
    % go through elasticities and search for available counries
    crop_data = findElasticity(data, 'all', crop_name, 'all');
        
    if size(crop_data,1) >= 2 % an entry for demand and supply
        
        countries = unique(cell2table(crop_data(:,1)));

        for j = 1:size(countries,1) % go through each country

            % gets jth country name from table
            country = char(countries.(1)(j));

            % supply and demand elasticity
            S_elasticity = findElasticity(crop_data, country, crop_name, ...
                                                'supply');
            D_elasticity = findElasticity(crop_data, country, crop_name, ...
                                                'demand_O');
                                            
            if (length(S_elasticity) > 0 && length(D_elasticity) > 0)
                S_elasticity
                D_elasticity
            end
        end
        
    end
    
end
    

