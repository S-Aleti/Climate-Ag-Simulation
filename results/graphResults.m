% ========================================================================
%
% Graphs the results of analyzeShocks.m
%
% ========================================================================


%% Corn

% input args
countries      = {'United States', 'China', 'Brazil'};
crop           = 'corn';
data_type      = 7; % returns percent change in producer surplus
title_of_graph = 'Change in corn producer surplus over time';
y_axis_label   = '% change in surplus';


% plot
fig = plotShockData( data, countries, crop, data_type, title_of_graph, ...
                      y_axis_label );
figure(fig); % shows figure
                  
% Save Results
saveas(fig, 'results\graphs\corn_prices.fig');
saveas(fig, 'results\graphs\corn_prices.png');

%% Soybeans

% input args
countries      = {'United States', 'China', 'Brazil', 'India'};
crop           = 'soybean';
data_type      = 7; % returns percent change in producer surplus
title_of_graph = 'Change in soybean producer surplus over time';
y_axis_label   = '% change in surplus';


% plot
fig = plotShockData( data, countries, crop, data_type, title_of_graph, ...
                      y_axis_label );
figure(fig); % shows figure
                  
% Save reults
%saveas(fig, 'results\graphs\soybean_prices.fig');
%saveas(fig, 'results\graphs\soybean_prices.png');