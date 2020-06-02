function [ elas_data, pq_data, epq_data, cf_data ] = collectData( arg, ...
    data_folder)
% ========================================================================
% COLLECTDATA can either recollect the data from the excel files or load
% previously collected data from the 'data' folder
% ========================================================================
% INPUT ARGUMENTS:
%   arg                  (string) either 'load' or 'recollect'
%   data_folder          (string) folder containing the xlsx files
% ========================================================================
% OUTPUT:
%   elas_data            (cell array) contains elasticity data
%   pq_data              (cell array) contains price & quantity data
%   epq_data             (cell array) merge of elas_data and pq_data
%   cf_data              (cell array) contains counterfactual data
% ========================================================================

if (isequal(arg, 'load'))
    %% Get previously collected data from data folder
    
    load('elas_data');
    load('pq_data'  );
    load('epq_data' );
    load('cf_data'  );
    return;
    
elseif (isequal(arg,'recollect'))
    %% Get elasticity data from the following file:

    disp('Collecting elasticity data...')

    file_name = [data_folder '/Elasticity_Data.xlsx'];
    elas_data = collectElasticityData(file_name, 1, 2, 3, 4, 6, 7);


    %% Get price and quantity data from the following file:

    disp('Collecting price and quantity data...')

    file_name   = [data_folder '/FAO_Production_Data.xlsx'];
    pq_data = collectPriceQuantityData(file_name, 1,  1, 2, 11, 4, 15, 13);


    %% Combine elasticity data with price and quantity data

    disp('Merging data...')

    epq_data = collectEPQData(pq_data, elas_data);


    %% Collect counterfactual data

    disp('Collecting counterfactual data...')

    file_name   = [data_folder '/Counterfactual_Data.xlsx'];
    cf_data = {};

    % each sheet contains cf data for a specific commodity
    for i = 1:5
        cf_data = [cf_data; collectCounterfactualData(file_name, ... 
                                                          2, 1, 3, i)];
    end
    
else
    
    error('Invalid argument: use either "load" or "recollect"');
    
end