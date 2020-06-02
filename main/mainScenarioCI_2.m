% ========================================================================
% This script generates results for the B_C_US shocks along with 
% providing outcomes under alternate scenarios
% ========================================================================

%% Collect Data

% % Collect data once to avoid having to recollect latter
% [ elas_data, pq_data, epq_data, cf_data ] = collectData( 'recollect', ...
%     'crop_data/xlsx_data/' );
% 
% % Set elasticity to same as CGE model
% epq_data(:,7) = {-0.808};
% 
% % Save data
% save('crop_data/processed_data/model_param_data.mat', ...
%     'elas_data', 'pq_data', 'epq_data', 'cf_data')

%% Params

% scenario data
scenarios_xlsx_file = '/crop_data/xlsx_data/B_C_US_shocks_c_s.xlsx';

% Percent change in supply and demand under each alternative scenario
demand_shift = 0.2;
supply_shift = 0.2;


% Results file name header
results_file_name = 'results/csv/results_BCUS_pe';


%% Get results for each scenario

for s = 1:7
    %% Load and prepare elasticity data
    load('crop_data/processed_data/model_param_data.mat');
    
    % Cross price elasticities (all zero for PE)
    elas_S_corn_soybean = 0; 
    elas_S_soybean_corn = 0; 
    elas_D_corn_soybean = 0; 
    elas_D_soybean_corn = 0;
    
    if s == 2
        % lower bound on demand elasticities
        epq_data(:,7) = num2cell(cell2mat(epq_data(:,7))*(1-demand_shift));
        results_file = [results_file_name  '_ld.csv'];
    elseif s == 3
        % upper bound on demand elasticities
        epq_data(:,7) = num2cell(cell2mat(epq_data(:,7))*(1+demand_shift));
        results_file = [results_file_name  '_ud.csv'];
    elseif s == 4
        % lower bound on supply elasticities
        epq_data(:,11) = num2cell(cell2mat(epq_data(:,11))*...
            (1-supply_shift));
        results_file = [results_file_name  '_ls.csv'];
    elseif s == 5
        % upper bound on supply elasticities
        epq_data(:,11) = num2cell(cell2mat(epq_data(:,11))*...
            (1+supply_shift));
        results_file = [results_file_name  '_us.csv'];
    elseif s == 6
        % with cross demand elasticities
        elas_D_corn_soybean = 0.808; 
        elas_D_soybean_corn = 0.808;
        results_file = [results_file_name  '_cd.csv'];
    elseif s == 7
        % with cross supply elasticities
        elas_S_corn_soybean = -0.076; 
        elas_S_soybean_corn = -0.13; 
        results_file = [results_file_name  '_cs.csv'];
    else
        % normal case
        results_file = [results_file_name  '_baseline.csv'];
    end
    

    %% Update counterfactual data with scenarios

    % cf_data uses initial outputs from
    % crop_data/xlsx_data/Counterfactual_data.xlsx by default
    % the cf_data variable is updated here to reflect the percent shocks in 
    % the scenarios_xlsx_file 

    crops = {'Corn', 'Soybean'};

    % used when replacing the cf data
    % n = length(cf_data(1,:));

    for scn_crop = crops

        % replace with shocks from scenarios_xlsx_file
        [~, ~, scenario_xls_raw]  = xlsread(scenarios_xlsx_file, ...
            scn_crop{:});

        % number of scenario years
        num_years = size(scenario_xls_raw(1,:),2)-2;

        % for each country in cf_data
        for i = 1:size(cf_data, 1)

            % counterfactual row's country
            cf_country = cf_data{i, 2};

            % cf row's crop
            cf_crop = cf_data{i, 3};

            % search country in scenario data
            for j = 2:size(scenario_xls_raw, 1)

                scn_country = scenario_xls_raw{j, 1};

                if (strcmp(cf_country, scn_country) && ...
                        strcmpi(cf_crop, scn_crop))

                    %fprintf('%s: %s\n', cf_country, cf_crop);

                    % given a country-crop match, update the cf_data
                    q_initial = cf_data{i, 4};

                    % percent shocks from scenarios
                    pct_shocks = cell2mat(scenario_xls_raw(j,3:(3+num_years-1)));

                    % new quantites implied by scenarios
                    q_scenarios = (1 + pct_shocks) * q_initial;

                    % update cf_data
                    for k = 1:length(q_scenarios)
                        cf_data{i, 4 + k} = q_scenarios(k);
                    end

                    break;

                end

            end

        end

    end

    % Drop rows without scenario data 
    ind = ~cellfun(@isempty, cf_data(:,size(cf_data,2)));
    cf_data = cf_data(ind, :);

    % % Drop rows not in country list
    % f = @(x) any(strcmp({'Brazil', 'China', 'United States'}, x))
    % ind = cellfun(f, cf_data(:,2));
    % cf_data = cf_data(ind,:);

    
    %% Get results

    [ results_mat, formatted_results, ~ ]  = analyzeShocksCross(       ...
        epq_data, cf_data, 1, elas_S_corn_soybean, elas_S_soybean_corn,...
        elas_D_corn_soybean, elas_D_soybean_corn);
    
    
    %% Export results to csv

    results_table = cell2table(formatted_results);


    var_names = {'Year', 'Country', 'Crop', 'Percent_Price_Change',    ...
        'Percent_Quantity_Change', 'Welfare_Transfer_to_Producer',     ...
        'Welfare_lost_by_Consumer', 'Welfare_lost_by_Producer',        ...
        'Change_in_Producer_Surplus',                                  ...
        'Change_in_Consumer_Surplus',                                  ...
        'Percent_Change_in_Producer_Surplus',                          ...
        'Percent_Change_in_Consumer_Surplus',                          ...
        'Producer_Surplus_Original',                                   ...
        'Consumer_Surplus_Original', 'Quantity_Original'};

    results_table.Properties.VariableNames = var_names;

    try 
        writetable(results_table, results_file);
        fprintf('Results saved to %s\n', results_file);
    catch
        % Make sure current directory is /Climate-Ag-Simulation/
        fprintf('Error saving results\n');
    end

    
end









