%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Runs Monte Carlo trails on the KDI Data %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

close all

%% Parameters

% commodities to analyze
commodities = {'gasoline', 'electricity', 'natural gas'};

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

% calculate alpha shock values based on percent change
alpha_shocks = quantity * percent_change - ...
                repmat(beta_s*price + alpha_s, 1, size(percent_change,2));
      
% no shock to commodity 1 or 2
alpha_shocks(2,:) = 0;
alpha_shocks(3,:) = 0;

% shock_data = collectCommodityShocks('KDI_supply_shocks', 'electricity', 2, 3);
% alpha_shocks = zeros(size(commodities, 2), size(shock_data, 1));
% alpha_shocks(2,:) = [shock_data{:,2}];

%% Monte Carlo

% params
sigma_D = 0.03;
sigma_S = 0.02;
trials = 1000;
plot_results = false; 

% preallocate arrays
n = size(alpha_shocks,2);
price_change = zeros(size(commodities,2), n, trials);
percent_price_change = price_change;
quantity_change = price_change;
percent_quantity_change = price_change;
quantity_after_shock = price_change;
quantity_rebound = price_change;
percent_quantity_rebound = price_change;
CO2_reduction_grams = price_change(1,:,:);
CO2_reduction_megatonnes = CO2_reduction_grams;

tic
% open waitbar
h = waitbar(0,'Running MC Sim');
data_size = trials;

for trial = 1:trials

    % add RV to elasticities
    [elas_D2, elas_S2] = randomizeElasticities(elas_D, elas_S, sigma_D, ...
                                                    sigma_S);
    
    %% Simluate shocks
    
    [price_eqls, quantity_eqls ] = runSimulation( price, quantity, ...
                 elas_D2, elas_S, alpha_shocks, iterations, plot_results);
             
    % update wait bar
    if (mod(trial,200)==0) waitbar(trial/data_size,h); end

    %% Results
	
    % Price changes
    price_change(:,:,trial) = price_eqls - repmat(price, 1, n);
    percent_price_change(:,:,trial) = price_change(:,:,trial) ./ ...
                                        repmat(price, 1, n);
   
    % Quantity changes
    quantity_change(:,:,trial) = quantity_eqls - repmat(quantity, 1, n);
    percent_quantity_change(:,:,trial) = quantity_change(:,:,trial) ./ ...
                                            repmat(quantity, 1, n);
    quantity_after_shock(:,:,trial) = repmat(quantity,1,n) + alpha_shocks;
    
    % Rebound effect
    quantity_rebound(:,:,trial) = quantity_eqls - ...
                                    quantity_after_shock(:,:,trial);
    percent_quantity_rebound(:,:,trial) = quantity_rebound(:,:,trial) ./...
                                           quantity_after_shock(:,:,trial);
    
    % Decrease in CO2
    CO2_reduction_grams(:,:,trial) = -quantity_rebound(1,:,trial)*95*131.76;
    CO2_reduction_megatonnes(:,:,trial) = CO2_reduction_grams(:,:,trial)*10^(-6);
    
    % Formatted Data for xlsx
    %formatted_data = [percent_price_change', percent_quantity_change', ...
    %                    percent_quantity_rebound', CO2_reduction_megatonnes'];
                    
end

close(h);
toc

%% Plot results for commodity j

close all;

% PARAMETERS
j = 1; % commodity index from "commodities" var
bins = 20;


% Price changes
fig = figure;

for i = 1:length(percent_change)
    h(i) = histogram(reshape(100*percent_price_change(j,i,:),1,trials),bins);
    set(h(i),'DisplayName',[num2str(100*(percent_change(i)-1)), '% shock']);
    hold on;
end

lgd = legend('show');
xlabel('Price change (%)');
ylabel(['Frequency', ' (max: ', num2str(trials), ')']);
title(['Change in price of fuel after supply shocks']);
grid on;


% Quantity changes
fig = figure;

for i = 1:length(percent_change)
    h(i) = histogram(reshape(100*percent_quantity_change(j,i,:),1,trials),bins);
    set(h(i),'DisplayName',[num2str(100*(percent_change(i)-1)), '% shock']);
    hold on;
end

lgd = legend('show');
xlabel('Quantity change (%)');
ylabel(['Frequency', ' (max: ', num2str(trials), ')']);
title(['Change in quantity of fuel after supply shocks']);
grid on;


% Rebound effect
fig = figure;

for i = 1:length(percent_change)
    h(i) = histogram(reshape(100*percent_quantity_rebound(j,i,:),1,trials),bins);
    set(h(i),'DisplayName',[num2str(100*(percent_change(i)-1)), '% shock']);
    hold on;
end


lgd = legend('show');
xlabel('Quantity change (%)');
ylabel(['Frequency', ' (max: ', num2str(trials), ')']);
title(['Change in quantity of ', commodities{j}, ' after supply shocks']);
grid on;


% CO2 reduction
fig = figure;

for i = 1:length(percent_change)
    h(i) = histogram(reshape(CO2_reduction_megatonnes(1,i,:),1,trials),bins);
    set(h(i),'DisplayName',[num2str(100*(percent_change(i)-1)), '% shock']);
    hold on;
end

lgd = legend('show');
xlabel('CO2 Reduction (megatonnes)');
ylabel(['Frequency', ' (max: ', num2str(trials), ')']);
title(['CO2 reduction after supply shocks']);
grid on;

