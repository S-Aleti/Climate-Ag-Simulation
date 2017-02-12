function [ country_str ] = convertCountryCode( country_code )
%CONVERTCOUNTRYCODE Converts country abbreviation to full string
%   Abbreviations for strings found in .../code/Elasticities2.xlsx

switch country_code
    case 'US'
        country_str = 'United States';
    case 'CA'
        country_str = 'Canada';
    case 'ME'
        country_str = 'Mexico';
    case 'BR'
        country_str = 'Brazil';
    case 'AR'
        country_str = 'Argentina';
    case 'P'
        country_str = 'Peru';
    case 'U'
        country_str = 'Uraguay';
    case 'V'
        country_str = 'Venenzuela';
    case 'AL'
        country_str = 'Algeria';
    case 'E'
        country_str = 'Egypt';
    case 'C'
        country_str = 'China';
        
    %%%% FINISH THE REST OF THESE %%%%    
        
    otherwise
        error('Invalid Country Code');
end

end

