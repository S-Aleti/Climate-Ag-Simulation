% ========================================================================
% The following script compares the predictions of the counterfactual 
% model, the partial equillibrium model, and the multimarket model
% ========================================================================

%% Collect raw data

[ elas_data, pq_data, epq_data, cf_data ] = collectData( 'recollect' , ...
    'crop_data/xlsx_data/');

% counterfactual scenarios
scenarios_count = 2;
cf_data_scenarios = {};

for j = 1:scenarios_count
    
    file_name   = ['crop_data\xlsx_data/Counterfactual_Data_scenario'  ...
        num2str(j) '.xlsx'];
    cf_data_temp = {};

    % each sheet contains cf data for a specific commodity
    for i = 1:5
        cf_data_temp = [cf_data_temp; collectCounterfactualData(    ...
            file_name, 2, 1, 3, i)];
    end
    
    cf_data_scenarios{j} = cf_data_temp;

end


%% Get results

%%% Multimarket Model - Monte Carlo sim

% PARAMS
trials = 1;           % monte carlo trials
format_results = false; % set to true to get formatted results
% elasticities
elas_S_corn_soybean = -0.076;
elas_S_soybean_corn = -0.13;
elas_D_corn_soybean = 0.123;

% pre-alloc output for each multimarket trial
running_output = zeros(24*10, 7, trials); 

% distribution
% pd = makedist('Triangle', 'a', 0, 'b', 0.15, 'c', 0.30);
pd  = makedist('Uniform', 'lower', 0, 'upper', 0.30);

tic
% each trial takes about 3 seconds
for trial = 1:trials
    
    % get random counterfactual data
    cf_data = cf_data_scenarios{randi(scenarios_count)};
    
    % generate random elasticity
    elas_D_soybean_corn = 0%random(pd);

    [ results, ~, ~, ~ ]  = analyzeShocksCross(epq_data,                ...
        cf_data, format_results, elas_S_corn_soybean,                   ...
        elas_S_soybean_corn, elas_D_corn_soybean, elas_D_soybean_corn);
    
    running_output(:,:,trial) = results;
    
end
toc

multimarket_result = mean(running_output, 3);


%%% Partial Equillibrum Model and Counterfactual Percent Shocks

[partial_eq_result, ~, labels, counterfactual_percent_shocks] =         ...
    analyzeShocksCross(epq_data, cf_data, 0,0,0,0,0);


%% Export results to csv

% multimarket results
writetable(formatOutput(multimarket_result, labels ), ...
    'results/csv/results_multimarket.csv')

% partial eq results
writetable(formatOutput(partial_eq_result, labels ), ...
    'results/csv/results_partialeq.csv')


%% Compare changes in price, cons surplus, and prod surplus of soybean

countrycrops = {{'China', 'soybean'}, {'India', 'soybean'},             ...
    {'United States', 'soybean'}};
[ indexes ] = findCountryCropIndex( countrycrops, labels );


%%Percent Changes in price

% multimarket price changes
price_change_mm = [];

% partial eq price changes
price_change_pe = [];

for i = 0:9 % for each year
    price_change_mm = [price_change_mm; ...
        multimarket_result(indexes+24*i,1)'];
    price_change_pe = [price_change_pe; ...
        partial_eq_result(indexes+24*i,1)'];
end

figure; 

% partial eq subplot
subplot(2,1,1);
plot(0:9, price_change_pe)
legend({'China', 'India', 'US'})
title('Price Change of Soybean (Partial Eq)')
xlabel('Year'); ylabel('Percent Change');
axis([0 9 -1 1])
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, price_change_mm)
legend({'China', 'India', 'US'})
title('Price Change of Soybean (Multi-Market)')
xlabel('Year'); ylabel('Percent Change');
axis([0 9 -1 1])
grid('on')


%%Percent Changes in consumer surplus

% multimarket consumer surplus changes
cs_change_mm = [];

% partial eq consumer surplus changes
cs_change_pe = [];

for i = 0:9 % for each year
    cs_change_mm = [cs_change_mm; ...
        multimarket_result(indexes+24*i,7)'];
    cs_change_pe = [cs_change_pe; ...
        partial_eq_result(indexes+24*i,7)'];
end

figure; 

% partial eq subplot
subplot(2,1,1);
plot(0:9, cs_change_pe)
legend({'China', 'India', 'US'})
title('Consumer Surplus Change of Soybean (Partial Eq)')
xlabel('Year'); ylabel('Percent Change');
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, cs_change_mm)
legend({'China', 'India', 'US'})
title('Consumer Surplus Change of Soybean (Multi-Market)')
xlabel('Year'); ylabel('Percent Change');
grid('on')


%%Percent Changes in producer surplus

% multimarket producer surplus changes
ps_change_mm = [];

% partial eq producer surplus changes
ps_change_pe = [];

for i = 0:9 % for each year
    ps_change_mm = [ps_change_mm; ...
        multimarket_result(indexes+24*i,6)'];
    ps_change_pe = [ps_change_pe; ...
        partial_eq_result(indexes+24*i,6)'];
end

figure; 

% partial eq subplot
subplot(2,1,1);
plot(0:9, ps_change_pe)
legend({'China', 'India', 'US'})
title('Producer Surplus Change of Soybean (Partial Eq)')
xlabel('Year'); ylabel('Percent Change');
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, ps_change_mm)
legend({'China', 'India', 'US'})
title('Producer Surplus Change of Soybean (Multi-Market)')
xlabel('Year'); ylabel('Percent Change');
grid('on')


%% Compare changes in price, cons surplus, and prod surplus of Corn

countrycrops = {{'China', 'corn'}, {'India', 'corn'},                   ...
    {'United States', 'corn'}};
[ indexes ] = findCountryCropIndex( countrycrops, labels );


%%Percent Changes in price

% multimarket price changes
price_change_mm = [];

% partial eq price changes
price_change_pe = [];

for i = 0:9 % for each year
    price_change_mm = [price_change_mm; ...
        multimarket_result(indexes+24*i,1)'];
    price_change_pe = [price_change_pe; ...
        partial_eq_result(indexes+24*i,1)'];
end

figure; 

% partial eq subplot
subplot(2,1,1);
plot(0:9, price_change_pe)
legend({'China', 'India', 'US'})
title('Price Change of Corn (Partial Eq)')
xlabel('Year'); ylabel('Percent Change');
axis([0 9 -0.5 1])
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, price_change_mm)
legend({'China', 'India', 'US'})
title('Price Change of Corn (Multi-Market)')
xlabel('Year'); ylabel('Percent Change');
axis([0 9 -0.5 1])
grid('on')


%%Percent Changes in consumer surplus

% multimarket consumer surplus  changes
cs_change_mm = [];

% partial eq consumer surplus  changes
cs_change_pe = [];

for i = 0:9 % for each year
    cs_change_mm = [cs_change_mm; ...
        multimarket_result(indexes+24*i,7)'];
    cs_change_pe = [cs_change_pe; ...
        partial_eq_result(indexes+24*i,7)'];
end

figure; 

% partial eq subplot
subplot(2,1,1);
plot(0:9, cs_change_pe)
legend({'China', 'India', 'US'})
title('Consumer Surplus Change of Corn (Partial Eq)')
xlabel('Year'); ylabel('Percent Change');
axis([0 9 -0.5 1])
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, cs_change_mm)
legend({'China', 'India', 'US'})
title('Consumer Surplus Change of Corn (Multi-Market)')
xlabel('Year'); ylabel('Percent Change');
axis([0 9 -0.5 1])
grid('on')


%%Percent Changes in producer surplus

% multimarket producer surplus changes
ps_change_mm = [];

% partial eq producer surplus changes
ps_change_pe = [];

for i = 0:9 % for each year
    ps_change_mm = [ps_change_mm; ...
        multimarket_result(indexes+24*i,6)'];
    ps_change_pe = [ps_change_pe; ...
        partial_eq_result(indexes+24*i,6)'];
end

figure; 

% partial eq subplot
subplot(2,1,1);
plot(0:9, ps_change_pe)
legend({'China', 'India', 'US'})
title('Producer Surplus Change of Corn (Partial Eq)')
xlabel('Year'); ylabel('Percent Change');
axis([0 9 -0.5 1])
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, ps_change_mm)
legend({'China', 'India', 'US'})
title('Producer Surplus Change of Corn (Multi-Market)')
xlabel('Year'); ylabel('Percent Change');
axis([0 9 -0.5 1])
grid('on')


%% Quantity Comparison

countrycrops = {{'China', 'soybean'}, {'India', 'soybean'},             ...
    {'United States', 'soybean'}, {'China', 'corn'}, {'India', 'corn'}, ...
    {'United States', 'corn'}};


%%% Chinese Soybean

[ indexes ] = findCountryCropIndex(countrycrops(1), labels);

figure; hold on;
plot(0:9, counterfactual_percent_shocks(indexes, :))

% multimarket quantity changes
q_change_mm = [];

% partial eq quantity changes
q_change_pe = [];

for i = 0:9 % for each year
    q_change_mm = [q_change_mm; ...
        multimarket_result(indexes+24*i,2)'];
    q_change_pe = [q_change_pe; ...
        partial_eq_result(indexes+24*i,2)'];
end

plot(0:9, q_change_pe)
plot(0:9, q_change_mm)

legend({'Counterfactual Scenario', 'Partial Eq Simulation',             ...
    'Multi-Market Simulation'})
title('Change in Quantity of Chinese Soybean')
y_ticks = round(get(gca,'ytick'), 3);
set(gca, 'yticklabel', [num2str(y_ticks'*100)                           ...
    repmat('%', length(y_ticks), 1)])
xlabel('Year'); ylabel('Percent Change');
grid('on')

%%% Indian Soybean

[ indexes ] = findCountryCropIndex(countrycrops(2), labels);

figure; hold on;
plot(0:9, counterfactual_percent_shocks(indexes, :))

% multimarket quantity changes
q_change_mm = [];

% partial eq quantity changes
q_change_pe = [];

for i = 0:9 % for each year
    q_change_mm = [q_change_mm; ...
        multimarket_result(indexes+24*i,2)'];
    q_change_pe = [q_change_pe; ...
        partial_eq_result(indexes+24*i,2)'];
end

plot(0:9, q_change_pe)
plot(0:9, q_change_mm)

legend({'Counterfactual Scenario', 'Partial Eq Simulation',             ...
    'Multi-Market Simulation'})
title('Change in Quantity of Indian Soybean')
y_ticks = round(get(gca,'ytick'), 3);
set(gca, 'yticklabel', [num2str(y_ticks'*100)                           ...
    repmat('%', length(y_ticks), 1)])
xlabel('Year'); ylabel('Percent Change');
grid('on')

%%% US Soybean

[ indexes ] = findCountryCropIndex(countrycrops(3), labels);

figure; hold on;
plot(0:9, counterfactual_percent_shocks(indexes, :))

% multimarket quantity changes
q_change_mm = [];

% partial eq quantity changes
q_change_pe = [];

for i = 0:9 % for each year
    q_change_mm = [q_change_mm; ...
        multimarket_result(indexes+24*i,2)'];
    q_change_pe = [q_change_pe; ...
        partial_eq_result(indexes+24*i,2)'];
end

plot(0:9, q_change_pe)
plot(0:9, q_change_mm)

legend({'Counterfactual Scenario', 'Partial Eq Simulation',             ...
    'Multi-Market Simulation'})
title('Change in Quantity of US Soybean')
y_ticks = round(get(gca,'ytick'), 3);
set(gca, 'yticklabel', [num2str(y_ticks'*100)                           ...
    repmat('%', length(y_ticks), 1)])
xlabel('Year'); ylabel('Percent Change');
grid('on')

%%% Chinese Corn

[ indexes ] = findCountryCropIndex(countrycrops(4), labels);

figure; hold on;
plot(0:9, counterfactual_percent_shocks(indexes, :))

% multimarket quantity changes
q_change_mm = [];

% partial eq quantity changes
q_change_pe = [];

for i = 0:9 % for each year
    q_change_mm = [q_change_mm; ...
        multimarket_result(indexes+24*i,2)'];
    q_change_pe = [q_change_pe; ...
        partial_eq_result(indexes+24*i,2)'];
end

plot(0:9, q_change_pe)
plot(0:9, q_change_mm)

legend({'Counterfactual Scenario', 'Partial Eq Simulation',             ...
    'Multi-Market Simulation'})
title('Change in Quantity of Chinese Corn')
y_ticks = round(get(gca,'ytick'), 3);
set(gca, 'yticklabel', [num2str(y_ticks'*100)                           ...
    repmat('%', length(y_ticks), 1)])
xlabel('Year'); ylabel('Percent Change');
grid('on')

%%% Indian Corn

[ indexes ] = findCountryCropIndex(countrycrops(5), labels);

figure; hold on;
plot(0:9, counterfactual_percent_shocks(indexes, :))

% multimarket quantity changes
q_change_mm = [];

% partial eq quantity changes
q_change_pe = [];

for i = 0:9 % for each year
    q_change_mm = [q_change_mm; ...
        multimarket_result(indexes+24*i,2)'];
    q_change_pe = [q_change_pe; ...
        partial_eq_result(indexes+24*i,2)'];
end

plot(0:9, q_change_pe)
plot(0:9, q_change_mm)

legend({'Counterfactual Scenario', 'Partial Eq Simulation',             ...
    'Multi-Market Simulation'})
title('Change in Quantity of Indian Corn')
y_ticks = round(get(gca,'ytick'), 3);
set(gca, 'yticklabel', [num2str(y_ticks'*100)                           ...
    repmat('%', length(y_ticks), 1)])
xlabel('Year'); ylabel('Percent Change');
grid('on')

%%% US Corn

[ indexes ] = findCountryCropIndex(countrycrops(6), labels);

figure; hold on;
plot(0:9, counterfactual_percent_shocks(indexes, :))

% multimarket quantity changes
q_change_mm = [];

% partial eq quantity changes
q_change_pe = [];

for i = 0:9 % for each year
    q_change_mm = [q_change_mm; ...
        multimarket_result(indexes+24*i,2)'];
    q_change_pe = [q_change_pe; ...
        partial_eq_result(indexes+24*i,2)'];
end

plot(0:9, q_change_pe)
plot(0:9, q_change_mm)

legend({'Counterfactual Scenario', 'Partial Eq Simulation',             ...
    'Multi-Market Simulation'})
title('Change in Quantity of US Corn')
y_ticks = round(get(gca,'ytick'), 3);
set(gca, 'yticklabel', [num2str(y_ticks'*100)                           ...
    repmat('%', length(y_ticks), 1)])
xlabel('Year'); ylabel('Percent Change');
grid('on')


%% Average Quantity Model Comparison

%%% Soybean

[ indexes ] = findCountryCropIndex(countrycrops(1:3), labels);

% counterfactual quantity changes
avg_q_change_cf = mean(counterfactual_percent_shocks(indexes, :), 2)';

% multimarket quantity changes
avg_q_change_mm = zeros(1, 3);

% partial eq quantity changes
avg_q_change_pe = zeros(1, 3);

for i = 0:9 % for each year
    avg_q_change_mm = avg_q_change_mm + ...
        multimarket_result(indexes+24*i,2)'/10;
    avg_q_change_pe = avg_q_change_pe + ...
        partial_eq_result(indexes+24*i,2)'/10;
end

figure; 

plot_labels = {};

for i = 1:3
    plot_labels{i} = countrycrops{i}{1};
end

bar(categorical(plot_labels), ...
    [avg_q_change_cf; avg_q_change_mm; avg_q_change_pe]')
y_ticks = round(get(gca,'ytick'), 3);
set(gca, 'yticklabel', [num2str(y_ticks'*100)                           ...
    repmat('%', length(y_ticks), 1)])
legend({'Counterfactual', 'Multi-Market', 'Partial Equillibrium'})
xlabel('Year'); ylabel('Average Percent Change');
title('Average % Change in Quantity of Soybean')


%%% Corn

[ indexes ] = findCountryCropIndex(countrycrops(4:6), labels);

% counterfactual quantity changes
avg_q_change_cf = mean(counterfactual_percent_shocks(indexes, :), 2)';

% multimarket quantity changes
avg_q_change_mm = zeros(1, 3);

% partial eq quantity changes
avg_q_change_pe = zeros(1, 3);

for i = 0:9 % for each year
    avg_q_change_mm = avg_q_change_mm + ...
        multimarket_result(indexes+24*i,2)'/10;
    avg_q_change_pe = avg_q_change_pe + ...
        partial_eq_result(indexes+24*i,2)'/10;
end

figure; 

plot_labels = {};

for i = 4:6
    plot_labels{i-3} = countrycrops{i}{1};
end

bar(categorical(plot_labels), ...
    [avg_q_change_cf; avg_q_change_mm; avg_q_change_pe]')
y_ticks = round(get(gca,'ytick'), 3);
set(gca, 'yticklabel', [num2str(y_ticks'*100)                           ...
    repmat('%', length(y_ticks), 1)])
legend({'Counterfactual', 'Multi-Market', 'Partial Equillibrium'})
xlabel('Year'); ylabel('Average Percent Change');
title('Average % Change in Quantity of Corn')
