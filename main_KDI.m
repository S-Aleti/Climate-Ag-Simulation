% table for price changes
% compute rebound effect which is the fall in gasoline supply
% price change for various shocks
% gasoline 95 gco2/mj of emissions, 131.76 mJ/gallon

close all


%% Parameters

% commodities to analyze
commodities = {'gasoline', 'electricity', 'natural gas'};

% define percent changes in quantity (>1 for positive supply shocks)
percent_change = [0.05:0.01:0.30] + 1;

% iterations for the market simulation
iterations = 15;


%% Import Data

disp(['Importing elasticity and production data...']);

filename_elasticities  = 'KDI_elasticity_data.xlsx';
filename_production  = 'KDI_production_data.xlsx';

[price,quantity, elas_D,elas_S] = importKDIData( commodities, ...
    filename_elasticities, filename_production );


%% Determine shock values 

disp(['Calculating shock effects...']);

[ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                         elas_D, elas_S, price, quantity);

% % calculate alpha shock values based on percent change
% alpha_shocks = quantity * percent_change - ...
%                 repmat(beta_s*price + alpha_s, 1, size(percent_change,2));
%       
% % no shock to commodity 1 or 2
% alpha_shocks(1,:) = 0;
% alpha_shocks(2,:) = 0;

shock_data = collectCommodityShocks('KDI_supply_shocks', 'electricity', 2, 3);
alpha_shocks = zeros(size(commodities, 2), size(shock_data, 1));
alpha_shocks(2,:) = [shock_data{:,2}];

%% Simluate shocks

plot_results = false;

[price_eqls, quantity_eqls ] = runSimulation( price, quantity, elas_D, ...
                        elas_S, alpha_shocks, iterations, plot_results);


%% Results

% number of supply shocks simulated
n = size(alpha_shocks,2);

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
CO2_reduction_grams = -quantity_rebound(1,:)*95*131.76;
CO2_reduction_megatonnes = CO2_reduction_grams*10^(-6);
        
% Formatted Data for xlsx
formatted_data = [percent_price_change', percent_quantity_change', ...
                    percent_quantity_rebound', CO2_reduction_megatonnes'];

%% Plot Results

pause;
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
ylabel('CO2 (megatonnes)');
title('CO2 Reduction');
grid on;


