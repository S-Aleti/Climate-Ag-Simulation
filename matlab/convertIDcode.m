function [ output ] = convertIDcode( id_code )
%CONVERTIDCODE Converts codes from column H of the xlsx to individual identifiers

delim_inds = findstr(id_code,'_'); % EG: f(US_R_R_O) => [3,5,7]
disp(id_code)

country =   id_code(1:(delim_inds(1)-1));
commodity = id_code(delim_inds(1)+1:delim_inds(2)-1);
if length(delim_inds) == 4
    cross =     id_code(delim_inds(2)+1:delim_inds(3)-1);
    e_type =    id_code(delim_inds(3)+1:length(id_code));
else
    cross = 'NA';
    e_type =id_code(delim_inds(2)+1:length(id_code));

output = { country, commodity, cross, e_type };


end

