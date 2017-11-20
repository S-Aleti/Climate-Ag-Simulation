

%% Get countries and commodities with data available

filtered_data = {};

for i = 1:size(cf_data,1)
    %% Construct supply and demand model
    
    % get country and commodity of counterfactual
    country_id = cf_data{i,1};
    country    = cf_data{i,2};
    commodity  = cf_data{i,3};
    
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
    
    % set up data entry
    entry = cell(1,3);
    entry(1:3) = {country_id, country, commodity};
    
    filtered_data = [filtered_data; entry];
    
end


%% Set up matrices of elasticities, prices, and quantities

% PARAMS
% cross supply
elas_S_corn_soybean = -0.076;
elas_S_soybean_corn = -0.13;
elas_D_corn_soybean = 0.123;
elas_D_soybean_corn = 0.123;

% number of commodities
n = length(unique(filtered_data(:,3)));
m = size(filtered_data, 1);

% matrices containing data for all country-crops in filtered_data
data_elas_D     = zeros(m);
data_elas_S     = zeros(m);
data_prices     = zeros(m, 1);
data_quantities = zeros(m, 1);

for i = 1:size(filtered_data, 1)
    
    % get country and commodity
    country_id = filtered_data{i,1};
    commodity  = filtered_data{i,3};
    
    % find elasticities, price, and quantity
    epq = findEPQ(epq_data, country_id, commodity, 'latest');
    elas_D   = epq{7}; % demand_ownprice
    elas_S   = epq{11}; 
    price    = epq{5};
    quantity = epq{6};
    
    % update data matrices
    data_elas_D(i,i)   = elas_D;
    data_elas_S(i,i)   = elas_S;
    data_prices(i)     = price;
    data_quantities(i) = quantity;
    
    % check the commoditiy and assign the proper cross price elasticity
    
    if strcmp(commodity, "corn")
        % fill elasticity matrices with corn's cross price elastcities
        for j = 1:size(filtered_data, 1)
            if strcmp(filtered_data{j,3}, "soybean")
                data_elas_S(i, j) = elas_S_corn_soybean;
                data_elas_D(i, j) = elas_D_corn_soybean;
            end
        end
    end
    
    if strcmp(commodity, "soybean")
        % fill elasticity matrices with soybeans's cross price elastcities
        for j = 1:size(filtered_data, 1)
            if strcmp(filtered_data{j,3}, "corn")
                data_elas_S(i, j) = elas_S_soybean_corn;
                data_elas_D(i, j) = elas_D_soybean_corn;
            end
        end
    end
    
end


%% Get coefficients

[ alpha_d, beta_d, alpha_s, beta_s ] =  calculateCoefficients( ...
    data_elas_D, data_elas_S, data_prices, data_quantities);


%% Introduce yearly shocks

alpha_shocks = zeros(m, 10);

for i = 1:size(filtered_data, 1)
    
    % get country and commodity
    country_id = filtered_data{i,1};
    commodity  = filtered_data{i,3};
    
    % find relevant counterfactual data
    ind1 = find([cf_data{:,1}]==country_id);
    ind2 = find(strcmp(cf_data(:,3), commodity));
    ind  = intersect(ind1, ind2);
    
    % baseline 
    control_quantity = cf_data{ind,4};
    
    % calculate shocks for each year
    for j = 5:14
       
        percent_shock = (cf_data{ind,j}-control_quantity)/control_quantity;
        quantity_cf   = data_quantities(i)*(1+percent_shock);
        alpha_shocks(i, j-4) = quantity_cf; 
        
    end
    
end

alpha_shocks = alpha_shocks - repmat(alpha_s + beta_s*data_prices, 1, 10);


%% Simulate shocks 

results = {};
raw_output = zeros(10*size(filtered_data, 1), 

for i = 1:10 % for each year
    
    [ output ] = calculateShockCrossEffects( data_prices,       ...
            data_quantities, alpha_d, beta_d, alpha_s, beta_s,  ...
            alpha_shocks(:, i));
    
    % percent changes in price, quantity
    price_change = (output(:,1) - data_prices) ./ (data_prices);
    quantity_change = (output(:,2) - data_quantities) ./ data_quantities;

    % surplus changes
    transfer_to_producer        = output(:,3);
    consumer_welfare_loss       = output(:,4);
    producer_welfare_loss       = output(:,5);

    % percent change in surpluses
    consumer_surplus_change     = (output(:,8)-output(:,6)) ./ output(:,6); 
    producer_surplus_change     = (output(:,9)-output(:,7)) ./ output(:,7); 
    
    for j = 1:size(filtered_data, 1) % for each country
        
            results = [results; {(i-1),                                 ...
                            filtered_data{j, 2}, filtered_data{j, 3},   ...
                            price_change(j), quantity_change(j),        ...
                            transfer_to_producer(j),                    ...
                            consumer_welfare_loss(j),                   ...
                            producer_welfare_loss(j),                   ...
                            producer_surplus_change(j),                 ...
                            consumer_surplus_change(j)}];
                    
    end
    
end


%% Format Results

var_names = {'Year', 'Country', 'Crop', 'Percent_Price_Change',         ...
    'Percent_Quantity_Change', 'Welfare_Transfer_to_Producer',          ...
    'Welfare_lost_by_Consumer', 'Welfare_lost_by_Producer',             ...
    'Percent_Change_in_Producer_Surplus',                               ...
    'Percent_Change_in_Consumer_Surplus'};
data_table = cell2table(results, 'VariableNames', var_names);




