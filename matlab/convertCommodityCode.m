function [ commodity_str ] = convertCommodityCode( commodity_code )
%CONVERTCOMMODITYcODE Converts commodity abbreviation to full string
%   Abbreviations for strings found in .../data/2016_elasticites_only.xlsx

switch commodity_code
    
    case 'C'
        commodity_str = 'corn';
    case 'SY'
        commodity_str = 'soybeans';
    case 'S'
        commodity_str = 'sugar';
    case 'SU'
        commodity_str = 'sugar';
    case 'R'
        commodity_str = 'rice';
    case 'SC'
        commodity_str = 'sugarcane';
    case 'RLG'
        commodity_str = 'rice (long-grain)';
    case 'OC'
        commodity_str = 'organic corn';
        
        % finish rest of the commodity codes %
                      
    otherwise
        commodity_str = ['Unknown: ', commodity_code ];
        %error(['Invalid Commodity Code: ' , commodity_code]);

end

end

