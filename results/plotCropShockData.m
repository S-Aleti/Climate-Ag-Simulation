function [ fig ] = plotCropShockData( data, countries, crop, data_type, ...
                                    title_, y_axis )

% PLOTCROPSHOCKDATA simplifies plotting this model's results by outputting 
% a plot with some pre-defined parameters
% ========================================================================
% INPUT ARGUMENTS:
%   data                 (matrix)     data to plot
%   countries            (cell array) also serve as label for each line
%   crop                 (string)     name of crop to get data for
%   data_type            (int)        1 for % price change,
%                                     2 for % quantity change, 
%                                     3 for surplus_L1, 
%                                     4 for surplus_L2, 
%                                     5 for surplus_L3
%                                     6 for % consumer surplus change
%                                     7 for % producer surplus change
%   title_               (string)     title of the graph
%   y_axis               (string)     label for the y-axis
% ========================================================================
% OUTPUT:
%   figure1              
% ========================================================================

%% Extract data

filtered_data = zeros(length(countries), size(data,2)-3);

% add data specific to each country
for i = 1:length(countries)
    
    cell_data = searchResults(data, countries{i}, crop, data_type);
    
    if isempty(cell_data)
        error(['No data found for ' , countries{i}, ', ' , crop]);
    end
    
    filtered_data(i,:) = cell2mat(cell_data(1,4:size(data,2))); 
    
end


%% Create figure

fig = figure;
set(fig, 'Visible', 'off');


%% Add Data

% Create axes
axes1 = axes('Position',[0.13 0.11 0.775 0.815], 'FontSize', 6);
hold(axes1,'on');

% Create multiple lines using matrix input to plot
plot1 = plot([0:(size(filtered_data,2)-1)], filtered_data);


%% Plot Settings

% Label each line in the legend
for i = 1:size(countries,2)
    set(plot1(i),'DisplayName',countries{i});
end

% Change tick size
%fig.Children(2).FontSize = 9;

lgd = legend('show', 'Location', 'southwest');
lgd.FontSize = 7;

% Create xlabel
xlb = xlabel('Years since shock', 'FontSize', 11);
set(xlb, 'Units', 'Normalized', 'Position', [0.5, -0.065, 0]);

% Create ylabel
ylb = ylabel(y_axis, 'FontSize', 11);
set(ylb, 'Units', 'Normalized', 'Position', [-0.07, 0.5, 0]);

% Format y_ticks if y-axis is a % output
if any([1,2,6,7] == data_type) 
    %fig.Children(2).YTick = percentYticks(fig); 
end

% Create title
ttl = title(title_, 'FontSize', 12, 'FontWeight', 'bold');
set(ttl, 'Units', 'Normalized', 'Position', [0.5, 1.02, 0])

% Misc.
box(axes1,'on');
grid('on');


end