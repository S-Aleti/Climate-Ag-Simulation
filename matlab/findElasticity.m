function [ output ] = findElasticity( data, country, ...
                                            commodity, type )
% FINDELASTICITY Searches cell array for the elasticity of a 
% commodity at a given location
% ========================================================================
% INPUT ARGUMENTS:
%   data                 (cell array) generated with main.m
%   country              (string) country name
%   commodity            (string) commodity name
%   type                 (string) elasticity type from the following:
%                           demand_I, demand_O, supply
% ========================================================================

%% Filter by country

% empty cell array to store data for the country
data_country = {};

for i = 1:size(data,1)
    
    %check country code 
    if isequal(data(i,1),{country})
        data_country = [data_country; data(i,:)];
    end
    
end

% check if country is not found
if  ~length(data_country) > 0
    error(['Country ' , country, ' not found']);
end

%% Filter by commodity

% empty cell array to store data for the commodity
data_commodity = {};

for i = 1:size(data_country,1)
    
    %check commodity code 
    if isequal(data_country(i,2),{commodity})
        data_commodity = [data_commodity; (data_country(i,:))];
    end
    
end

% check if commodity is not found
if ~length(data_commodity) > 0
    error(['Commodity ' , commodity, ' not found']);
end 

%% Filter by elasticity

found = 0;

for i = 1:size(data_commodity,1)
    % check type of elasticity we're looking for
    if isequal(data_commodity(i,4), {type})
        found = 1;
        output = cell2mat(data_commodity(i,5));
    end
end

if ~found
    error('Not found');
end

end
