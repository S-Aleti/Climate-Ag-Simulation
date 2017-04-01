function [ filtered_data ] = findEPQ(data, id_code, commodity, year)

% FINDELASTICITY Searches cell array for the elasticity of a 
% commodity at a given location
% ========================================================================
% INPUT ARGUMENTS:
%   data                 (cell array) from collectAllData.m
%   id_code              (int)        country identification code
%   commodity            (string)     commodity name, use 'all' for all
%   year                 (int/string) year of data, 'latest' for latest
% ========================================================================
% OUTPUT:
%   filtered_data        (cell array) elasticity, price, and quantity data
%                                     filtered by country and commodity
% ========================================================================

%% Filter by country

if isequal(id_code,'all') 

    data_country = data;
    
else % looking for a specific country
    
    % empty cell array to store data for the country
    data_country = {};

    for i = 1:size(data,1)

        %check country code 
        if isequal(data(i,1),{id_code})
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

        % check commodity code 
        if isequal(data_country(i,3),{commodity})
            data_commodity = [data_commodity; (data_country(i,:))];
        end

    end
    
end

if isempty(data_commodity)
    filtered_data = data_commodity;
    return;
end

%% Filter by Year

if isequal(year,'latest')
    year = max(cell2mat(data_commodity(:,4))); % get latest year
end
    
% empty cell array to store data for the year
data_year = {};

for i = 1:size(data_commodity,1)

    % check year 
    if isequal(data_commodity(i,4),{year})
        data_year = [data_year; (data_commodity(i,:))];
    end

end

%% Output

filtered_data = data_year;

end

