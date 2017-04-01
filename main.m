%% Collect Data

[ elas_data, pq_data, epq_data, cf_data ] = collectData( 'load' );

%% Anaylze Data

data = analyzeShocks(epq_data, cf_data);

%% Graph Results

graphResults