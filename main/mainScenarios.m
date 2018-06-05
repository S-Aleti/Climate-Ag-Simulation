% ========================================================================
% This script analyzes the 31 counterfactual shocks 
% ========================================================================

%% Params

% scenario data
scenarios_xlsx_file = '/crop_data/xlsx_data/crop-GTAP-003-yr4.xlsx';

% results file loc
results_file = 'results/csv/results_yr4_mm.csv';

% elasticities
elas_S_corn_soybean = 0%-0.076;
elas_S_soybean_corn = 0%-0.13;
elas_D_corn_soybean = 0%0.123;
elas_D_soybean_corn = 0%0.15;


%% Collect Data

% change arg to 'recollect' to recollect the data, or just use 'load' to
% use the previously collected data (faster)
[ elas_data, pq_data, epq_data, cf_data ] = collectData( 'load' );


%% Update counterfactual data with scenarios

% cf_data uses initial outputs from
% crop_data/xlsx_data/Counterfactual_data.xlsx by default
% the cf_data variable is updated here to reflect the percent shocks in 
% the scenarios_xlsx_file 

crops = {'Corn', 'Soybean', 'Rice'};

% used when replacing the cf data
% n = length(cf_data(1,:));

for scn_crop = crops

    % replace with shocks from scenarios_xlsx_file
    [~, ~, scenario_xls_raw]  = xlsread(scenarios_xlsx_file, 'Soybean');

    % for each country in cf_data
    for i = 1:size(cf_data, 1)

        % counterfactual row's country
        cf_country = cf_data{i, 2};

        % cf row's crop
        cf_crop = cf_data{i, 3};

        % search country in scenario data
        for j = 4:size(scenario_xls_raw, 1)

            scn_country = scenario_xls_raw{j, 1};

            if (strcmp(cf_country, scn_country) && ...
                    strcmpi(cf_crop, scn_crop))

                %fprintf('%s: %s\n', cf_country, cf_crop);
                
                % given a country-crop match, update the cf_data
                q_initial = cf_data{i, 4};
                
                % percent shocks from scenarios
                pct_shocks = cell2mat(scenario_xls_raw(j,3:33));
                
                % new quantites implied by scenarios
                q_scenarios = (1 + pct_shocks/100) * q_initial;
                
                % update cf_data
                for k = 1:length(q_scenarios)
                    cf_data{i, 4 + k} = q_scenarios(k);
                end
                
                break;

            end

        end

    end
    
end


%% Get results

[ results_mat, formatted_results, ~ ]  = analyzeShocksCross(epq_data,  ...
    cf_data, 1, elas_S_corn_soybean,                                   ...
    elas_S_soybean_corn, elas_D_corn_soybean, elas_D_soybean_corn);


%% Export results to csv

results_table = cell2table(formatted_results);


var_names = {'Scenario', 'Country', 'Crop', 'Percent_Price_Change',     ...
    'Percent_Quantity_Change', 'Welfare_Transfer_to_Producer',          ...
    'Welfare_lost_by_Consumer', 'Welfare_lost_by_Producer',             ...
    'Percent_Change_in_Producer_Surplus',                               ...
    'Percent_Change_in_Consumer_Surplus'};

results_table.Properties.VariableNames = var_names;

try 
    writetable(results_table, results_file);
    fprintf('Results saved to %s\n', results_file);
end











