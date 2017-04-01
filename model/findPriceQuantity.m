function [ filtered_data ] = findPriceQuantity( data, country, ...
                                                    commodity, year)
                                                
% FINDELASTICITY Searches cell array for the elasticity of a 
% commodity at a given location
% ========================================================================
% INPUT ARGUMENTS:
%   data                 (cell array) from collectSupplyDemandData.m
%   country              (string) country name, use 'all' for all
%   commodity            (string) commodity name, use 'all' for all
%   year                 (int) year of data, use 'all' for all
% ========================================================================
% OUTPUT:
%   filtered_data        (cell array) elasticity data filtered by the 
%                           country, commodity, and/or year in the same 
%                           format as the data variable
% ========================================================================

%% Filter by country

if isequal(country,'all') 

    data_country = data;
    
else % looking for a specific country
    
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
        if isequal(data_country(i,2),{commodity})
            data_commodity = [data_commodity; (data_country(i,:))];
        end

    end
    
end

%% Filter by year

filtered_data = {};

if isequal(year,'all')
    
    filtered_data = data_commodity;
    
else % if we're looking for data from a certain year

    for i = 1:size(data_commodity,1)
        
        % check year we're looking for
        if isequal(data_commodity(i,3), {year})
            
            % add data to output cell arry
            filtered_data = [filtered_data; data_commodity(i,:)];
            
        end
        
    end
    
end



end

