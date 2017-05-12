
close all

%% Gas and Electricity Data

price = [1432.92,90.48]';
quantity = [76579*42*3.78,490399*1000000]';
elas_D = [-0.3,0;0,-0.1]  + [0,0.2;0.2,0]; % NOTE THE ADDED CROSS ELASTICITIES!
elas_S = diag([0.15,1/4]) %+ [0,-0.01;-0.01,0];

% define your own percent changes here
percent_change = [-0.10] + 1;

% iterations for the simulation
iterations = 15;


%% Determine percent shock values 

[ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                         elas_D, elas_S, price, quantity);

% calculate 
alpha_shocks = quantity * percent_change - ...
                repmat(beta_s*price + alpha_s, 1, size(percent_change,2));
      
            
%% For each supply shock, find the equillibrium

% plots the supply and demand graphs
plot_results = true;

for shock_num = 1:size(percent_change,2)
    
    % specific supply shock
    alpha_shock = alpha_shocks(:,shock_num);
    alpha_s2 = alpha_s + alpha_shock;
    
    % results of each shock
    [ price_t, quantity_t, price_shock, quantity_shock, price_eql,      ...
        quantity_eql ] = simulateShock(price, quantity, elas_D, elas_S, ...
                        alpha_shock, iterations, plot_results);
    
end

 
        
        
        
        
        