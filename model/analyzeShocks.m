function [ data ] = analyzeShocks(epq_data, cf_data)

%% Calculate shocks 

% empty cell array to store results
data = {};

% for each counterfactual scenario
for i = 1:size(cf_data,1)
    %% Construct supply and demand model
    
    % get country and commodity of counterfactual
    country_id = cf_data{i,1};
    country    = cf_data{i,2};
    commodity  = cf_data{i,3};
    
    % set up data entry
    entry = cell(1,13);
    entry(1:3) = {country_id, country, commodity};
    
    % find latest corresponding elasticity, price, and quantity 
    epq = findEPQ(epq_data, country_id, commodity, 'latest');
    
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
    
    % get coefficients of the supply and demand curves
    [ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                          elas_D, elas_S, price, quantity);
 
    control_quantity = cf_data{i,4};
    
    %% Calculate shocks for each year
    
    for j = 5:14 % each year in the scenario
        
        % find shock value
        percent_shock = (cf_data{i,j}-control_quantity)/control_quantity;
        quantity_cf = quantity*(1+percent_shock);
        alpha_shock = quantity_cf - alpha_s - beta_s*price;
        
        % find shock data
        output = calculateShockEffects( price, quantity, ...
                          alpha_d, beta_d, alpha_s, beta_s, alpha_shock);
                      
        % percent changes in price, quantity
        price_change = (output(1) - price) / (price);
        quantity_change = percent_shock;
                        
        % surplus changes
        transfer_to_producer        = output(3);
        consumer_deadweight         = output(4);
        producer_deadweight         = output(5);
        consumer_surplus_before     = output(6);
        producer_surplus_before     = output(7);
        consumer_surplus_after      = output(8);
        producer_surplus_after      = output(9);
       
        %entry(j-1) = {price_change};
        
        entry(j-1) = {[price_change, quantity_change,                   ...
                        transfer_to_producer, consumer_deadweight,      ...
                        producer_deadweight, consumer_surplus_before,   ...
                        producer_surplus_before, consumer_surplus_after,...
                        producer_surplus_after]};
        
    end
        
    % add to data
    data = [data; entry];
 
end


