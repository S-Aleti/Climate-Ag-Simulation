% =======================================================================
% The following code calculates the effects of biomass shocks given in 
% KDI_supply_shocks.xlsx and stores the results in the variable
% "formatted data," which is formatted to match the spreadsheet 
% KDI_results.xlsx in the results folder
% =======================================================================

close all

%% Parameters

% commodities to analyze
commodities = {'fuel', 'electricity', 'natural gas'};

% commodity to shock
shock_commodity = 'electricity';

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

shock_data = collectCommodityShocks('KDI_supply_shocks.xlsx', ...
                                        shock_commodity, 2, 3);

% find row corresponding to the given commodity to shock
row  = find(~cellfun(@isempty,strfind(commodities, shock_commodity)));

alpha_shocks = zeros(size(commodities, 2), size(shock_data, 1));
alpha_shocks(row,:) = [shock_data{:,2}];


%% Simluate shocks

plot_results = false;

[price_eqls, quantity_eqls ] = runSimulation( price, quantity, elas_D, ...
                        elas_S, alpha_shocks, iterations, plot_results);


%% Results

% number of supply shocks simulated
n = size(alpha_shocks,2);

% Percent supply shock
percent_supply_shocks = alpha_shocks ./ repmat(quantity, 1, n);
percent_supply_shocks = percent_supply_shocks(row,:);

% Price changes
price_change = price_eqls - repmat(price, 1, n);
percent_price_change = price_change ./ repmat(price, 1, n);

% Quantity changes
quantity_change = quantity_eqls - repmat(quantity, 1, n);
percent_quantity_change = quantity_change ./ repmat(quantity, 1, n);
quantity_after_shock = repmat(quantity,1,n) + alpha_shocks;

% Rebound effect
quantity_rebound = quantity_eqls(row,:) - quantity_after_shock(row,:);
percent_quantity_rebound = quantity_rebound ./ quantity_after_shock(row,:);
rebound_effect = (percent_supply_shocks +  percent_quantity_rebound) ...
                 ./ percent_supply_shocks;
             
% Decrease in CO2
CO2_reduction = 976; %g/kWh saved from switching to biomass (Spath and Mann)
CO2_reduction_grams = -quantity_rebound(1,:) * CO2_reduction;
CO2_reduction_tonnes = CO2_reduction_grams*10^(-6);
        
% Formatted Data for xlsx
formatted_data = [percent_supply_shocks', percent_price_change',       ...
                  percent_quantity_change', percent_quantity_rebound', ...
                  rebound_effect', CO2_reduction_tonnes'];

              
%% Plot Results

% -----------------------------------------------------------------------
% Use the following to plot if shocks based on percent changes are used
% Plots are non-sensical if using specific supply shocks from
% KDI_supply_shocks.xlsx
% -----------------------------------------------------------------------

% close all;
% 
% % Price changes
% fig = figure;
% plot_prices = plot(percent_quantity_change, percent_price_change');
% %set(fig,'interpreter','none')
% 
% for i = 1:size(commodities,2)
%     set(plot_prices(i),'DisplayName',commodities{i});
% end
% 
% lgd = legend('show');
% xlabel('Supply Shock (%)');
% ylabel('Price change (%)');
% title('Change in prices after supply shocks');
% grid on;
% 
% % Quantity changes
% fig = figure;
% plot_prices = plot(percent_change-1, percent_quantity_change');
% %set(fig,'interpreter','none')
% 
% for i = 1:size(commodities,2)
%     set(plot_prices(i),'DisplayName',commodities{i});
% end
% 
% lgd = legend('show');
% xlabel('Supply Shock (%)');
% ylabel('Quantity change (%)');
% title('Change in quantities after supply shocks');
% grid on;
% 
% 
% % Rebound effect
% fig = figure;
% plot_prices = plot(percent_change-1, percent_quantity_rebound');
% %set(fig,'interpreter','none')
% 
% for i = 1:size(commodities,2)
%     set(plot_prices(i),'DisplayName',commodities{i});
% end
% 
% lgd = legend('show');
% xlabel('Supply Shock (%)');
% ylabel('Quantity change (%)');
% title('Rebound effects');
% grid on;
% 
% 
% % CO2 reduction
% fig = figure;
% plot_prices = plot(percent_change-1, CO2_reduction_megatonnes');
% %set(fig,'interpreter','none')
% 
% set(plot_prices(1),'DisplayName', 'Decrease in CO2');
% 
% lgd = legend('show');
% xlabel('Supply Shock (%)');
% ylabel('CO2 (tonnes)');
% title('CO2 Reduction');
% grid on;


