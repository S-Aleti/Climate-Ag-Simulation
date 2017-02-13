function [ output ] = convertIDcode( id_code )
%CONVERTIDCODE Converts codes from column H of the xlsx to individual identifiers

% break code into parts with the delimiter: '_'
delim_inds = findstr(id_code,'_'); % EG: f(US_R_R_O) => [3,5,7]

% determine whether id code is for supply or demand elasticity
if ~(all(id_code(1:2) == 'S_')) % code doesn't start with 'S_'
    %% Demand
    
    % First abbreviation is country code
    country =   convertCountryCode(id_code(1:(delim_inds(1)-1)));
    
    % Second abbreviation is commodity code
    commodity = convertCommodityCode(id_code...
        (delim_inds(1)+1:delim_inds(2)-1));
    
    % Next one or two is dependent on the elasticity type
    if length(delim_inds) == 3

        cross =     convertCommodityCode(id_code(...
                         delim_inds(2)+1:delim_inds(3)-1));
        e_type =    id_code(delim_inds(3)+1:length(id_code));

    else % if cross commodity is itself

        cross = 'NA';
        e_type = ['demand_' , id_code(delim_inds(2)+1:length(id_code))];
        
    end
    
else 
    %% Supply
    
    country = convertCountryCode(id_code(3:(delim_inds(2)-1)));
    commodity = convertCommodityCode(...
        id_code(delim_inds(2)+1:length(id_code)));
    cross = 'NA';
    e_type = 'supply';
    
end

% cell array
output = { country, commodity, cross, e_type };

end

