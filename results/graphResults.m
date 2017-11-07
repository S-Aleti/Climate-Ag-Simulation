% ========================================================================
%
% Graphs the results of analyzeShocks.m
%
% ========================================================================

close all

%% Generate Graphs

crops = {'corn', 'soybean'};

for i = 1:length(crops)
    
    crop = crops{i};

    % input args
    countries      = {'United States', 'China', 'Brazil', 'India'};

    for data_type = 1:7  

        % plot
        fig = plotCropShockData( data, countries, crop, data_type);

        % shows figure              
        figure(fig); 
        
        % converts y labels to percentages
        if any(data_type==[1,2,6,7])
            
            L = get(gca, 'yticklabels');
            yticks = num2str(cellfun(@str2num, L)*100) + "%";
            set(gca, 'yticklabels', yticks);
            
        end

        % Save Results
        %saveas(fig, 'results\graphs\corn_prices.fig');
        filepath = ['results\graphs\' crop '_' num2str(data_type) '.png'];
        saveas(fig, filepath);

    end

end



