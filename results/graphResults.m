% ========================================================================
%
% Graphs the results of analyzeShocks.m
%
% ========================================================================


%% Corn

% USA, China, Brazil
corn_USA_prices    = findResults(data, 'United States',  'corn', 1);
corn_China_prices  = findResults(data, 'China',          'corn', 1);
corn_Brazil_prices = findResults(data, 'Brazil',         'corn', 1);

% Prices in a matrix
prices = [cell2mat(corn_USA_prices(1,4:13));
          cell2mat(corn_China_prices(1,4:13));
          cell2mat(corn_Brazil_prices(1,4:13))];

% Graphs
corn_prices_fig = plotShockData(prices, {'USA', 'China',  'Brazil'},   ...
                                'Corn prices', '% Price Change');

% Save Results
saveas(corn_prices_fig, 'results\graphs\corn_prices.fig');
saveas(corn_prices_fig, 'results\graphs\corn_prices.png');

%% Soybeans

% USA, China, Brazil
soybean_USA_prices    = findResults(data, 'United States',  'soybean', 1);
soybean_China_prices  = findResults(data, 'China',          'soybean', 1);
soybean_Brazil_prices = findResults(data, 'Brazil',         'soybean', 1);
soybean_India_prices  = findResults(data, 'India',          'soybean', 1);

% Prices in a matrix
prices = [cell2mat(soybean_USA_prices(1,4:13))   ;
          cell2mat(soybean_China_prices(1,4:13)) ;
          cell2mat(soybean_Brazil_prices(1,4:13));
          cell2mat(soybean_India_prices(1,4:13)) ];

% Graphs
soybean_prices_fig = plotShockData( prices, {'USA', 'China', 'Brazil', ...
                                    'India'}, 'Soybean prices',  ... 
                                    '% Price Change');
                                      
% Save reults
saveas(soybean_prices_fig, 'results\graphs\soybean_prices.fig');
saveas(soybean_prices_fig, 'results\graphs\soybean_prices.png');
                                      
%% Show graphs

figure(corn_prices_fig);
figure(soybean_prices_fig);