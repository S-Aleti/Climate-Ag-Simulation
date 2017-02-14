function [ output ] = findElasticity( data, country, ...
                                            commodity, type )
% FINDELASTICITY Searches cell array for the elasticity of a 
% commodity at a given location
% ========================================================================
% INPUT ARGUMENTS:
%   data                 (cell array) generated with main.m
%   country              (string) country name, set to 'all' for all
%   commodity            (string) commodity name, set to 'all' for all
%   type                 (string) elasticity type from the following:
%                           demand_I, demand_O, supply
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

%% Filter by elasticity

found  = 0;
output = {};

if isequal(type,'all')
    
    output = data_commodity;
    
else % if we're looking for a specific elasticity type

    for i = 1:size(data_commodity,1)
        % check type of elasticity we're looking for
        if isequal(data_commodity(i,4), {type})
            % add data to output cell arry
            output = [output; data_commodity(i,:)];
        end
    end
    
end

end
