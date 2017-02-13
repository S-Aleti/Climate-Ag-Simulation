function [ country_str ] = convertCountryCode( country_code )
%CONVERTCOUNTRYCODE Converts country abbreviation to full string
%   Abbreviations for strings found in .../data/2016_elasticites_only.xlsx

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
    case 'CH'
        country_str = 'China';
    case 'IC'
        country_str = 'Ivory Coast';
    case 'N'
        country_str = 'Nigeria';
    case 'I'
        country_str = 'Iran';
    case 'SA'
        country_str = 'Saudi Arabia';
    case 'BG'
        country_str = 'Bangladesh';
    case 'IN'
        country_str = 'Indonesia';
    case 'ID'
        country_str = 'India';
    case 'IR'
        country_str = 'Iran';
    case 'IS'
        country_str = 'Israel';
    case 'IQ'
        country_str = 'Iraq';
    case 'JP'
        country_str = 'Japan';
    case 'PK'
        country_str = 'Pakistan';
    case 'ML'
        country_str = 'Malaysia';
    case 'MY'
        country_str = 'Myanmar';
    case 'PP'
        country_str = 'Philippines';
    case 'SK'
        country_str = 'South Korea';
    case 'RU'
        country_str = 'Russia';
    case 'TW'
        country_str = 'Taiwan';
    case 'TH'
        country_str = 'Thailand';
    case 'TU'
        country_str = 'Turkey';
    case 'VN'
        country_str = 'Vietnam';
                      
    otherwise
        error(['Invalid Country Code: ' , country_code]);

end

end

