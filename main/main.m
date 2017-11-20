%% Collect Data

% change arg to 'recollect' to recollect the data, or just use 'load' to
% use the previously collected data (faster)
[ elas_data, pq_data, epq_data, cf_data ] = collectData( 'load' );

%% Anaylze Data

data = analyzeShocks(epq_data, cf_data);

%% Graph Results

% graphResults

%% Export Data

exportData(data, 'results/csv/results.csv');

%% Averages

countries = unique(data_table{:,'Country'});

table_avg = varfun(@mean, data_table, 'GroupingVariables', {'Country', 'Crop'})
% table for average change over 10 years for each crop and country
% soybean cross price elas [0, 0.15, 0.3] triangle, only soybean/corn (see
% email)
% compute rebound effects
% don't overwrite dropbox stuff