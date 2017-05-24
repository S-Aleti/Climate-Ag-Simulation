% =======================================================================
% The following code calculates the effects of biofuel shocks given in 
% KDI_supply_shocks.xlsx and stores the results in the variable
% "formatted data," which is formatted to match the spreadsheet 
% KDI_results.xlsx in the results folder
% =======================================================================

clear
close all

%% Parameters

% commodities to analyze
commodities = {'gasoline', 'electricity', 'natural gas'};

% commodity to shock
shock_commodity = 'electricity';

% percent shocks can be specified manually here
percent_shocks = [0.05:0.10:0.25] + 1;

% iterations for the market simulation
iterations = 15;

% SPECIFY HERE WHETHER TO USE KDI SHOCKS OR PREDEFINED PERCENT SHOCKS
use_KDI_shocks = false;


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
    shock_data = collectCommodityShocks('KDI_supply_shocks.xlsx', ...
                                    shock_commodity, 2, 3);
    shock_data = [shock_data{:,2}];
else
    shock_data =   quantity * percent_shocks - repmat(beta_s * ...
                      price + alpha_s, 1, size(percent_shocks,2));    
    shock_data = shock_data(row,:);
end

alpha_shocks = zeros(size(commodities, 2), size(shock_data, 2));
alpha_shocks(row,:) = shock_data;


%% Monte Carlo Simulation

% params
sigma = 0.05; % stdev of normal dist added to randomize elasticities
trials = 10000;
plot_results = false; 

% preallocate arrays
n = size(alpha_shocks,2);
price_change              = zeros(size(commodities,2), n, trials);
percent_price_change      = price_change;
quantity_change           = price_change;
percent_quantity_change   = price_change;
quantity_after_shock      = price_change;
quantity_rebound          = price_change;
percent_quantity_rebound  = price_change;
rebound_effect            = price_change;
percent_supply_shocks     = price_change(1,:,1);
CO2_reduction_grams       = price_change(1,:,:);
CO2_reduction_megatonnes  = CO2_reduction_grams;

tic
% open waitbar
h = waitbar(0,'Running Simulation');
data_size = trials;

for trial = 1:trials
    %% Randomize elasticities
    
    % elasticities are randomized 
    elas_D2 = randomizeElasticities(elas_D, 'normal', sigma);
    
    % gasoline own price demand elas is taken from a random uniform dist
    ind = find(~cellfun(@isempty,strfind(commodities, 'gasoline')));
    % based on Dahl and Sterner
    elas_D2(ind,ind) = randomizeElasticities( elas_D(ind,ind), ...
                        'uniform', -1.05, -0.16 ); 
    
    % electricity own price demand elas is taken from a normal dist
    ind = find(~cellfun(@isempty,strfind(commodities, 'electricity')));
    % based on Bernstein and Griffin
    elas_D2(ind,ind) = randomizeElasticities( elas_D(ind,ind), ...
                        'normal', 0.0753); 

    %% Simluate shocks
    
    [price_eqls, quantity_eqls ] = runSimulation( price, quantity, ...
                elas_D2, elas_S, alpha_shocks, iterations, plot_results);
             
    % update wait bar
    if (mod(trial,200)==0) waitbar(trial/data_size,h); end

    %% Results
    
	% Percent supply shock
    temp = alpha_shocks ./ repmat(quantity, 1, n);
    percent_supply_shocks(:,:) = temp(row,:);
    
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
    rebound_effect(:,:,trial) = (repmat(percent_supply_shocks, length( ...
        commodities), 1) + percent_quantity_rebound(:,:,trial)) ./     ...
        repmat(percent_supply_shocks, length(commodities), 1);
    
    % Decrease in CO2
    CO2_reduction_grams(:,:,trial) = -quantity_rebound(1,:,trial)*95*131.76;
    CO2_reduction_megatonnes(:,:,trial) = CO2_reduction_grams(:,:,trial)*10^(-6);

                    
end

close(h);
toc


%% Plot results for commodity shocked

close all

% PARAMS

% truncates % change graphs at -100%
percent_change_outlier_threshold = [-1, inf]; 
% drops samples outside 3 standard deviations
stdev_threshold = 3; 

legend_labels = cell(1,length(percent_supply_shocks));
for i = 1:length(legend_labels)
    legend_labels{i} = [num2str(100*percent_supply_shocks(i)), '% shock'];
end


%%% Price changes
data       = percent_price_change(row,:,:);
plot_title = 'Change in price of electricity after supply shocks';
x_label    = 'Price Change (%)';
y_label    = 'Probability';
bins       = 20;

plotShockHistogram(data, plot_title, x_label, y_label, legend_labels, ...
                bins, percent_change_outlier_threshold,  stdev_threshold);

            
%%% Quantity changes

data       = percent_quantity_change(row,:,:);
plot_title = 'Change in quantity of electricity after supply shocks';
x_label    = 'Quantity Change (%)';
y_label    = 'Probability';
bins       = 8;

plotShockHistogram(data, plot_title, x_label, y_label, legend_labels, ...
                bins, percent_change_outlier_threshold,  stdev_threshold);

          
%%% Quantity changes in non-biomass derived electricity

data       = percent_quantity_rebound(row,:,:);
plot_title = ['Change in quantity of non-biomass-derived electricity', ...
                'after supply shocks'];
x_label    = 'Quantity Change (%)';
y_label    = 'Probability';
bins       = 15;

plotShockHistogram(data, plot_title, x_label, y_label, legend_labels, ...
                bins, percent_change_outlier_threshold,  stdev_threshold);

%%% Rebound effect

data       = rebound_effect(row,:,:);
plot_title = 'Rebound effect on electricity after supply shocks';
x_label    = 'Rebound Effect';
y_label    = 'Probability';
bins       = 30;

plotShockHistogram(data, plot_title, x_label, y_label, legend_labels, ...
                bins, [-inf, inf],  stdev_threshold);

            
%%% CO2 reduction

data       = CO2_reduction_megatonnes(1,:,:);
plot_title = 'CO2 reduction after supply shocks';
x_label    = 'CO2 Reduction (megatonnes)';
y_label    = 'Probability';
bins       = 30;

plotShockHistogram(data, plot_title, x_label, y_label, legend_labels, ...
                bins, [-inf, inf],  stdev_threshold);

