% table for price changes
% compute rebound effect which is the fall in gasoline supply
% price change for various shocks
% gasoline 95 gco2/mj of emissions, 1.3*10^2 mJ/gallon

close all


%% Parameters

% commodities to analyze
commodities = {'natural gas', 'electricity', 'gasoline'};

% define percent changes in quantity (>1 for positive supply shocks)
percent_change = [0.00:0.01:0.20] + 1;

% iterations for the market simulation
iterations = 15;


%% Import Data

filename  = 'elasticity_data.xlsx';
elas_data = collectElasticityData(filename, 1, 2, 3, 4, 5, 6);

filename  = 'production_data.xlsx';
pq_data   = collectPriceQuantityData(filename, 'main', 1, 2, 3, 8, 4, 6);

[price,quantity, elas_D,elas_S] = ...
    organizeData(commodities,elas_data,pq_data);


%% Determine shock values 

[ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                         elas_D, elas_S, price, quantity);

% calculate 
alpha_shocks = quantity * percent_change - ...
                repmat(beta_s*price + alpha_s, 1, size(percent_change,2));
      
% no shock to commodity 1 or 2
alpha_shocks(1,:) = 0;
alpha_shocks(2,:) = 0;


%% Simluate shocks

% initialize vars to 0
price_eqls     = zeros(size(commodities,2),size(percent_change,2));
quantity_eqls  = price_change;

% plots the supply and demand graphs
plot_results = false;

for shock_num = 1:size(percent_change,2)
    
    % specific supply shock
    alpha_shock = alpha_shocks(:,shock_num);
    alpha_s2 = alpha_s + alpha_shock;
    
    % results of each shock
    [ price_t, quantity_t, price_shock, quantity_shock, price_eql,      ...
        quantity_eql ] = simulateShock(price, quantity, elas_D, elas_S, ...
                        alpha_shock, iterations, plot_results);
                    
    price_eqls(:,shock_num)     = price_eql;
    quantity_eqls(:,shock_num)  = quantity_eql;  
    
    
end


%% Results

% number of supply shocks simulated
n = size(percent_change,2);

% Price changes
price_change = price_eqls - repmat(price, 1, n);
percent_price_change = price_change ./ repmat(price, 1, n);

% Quantity changes
quantity_change = quantity_eqls - repmat(quantity, 1, n);
percent_quantity_change = quantity_change ./ repmat(quantity, 1, n);
quantity_after_shock = repmat(quantity,1,n) + alpha_shocks;

% Rebound effect
quantity_rebound = quantity_eqls - quantity_after_shock;
percent_quantity_rebound = quantity_rebound ./ quantity_after_shock;

% Decrease in CO2
CO2_reduction_grams = -quantity_rebound(3,:)*95*1.3*10^2;
CO2_reduction_megatonnes = CO2_reduction_grams*10^(-6-6);
        

%% Plot Results

close all;

% Price changes
fig = figure;
plot_prices = plot(percent_change-1, percent_price_change');
%set(fig,'interpreter','none')

for i = 1:size(commodities,2)
    set(plot_prices(i),'DisplayName',commodities{i});
end

lgd = legend('show');
xlabel('Supply Shock (%)');
ylabel('Price change (%)');
title('Change in prices after supply shocks');
grid on;

% Quantity changes
fig = figure;
plot_prices = plot(percent_change-1, percent_quantity_change');
%set(fig,'interpreter','none')

for i = 1:size(commodities,2)
    set(plot_prices(i),'DisplayName',commodities{i});
end

lgd = legend('show');
xlabel('Supply Shock (%)');
ylabel('Quantity change (%)');
title('Change in quantities after supply shocks');
grid on;


% Rebound effect
fig = figure;
plot_prices = plot(percent_change-1, percent_quantity_rebound');
%set(fig,'interpreter','none')

for i = 1:size(commodities,2)
    set(plot_prices(i),'DisplayName',commodities{i});
end

lgd = legend('show');
xlabel('Supply Shock (%)');
ylabel('Quantity change (%)');
title('Rebound effects');
grid on;


% CO2 reduction
fig = figure;
plot_prices = plot(percent_change-1, CO2_reduction_megatonnes');
%set(fig,'interpreter','none')

set(plot_prices(1),'DisplayName', 'Decrease in CO2');

lgd = legend('show');
xlabel('Supply Shock (%)');
ylabel('Megatonnes');
title('CO2 Reduction');
grid on;




        
        