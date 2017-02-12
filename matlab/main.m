[~,~,xls_raw] = xlsread('Controls,Elasticities.xlsx');

for i = 2:size(xls_raw,1)
   
    % Check identification code
    id_code = char(xls_raw(i,8));
    individual_codes = convertIDcode( id_code );
    
    country = convertCountryCode(char(individual_codes(1)))
    
    
    
end