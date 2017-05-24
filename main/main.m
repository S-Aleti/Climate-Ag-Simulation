%% Collect Data

% change arg to 'recollect' to recollect the data, or just use 'load' to
% use the previously collected data (faster)
[ elas_data, pq_data, epq_data, cf_data ] = collectData( 'load' );

%% Anaylze Data

data = analyzeShocks(epq_data, cf_data);

%% Graph Results

graphResults