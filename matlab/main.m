% 
% ========================================================================
% Track prices in counterfactual scenario
% ========================================================================

%
data = {};

% for each counterfactual scenario
for i = 1:length(cf_data)
    
    % get country and commodity of counterfactual
    country_id = cf_data{i,1};
    country    = cf_data{i,2};
    commodity  = cf_data{i,3};
    
    % set up data entry
    entry = cell(1,13);
    entry(1:3) = {country_id, country, commodity};
    
    % find corresponding elasticity, price, and quantity 
    epq = findEPQ(epq_data, country_id, commodity, 'latest');
    
    % skip iteration if no data
    if isempty(epq)
        continue;
    end
    
    elas_D = epq{7}; % demand_ownprice
    elas_S = epq{11}; 
    price = epq{4};
    quantity = epq{5};
    
    % skip this iteration if supply and demand elasticities are wrong
    if ( (elas_D > 0) || (elas_S < 0) )
        continue; 
    end
    
    % get coefficients of the supply and demand curves
    [ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                          elas_D, elas_S, price, quantity);
   
    % get control supply
    control_quantity = cf_data{i,4};
    control_price = (control_quantity - alpha_d) / beta_d;
    alpha_control = control_quantity - alpha_s - beta_s*control_price;
    alpha_s = alpha_control + alpha_s;
    
    for j = 5:14 % each year in the scenario
        
        % find shock value
        cf_quantity = cf_data{i,j};
        cf_price = (cf_quantity - alpha_d) / beta_d;
        supply_shock = cf_quantity - alpha_s - beta_s*cf_price;
        
        % find shock data
        output = calculateShock( control_price, control_quantity, ...
                          alpha_d, beta_d, alpha_s, beta_s, supply_shock);
                      
        % percent changes in price, quantity
        price_change = (output(1) - control_price) / (control_price);
        quantity_change = (output(2) - (control_quantity)) ...
                            / (control_quantity);
                        
        % surplus changes
        transfer_to_producer = output(3);
        consumer_deadweight  = output(4);
        producer_deadweight  = output(5);
       
        entry(j-1) = {price_change};
        
        %entry(j-1) = {[price_change, quantity_change, ...
        %                transfer_to_producer, consumer_deadweight, ...
        %                producer_deadweight]};
        
    end
        
    % add to data
    data = [data; entry];
    
    %pause;
end


