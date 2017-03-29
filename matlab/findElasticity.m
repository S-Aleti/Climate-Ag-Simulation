function [ filtered_data ] = findElasticity( data, id_code, ...
                                            commodity, type )

% FINDELASTICITY Searches cell array for the elasticity of a 
% commodity at a given location
% ========================================================================
% INPUT ARGUMENTS:
%   data                 (cell array) from collectElasticityData.m
%   id_code              (int) country identification code
%   commodity            (string) commodity name, use 'all' for all
%   type                 (string) elasticity type from the following:
%                           demand_I, demand_O, ,demand_C, demand_E, 
%                           supply; use 'all' for all
% ========================================================================
% OUTPUT:
%   filtered_data        (cell array) elasticity data filtered by the 
%                           country, commodity, and/or elasticity type in
%                           the same format as the data variable
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

        %check commodity code 
        if isequal(data_country(i,3),{commodity})
            data_commodity = [data_commodity; (data_country(i,:))];
        end

    end
    
end

%% Filter by elasticity

filtered_data = {};

if isequal(type,'all')
    
    filtered_data = data_commodity;
    
else % if we're looking for a specific elasticity type

    for i = 1:size(data_commodity,1)
        
        % check type of elasticity we're looking for
        if isequal(data_commodity(i,5), {type})
            
            % add data to output cell arry
            filtered_data = [filtered_data; data_commodity(i,:)];
            
        end
        
    end
    
end

end
