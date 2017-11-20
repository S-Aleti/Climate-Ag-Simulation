%% Collect Data

% change arg to 'recollect' to recollect the data, or just use 'load' to
% use the previously collected data (faster)
[ elas_data, pq_data, epq_data, cf_data ] = collectData( 'load' );


%% Get Results

% PARAMS
trials = 100;           % monte carlo trials
format_results = false; % set to true to get formatted results
% elasticities
elas_S_corn_soybean = -0.076;
elas_S_soybean_corn = -0.13;
elas_D_corn_soybean = 0.123;

% pre-alloc
running_output = zeros(24*10, 7, trials); % contains output for each trial

% distribution
% pd = makedist('Triangle', 'a', 0, 'b', 0.15, 'c', 0.30);
pd  = makedist('Uniform', 'lower', 0, 'upper', 0.30);

tic
% each trial takes about 3 seconds
parfor trial = 1:trials
    
    % generate random elasticity
    elas_D_soybean_corn = random(pd);

    [ results, ~, ~ ]  = analyzeShocksCross(epq_data,                ...
        cf_data, format_results, elas_S_corn_soybean,                   ...
        elas_S_soybean_corn, elas_D_corn_soybean, elas_D_soybean_corn);
    
    running_output(:,:,trial) = results;
    
end
toc

average_result = mean(running_output, 3);

% filtered data contains list of countries and crops analyzed
[ ~, ~, filtered_data ] = analyzeShocksCross(epq_data, cf_data, 0,0,0,0,0);


%% Find rebound effect

rebound = calculateReboundEffect(cf_data, results_matrix, filtered_data);


%% Format Results

% contains results for each year, average of monte carlo simulation
data_table_mean = formatOutput( average_result, labels );

% contains data_table_mean averaged across all years
table_yrs_avg = varfun(@mean, data_table_mean, 'GroupingVariables',     ...
                            {'Country', 'Crop'});
table_yrs_avg(:, 'mean_Year') = [];
