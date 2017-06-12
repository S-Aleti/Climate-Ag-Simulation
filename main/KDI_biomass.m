% =======================================================================
% The following code calculates the effects of biomass shocks given in 
% KDI_supply_shocks.xlsx and stores the results in the variable
% "formatted data," which is formatted to match the spreadsheet 
% KDI_results.xlsx in the results folder
% =======================================================================

clear
close all

%% Parameters

% commodities to analyze
commodities = {'fuel', 'electricity', 'natural gas'};

% commodity to shock
shock_commodity = 'electricity';

% SPECIFY HERE WHETHER TO USE KDI SHOCKS OR PREDEFINED PERCENT SHOCKS
use_KDI_shocks = false;

% percent shocks can be specified manually here
percent_shocks = [0.05:0.05:1.00] + 1;

% iterations for the market simulation
iterations = 15;

% spreadsheet to update
filename = 'results/xlsx/KDI_results_randomsupply.xlsx';


%% Import Data

disp(['Importing elasticity and production data...']);

filename_elasticities  = 'KDI_elasticity_data.xlsx';
filename_production  = 'KDI_production_data.xlsx';

[price,quantity, elas_D,elas_S] = importKDIData( commodities, ...
    filename_elasticities, filename_production );


%% Determine shock values 

disp('Calculating shock effects...');

[ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                         elas_D, elas_S, price, quantity);

% find row corresponding to the given commodity to shock
row  = find(~cellfun(@isempty,strfind(commodities, shock_commodity)));

                                     
if use_KDI_shocks
    raw_shock_data = collectCommodityShocks('KDI_supply_shocks.xlsx', ...
                                    shock_commodity, 2, 3);
    shock_data = [raw_shock_data{:,2}];
else
    raw_shock_data =   quantity * percent_shocks - repmat(beta_s * ...
                      price + alpha_s, 1, size(percent_shocks,2));    
    shock_data = raw_shock_data(row,:);
end

alpha_shocks = zeros(size(commodities, 2), size(shock_data, 2));
alpha_shocks(row,:) = shock_data;


%% Simluate shocks

[price_eqls, quantity_eqls ] = runSimulation( price, quantity, elas_D, ...
                        elas_S, alpha_shocks, iterations, false);


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
percent_quantity_rebound = quantity_rebound ./ ...
                                repmat(quantity(row,:), 1, n);
rebound_effect = (percent_supply_shocks +  percent_quantity_rebound) ...
                 ./ percent_supply_shocks;
             
% Decrease in CO2
CO2_reduction = 976; %g/kWh saved from switching to biomass (Spath and Mann)
CO2_reduction_grams = -quantity_rebound(1,:) * CO2_reduction;
CO2_reduction_tonnes = CO2_reduction_grams*10^(-6);
       
%welfare calculations
CS = (-price_change(row,:) .* (quantity_eqls(row,:) ...
        + repmat(quantity(row,:), 1, n))./2);
PS_G = ( price_change(row,:) .* (quantity_eqls(row,:) ...
        - quantity_after_shock(row,:) + repmat(quantity(row,:), 1, n))./2);
PS_B = ( price_eqls(row,:) .* (percent_supply_shocks ...
        .* repmat(quantity(row,:), 1, n)));

% Formatted Data for xlsx
formatted_data = [percent_supply_shocks', percent_price_change',       ...
                  percent_quantity_change', percent_quantity_rebound', ...
                  rebound_effect', CO2_reduction_tonnes'];

              
%% Plot Results

close all;

if ~use_KDI_shocks

    %%% Price changes
    
    fig = figure;
    plot_prices = plot(percent_supply_shocks, percent_price_change');

    for i = 1:size(commodities,2)
        set(plot_prices(i),'DisplayName',commodities{i});
    end

    lgd = legend('show');
    xlabel('Supply Shock (%)');
    ylabel('Price change (%)');
    title('Change in prices after supply shocks');
    grid on;

    %%% Quantity changes
    fig = figure;
    plot_prices = plot(percent_supply_shocks, percent_quantity_change');

    for i = 1:size(commodities,2)
        set(plot_prices(i),'DisplayName',commodities{i});
    end

    lgd = legend('show');
    xlabel('Supply Shock (%)');
    ylabel('Quantity change (%)');
    title('Change in quantities after supply shocks');
    grid on;

    
    %%% Change in non-biomass-derived electricity
    fig = figure;
    plot_prices = plot(percent_supply_shocks, percent_quantity_rebound);
    %set(fig,'interpreter','none')

    set(plot_prices(1),'DisplayName', 'non-biomass-derived electricity');

    lgd = legend('show');
    xlabel('Supply Shock (%)');
    ylabel('Quantity change (%)');
    title('Change in non-biomass-derived electricity');
    grid on;
    

    %%% Rebound effect
    fig = figure;
    plot_prices = plot(percent_supply_shocks, rebound_effect);
    %set(fig,'interpreter','none')

    set(plot_prices(1),'DisplayName',commodities{row});

    lgd = legend('show');
    xlabel('Supply Shock (%)');
    ylabel('Rebound');
    title('Rebound effect');
    grid on;


    %%% CO2 reduction
    fig = figure;
    plot_prices = plot(percent_supply_shocks, CO2_reduction_tonnes);
    %set(fig,'interpreter','none')

    set(plot_prices(1),'DisplayName', 'Decrease in CO2');

    lgd = legend('show');
    xlabel('Supply Shock (%)');
    ylabel('CO2 (tonnes)');
    title('CO2 Reduction');
    grid on;
    
    
    %%% Welfare effects
    fig = figure;
    plot_prices = plot(percent_supply_shocks, [CS; PS_G; PS_B]);
    %set(fig,'interpreter','none')
    
    set(plot_prices(1),'DisplayName', 'CS');
    set(plot_prices(2),'DisplayName', 'PS_G');
    set(plot_prices(3),'DisplayName', 'PS_B');
    
    lgd = legend('show');
    xlabel('Supply Shock (%)');
    ylabel('Change in Surplus (won)');
    title('Weflare effects');
    grid on;
    
end


%% Update results

try

    sheet = 'electricity_shocks';

    xlswrite(filename, formatted_data,  sheet,  'G2');

    disp(['Results saved to ' , filename]);
    
catch
    
    disp(['Error recording results, ' , ...
                    'make sure you are in the root folder'])
    return;
    
end
