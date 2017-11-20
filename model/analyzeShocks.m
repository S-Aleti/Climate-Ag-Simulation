function [ data ] = analyzeShocks(epq_data, cf_data)
% ========================================================================
% ANALYZESHOCKS creates a linear supply and demand model based on the epq
% data and then simulates the effects in the cf_data using this model
% ========================================================================
% INPUT ARGUMENTS:
%   epq_data             (cell array)  merge of elas_data and pq_data
%   cf_data              (cell array)  contains counterfactual data
% ========================================================================
% OUTPUT:
%   data                 (cell array)  contains the {country_ID,
%                                      country_name, commodity_name, 
%                                      year_1_shock, ..., year_n_shock}
%                                      where each year's shock data
%                                      is the [price_change, quant_change,
%                                      transfer_to_producer, 
%                                      consumer_welfare_loss,
%                                      producer_welfare_loss, 
%                                      producer_surplus_change,   
%                                      consumer_surplus_change]
% ========================================================================


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
        quantity_change = (output(2) - quantity)/quantity;
        
        % surplus changes
        transfer_to_producer        = output(3);
        consumer_welfare_loss       = output(4);
        producer_welfare_loss       = output(5);
        
        % percent change in surpluses
        consumer_surplus_change     = (output(8)-output(6))/ output(6); 
        producer_surplus_change     = (output(9)-output(7))/ output(7); 

        % fill in entry
        entry(j-1) = {[price_change, quantity_change,                   ...
                        transfer_to_producer, consumer_welfare_loss,      ...
                        producer_welfare_loss, producer_surplus_change,   ...
                        consumer_surplus_change]};
        
    end
        
    % add to data
    data = [data; entry];
 
end


