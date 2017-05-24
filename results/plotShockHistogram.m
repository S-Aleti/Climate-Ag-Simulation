function [ fig ] = plotShockHistogram(data, plot_title, x_label,       ...
                    y_label, legend_labels, bins, outlier_threshold,   ...
                    stdev_threshold)

% PLOTCROPSHOCKDATA simplifies plotting this model's results by outputting 
% a plot with some pre-defined parameters
% ========================================================================
% INPUT ARGUMENTS:
%   data                 (matrix)     plots first row and values for each  
%                                     of the columns as a historgram
%   plot_title_          (string)     title of the graph
%   x_label              (string)     label for the x-axis
%   y_label              (string)     label for the y-axis
%   legend_labels        (cell array) contains string labels for each col
%                                     of the data being plotted
%   bins                 (int)        number of bins for the histogram
%   outlier_threshold    (vector)     1x2, excludes samples outside these
%                                     given bounds
%   stdev_threshold      (scalar)     excludes outliers outside this many
%                                     standard deviations
% ========================================================================
% OUTPUT:
%   fig                  (figure)         
% ========================================================================

%% Create figure

fig = figure;
hold on;

for i = 1:size(data,2)
    %% Remove outliers
    
    plot_data = data(1, i, :);
    
    plot_data(abs(plot_data - mean(plot_data)) > stdev_threshold * ...
                    std(plot_data)) = [];
    
    plot_data(plot_data < outlier_threshold(1)) = outlier_threshold(1);
    plot_data(plot_data > outlier_threshold(2)) = outlier_threshold(2); 
    
    %% Add histogram
    
    h(i) = histogram(reshape(plot_data, 1, size(plot_data,3)), bins, ...
        'Normalization', 'probability');
    
    h(i).BinWidth = h(1).BinWidth;
    
    set(h(i), 'DisplayName', legend_labels{i});
    
end

hold off;

%% Format figure

lgd = legend('show');

grid on;

xlabel(x_label);

ylabel(y_label);

title(plot_title);


end

