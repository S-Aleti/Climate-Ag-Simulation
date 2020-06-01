clc
filtered_data = {};

for i = 1:size(cf_data,1)
    %% Construct supply and demand model
    
    % get country and commodity of counterfactual
    country_id = cf_data{i,1};
    country    = cf_data{i,2};
    commodity  = cf_data{i,3};
    
    % find latest corresponding elasticity, price, and quantity 
    epq = findEPQ(epq_data, country, commodity, 'latest');
    
    % skip iteration if no data
    if isempty(epq)
        continue;
    end
    
    elas_D = epq{7}; % demand_ownprice
    elas_S = epq{11}; 
    price = epq{5};
    quantity = epq{6};
    
    % skip this iteration if supply and demand elasticities are wrong
    if ( (elas_D > 0) || (elas_S < 0) )
        continue; 
    end
    
    % set up data entry
    entry = cell(1,3);
    entry(1:3) = {country_id, country, commodity};
    
    filtered_data = [filtered_data; entry];
    
end

num_countrycrop = size(filtered_data, 1);