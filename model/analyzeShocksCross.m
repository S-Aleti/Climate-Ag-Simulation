function [ raw_output, results ]  = analyzeShocksCross(epq_data,        ...
    cf_data, format_results, elas_S_corn_soybean, elas_S_soybean_corn,  ...
    elas_D_corn_soybean, elas_D_soybean_corn)
% ========================================================================
% ANALYZESHOCKSCROSS creates a linear supply and demand model based on the 
% epq data and then simulates the effects in the cf_data using this model
% ========================================================================
% INPUT ARGUMENTS:
%   epq_data             (cell array)  merge of elas_data and pq_data
%   cf_data              (cell array)  contains counterfactual data
%   format_results       (boolean)     toggle output of results array
%   elas_S_[A]_[B]       (scalar)      supply cross price elasticity of
%                                      crop A with respect to crop B
% ========================================================================
% OUTPUT:
%   raw_output           (matrix)      contains the [percent_price_change, 
%                                      percent_quantity_change,
%                                      transfer_to_producer, 
%                                      consumer_welfare_loss,
%                                      producer_welfare_loss, 
%                                      producer_surplus_change,   
%                                      consumer_surplus_change]
%                                      by year for each country
%   results              (cell array)  contains the same data as the 
%                                      raw_ouput but with labels
% ========================================================================



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

num_countries = size(filtered_data, 1);


%% Set up matrices of elasticities, prices, and quantities

% PARAMS defined in function input
% % cross supply
% elas_S_corn_soybean = -0.076;
% elas_S_soybean_corn = -0.13;
% elas_D_corn_soybean = 0.123;
% elas_D_soybean_corn = 0.123;

% number of commodities
n = length(unique(filtered_data(:,3)));
% number of countries
m = num_countries;

% matrices containing data for all country-crops in filtered_data
data_elas_D     = zeros(m);
data_elas_S     = zeros(m);
data_prices     = zeros(m, 1);
data_quantities = zeros(m, 1);

for i = 1:num_countries
    
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
        for j = 1:num_countries
            if strcmp(filtered_data{j,3}, "soybean")
                data_elas_S(i, j) = elas_S_corn_soybean;
                data_elas_D(i, j) = elas_D_corn_soybean;
            end
        end
    end
    
    if strcmp(commodity, "soybean")
        % fill elasticity matrices with soybeans's cross price elastcities
        for j = 1:num_countries
            if strcmp(filtered_data{j,3}, "corn")
                data_elas_S(i, j) = elas_S_soybean_corn;
                data_elas_D(i, j) = elas_D_soybean_corn;
            end
        end
    end
    
end


%% Get coefficients

% =========================================================================
% =================================REMOVE==================================
% =========================================================================

data_elas_D = diag(diag(data_elas_D));
data_elas_S = diag(diag(data_elas_S));

[ alpha_d, beta_d, alpha_s, beta_s ] =  calculateCoefficients(          ...
    data_elas_D, data_elas_S, data_prices, data_quantities);


%% Introduce yearly shocks

alpha_shocks = zeros(m, 10);

for i = 1:num_countries
    
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
raw_output = zeros(10*num_countries, 7);

for i = 1:10 % for each year
    
    [ output ] = calculateShockCrossEffects( data_prices,               ...
            data_quantities, alpha_d, beta_d, alpha_s, beta_s,          ...
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
    
    row_range = (num_countries*(i-1)+1):(num_countries*(i));
    column_range = 1:7;
    raw_output(row_range,column_range) = [                              ...
                price_change, quantity_change,                          ...
                transfer_to_producer, consumer_welfare_loss,            ...
                producer_welfare_loss, producer_surplus_change,         ...
                consumer_surplus_change];
    
    if format_results % save time by setting this to false
        
        for j = 1:num_countries % for each country   
            
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
    
end

end