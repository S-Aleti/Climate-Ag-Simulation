% ========================================================================
%
% Graphs the results of analyzeShocks.m
%
% ========================================================================
close all


%% Corn

% input args
countries      = {'United States', 'China', 'Brazil', 'India'};
crop           = 'corn';
data_type      = 7; % returns percent change in producer surplus
graph_title    = 'Change in corn producer surplus over time';
y_axis_label   = '% change in surplus';


% plot
fig = plotCropShockData( data, countries, crop, data_type,              ...
                             graph_title, y_axis_label );
                  
% shows figure              
figure(fig); 
% converts y labels to percentages
percentYticks(gca);
% change figure size to 6.5 x 4 inches
fig.PaperPosition = [1, 3, 6.5 3];

% Save Results
%saveas(fig, 'results\graphs\corn_prices.fig');
saveas(fig, 'results\graphs\corn_prices.png');


%% Soybeans

% input args
countries      = {'United States', 'China', 'Brazil', 'India'};
crop           = 'soybean';
data_type      = 7; % returns percent change in producer surplus
graph_title    = 'Change in soybean producer surplus over time';
y_axis_label   = '% change in surplus';


% plot
fig = plotCropShockData( data, countries, crop, data_type, ...
                            graph_title, y_axis_label );
                  
% shows figure              
figure(fig); 
% converts y labels to percentages
percentYticks(gca);
% change figure size to 6.5 x 4 inches
fig.PaperPosition = [1, 3, 6.5 3];            
                  
% Save reults
%saveas(fig, 'results\graphs\soybean_prices.fig');
saveas(fig, 'results\graphs\soybean_prices.png');


%% Local Funcs

function [] = percentYticks(gca) 
% ========================================================================
% Converts decimal y ticks on a graph to percentages
% ========================================================================

% Get current y ticks
L = get(gca, 'yticklabels');

% Convert to percentages
yticks = num2str(cellfun(@str2num, L)*100) + "%";

set(gca, 'yticklabels', yticks);

end