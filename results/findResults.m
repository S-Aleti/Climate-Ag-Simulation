function [ filtered_data ] = findResults( data, country, commodity, type)
                                                
% FIND RESULTS Searches cell array for results of the given type pertaining
% to country and commodity commodity 
% ========================================================================
% INPUT ARGUMENTS:
%   data                 (cell array) from model/analyzeShocks.m
%   country              (string/int) country name or code, accepts 'all'
%   commodity            (string)     commodity name, accepts 'all'
%   type                 (int)        1 for % price change,
%                                     2 for % quantity change, 
%                                     3 for surplus_L1, 
%                                     4 for surplus_L2, 
%                                     5 for surplus_L3
% ========================================================================
% OUTPUT:
%   filtered_data        (cell array) data filtered by the 
%                           country and commodity and by a certain type
% ========================================================================

%% Filter by country

if isequal(country,'all') 

    data_country = data;
    
elseif ischar(country) % given country name
    
    % empty cell array to store data for the country
    data_country = {};

    for i = 1:size(data,1)

        %check country code 
        if isequal(data(i,2),{country})
            data_country = [data_country; data(i,:)];
        end

    end
   
else % given country ID
    
        % empty cell array to store data for the country
    data_country = {};

    for i = 1:size(data,1)

        %check country code 
        if isequal(data(i,1),{country})
            data_country = [data_country; data(i,:)];
        end

    end
    
end

%% Filter by commodity

if isequal(commodity,'all')
    
    data_commodity = data_country;
    
else % looking for a specific commodity

    % empty cell array to store data for the commodity
    data_commodity = {};

    for i = 1:size(data_country,1)

        %check commodity code 
        if isequal(data_country(i,3),{commodity})
            data_commodity = [data_commodity; (data_country(i,:))];
        end

    end
    
end

%% Filter data type

% sizes
entries = size(data_commodity, 1);
columns = size(data_commodity, 2);

% set up empty arrays
filtered_data = cell(entries, columns);

% enter each entry
for i = 1:entries
    
    % fill in country_id, country, and commodity
    filtered_data(i,1) = data_commodity(i,1);
    filtered_data(i,2) = data_commodity(i,2);
    filtered_data(i,3) = data_commodity(i,3);
    
    % fill in specified result for each year
    for j = 4:columns
        
        result = data_commodity{i,j}(type);
        filtered_data(i,j) = mat2cell(result,1,1);

    end
    
end

