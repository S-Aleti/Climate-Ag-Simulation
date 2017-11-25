% ========================================================================
% The following script compares the predictions of the counterfactual 
% model, the partial equillibrium model, and the multimarket model
% ========================================================================

%% Get results

[ elas_data, pq_data, epq_data, cf_data ] = collectData( 'load' );

%%% Multimarket Model - Monte Carlo sim

% PARAMS
trials = 10;           % monte carlo trials
format_results = false; % set to true to get formatted results
% elasticities
elas_S_corn_soybean = -0.076/10;
elas_S_soybean_corn = -0.13/10;
elas_D_corn_soybean = 0.123/10;

% pre-alloc output for each multimarket trial
running_output = zeros(24*10, 7, trials); 

% distribution
% pd = makedist('Triangle', 'a', 0, 'b', 0.15, 'c', 0.30);
pd  = makedist('Uniform', 'lower', 0, 'upper', 0.30);

tic
% each trial takes about 3 seconds
for trial = 1:trials
    
    % generate random elasticity
    elas_D_soybean_corn = random(pd)/10;

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


%% Compare changes in price, cons surplus, and prod surplus of soybean

countrycrops = {{'China', 'soybean'}, {'India', 'soybean'},             ...
    {'United States', 'soybean'}};
[ indexes ] = findCountryCropIndex( countrycrops, labels );


%%% Changes in price

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
xlabel('Year'); ylabel('% Change');
axis([0 9 -1 1])
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, price_change_mm)
legend({'China', 'India', 'US'})
title('Price Change of Soybean (Multi-Market)')
xlabel('Year'); ylabel('% Change');
axis([0 9 -1 1])
grid('on')


%%% Changes in consumer surplus

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
xlabel('Year'); ylabel('% Change');
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, cs_change_mm)
legend({'China', 'India', 'US'})
title('Consumer Surplus Change of Soybean (Multi-Market)')
xlabel('Year'); ylabel('% Change');
grid('on')


%%% Changes in producer surplus

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
xlabel('Year'); ylabel('% Change');
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, ps_change_mm)
legend({'China', 'India', 'US'})
title('Producer Surplus Change of Soybean (Multi-Market)')
xlabel('Year'); ylabel('% Change');
grid('on')


%% Compare changes in price, cons surplus, and prod surplus of Corn

countrycrops = {{'China', 'corn'}, {'India', 'corn'},                   ...
    {'United States', 'corn'}};
[ indexes ] = findCountryCropIndex( countrycrops, labels );


%%% Changes in price

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
xlabel('Year'); ylabel('% Change');
axis([0 9 -0.5 1])
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, price_change_mm)
legend({'China', 'India', 'US'})
title('Price Change of Corn (Multi-Market)')
xlabel('Year'); ylabel('% Change');
axis([0 9 -0.5 1])
grid('on')


%%% Changes in consumer surplus

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
xlabel('Year'); ylabel('% Change');
axis([0 9 -0.5 1])
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, cs_change_mm)
legend({'China', 'India', 'US'})
title('Consumer Surplus Change of Corn (Multi-Market)')
xlabel('Year'); ylabel('% Change');
axis([0 9 -0.5 1])
grid('on')


%%% Changes in producer surplus

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
xlabel('Year'); ylabel('% Change');
axis([0 9 -0.5 1])
grid('on')

% multimarket subplot
subplot(2,1,2);
plot(0:9, ps_change_mm)
legend({'China', 'India', 'US'})
title('Producer Surplus Change of Corn (Multi-Market)')
xlabel('Year'); ylabel('% Change');
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
grid('on')

%%% US Corn

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
title('Change in Quantity of US Corn')
y_ticks = round(get(gca,'ytick'), 3);
set(gca, 'yticklabel', [num2str(y_ticks'*100)                           ...
    repmat('%', length(y_ticks), 1)])
grid('on')