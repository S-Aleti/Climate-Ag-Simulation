

%% Find percent shocks of counterfactual model

cf_percent_shocks = zeros(size(filtered_data, 1), 10);

for i = 1:size(filtered_data, 1)
    
    % get country and commodity
    country_id = filtered_data{i,1};
    commodity  = filtered_data{i,3};
    
    % find relevant counterfactual data
    ind1 = find([cf_data{:,1}]==country_id);
    ind2 = find(strcmp(cf_data(:,3), commodity));
    ind  = intersect(ind1, ind2);
    
    % baseline 
    control_quantity = cf_data{ind,4};
    
    % calculate shocks for each year
    for j = 1:10
       
        percent_shock = (cf_data{ind,j+4} - control_quantity) / ...
                            control_quantity;
        cf_percent_shocks(i, j) = percent_shock;
        
    end

end


%% Collect quantity shocks of partial equillibrium model

quantity_percent_shocks = zeros(size(filtered_data, 1), 10);

for i = 1:size(filtered_data, 1)

    for j = 1:10 % for each year
        
        row = (j-1)*size(filtered_data, 1) + i;
        quantity_percent_shocks(i, j) = results_matrix(row, 2);
        
    end
end


%% Calculate rebound effect

rebound_effect = (cf_percent_shocks - quantity_percent_shocks) ...
                    ./ (cf_percent_shocks);


