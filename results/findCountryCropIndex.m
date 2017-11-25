function [ indexes ] = findCountryCropIndex( countrycrops, labels )
% ========================================================================
% ANALYZESHOCKSCROSS creates a linear supply and demand model based on the 
% epq data and then simulates the effects in the cf_data using this model
% ========================================================================
% INPUT ARGUMENTS:
%   counrycrops          (cell array) contains cells of country and crop
%                                     combinations to search for in the 
%                                     labels array
%   labels               (cell array) contains a list of countries and  
%                                     crops each row in the output 
%                                     corresponds to, denoted filtered
%                                     data in the analyze cross shocks fn
% ========================================================================
% OUTPUT:
%   indexes              (matrix)     list of indicies corresponding to 
%                                     the countries and their crops
% ========================================================================


%% Pre-alloc

% if not found, index will be -1
indexes = zeros(1, length(countrycrops)) - 1;


%% Search labels

for i = 1:length(countrycrops)
    
    country = countrycrops{i}{1};
    crop    = countrycrops{i}{2};
    
    ind1 = find(strcmp(labels(:,2), country));
    ind2 = find(strcmp(labels(:,3), crop));
    ind  = intersect(ind1, ind2);

    if ~isempty(ind)
        indexes(i) = ind;
    end
    
end


%% Check results for missing indicies

error_msg = [];

if any(indexes == -1)
    
    error_msg = [error_msg, '    Error finding indexes: '];
    
    for i = [find(indexes == -1)]
    error_msg = [error_msg, ['\n        Index for ', countrycrops{i}{1} ...
        ,'-' , countrycrops{i}{2}, ' not found']];
    end
 
end

if ~isempty(error_msg)
    error(sprintf(error_msg));
end

end
