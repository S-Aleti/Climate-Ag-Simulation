function [ fig ] = plotShockData( data, labels, title_, y_axis )

% PLOTSHOCKDATA simplifies plotting this model's results by outputting a 
% plot with some pre-defined parameters
% ========================================================================
% INPUT ARGUMENTS:
%   data                 (matrix)     data to plot
%   labels               (cell array) label for each line 
%   title_               (string)     title of the graph
%   y_axis               (string)     label for the y-axis
% ========================================================================
% OUTPUT:
%   figure1              
% ========================================================================

%% Create figure

fig = figure;
set(fig, 'Visible', 'off');

%% Add Data

% Create axes
axes1 = axes('Position',[0.13 0.11 0.775 0.815]);
hold(axes1,'on');

% Create multiple lines using matrix input to plot
plot1 = plot([0:(size(data,2)-1)], data);

%% Label Plot

% Label each line in the legend
for i = 1:size(labels,2)
    set(plot1(i),'DisplayName',labels{i});
end

% Create xlabel
xlabel('Year (post shock)');

% Create title
title(title_);

% Create ylabel
ylabel(y_axis);

legend('show');
box(axes1,'on');

end

