% ========================================================================
% Generates random supply and demand curves and integrates to find the 
% surpluses; the results are compared to the manual calculation done in 
% calculateShockEffects.m to check for errors
% ========================================================================

close all;
clc;
clear;

%% Params

price = randn()^2 * 5 + 5;
quantity = randn()^2 * 5 + 5;

elas_D = - rand()^2 - 0.1;
elas_S = rand()^2 *8 + 0.1;


%% Coefficients

[ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                          elas_D, elas_S, price, quantity);
alpha_shock = -quantity*(rand()*10);
alpha_s2 = alpha_s + alpha_shock;


%% Create supply and demand curve
                                      
demand  = @(p) alpha_d + beta_d*p;
supply  = @(p) alpha_s + beta_s*p;
supply2 = @(p) alpha_s + alpha_shock + beta_s*p;

eq_p1 = (alpha_s - alpha_d)/ (beta_d - beta_s);
eq_p2 = (alpha_s2 - alpha_d)/ (beta_d - beta_s);


%% Plot curves

figure; hold on;

% price range
price_range = linspace(0, (-alpha_d/beta_d), 10);

% get data
quantity_demand  = demand(price_range);
quantity_supply  = supply(price_range);
quantity_supply2 = supply2(price_range);

% plot data
plot(quantity_demand,  price_range, 'b');
plot(quantity_supply,  price_range, 'r');
plot(quantity_supply2, price_range, 'm');

plot([0 demand(eq_p1)], [eq_p1 eq_p1], 'k--')
plot([0 demand(eq_p2)], [eq_p2 eq_p2], 'k--')

% plot options
legend({'Demand', 'Supply', 'Supply_{shock}'})
axis([0 quantity*2 0 1.1*max(price_range)])
xlabel('Q'); ylabel('P');


%% Results

demand_Q0 = fzero(demand, 0);
supply_Q0 = max(fzero(supply,0), 0);
supply2_Q0 = max(fzero(supply2,0), 0);

surplus_D1 = integral(demand, eq_p1, demand_Q0);
surplus_S1 = integral(supply, supply_Q0, eq_p1);
surplus_D2 = integral(demand, eq_p2, demand_Q0);
surplus_S2 = integral(supply2, supply2_Q0, eq_p2);
surplus_L1 = integral(supply2, eq_p1, eq_p2);
surplus_L2 = integral(demand, eq_p1, eq_p2) - surplus_L1;
surplus_L3 = integral(supply, supply_Q0, eq_p1) - ...
                integral(supply2, supply2_Q0, eq_p1);

[ output ] = calculateShockEffects( price, quantity, alpha_d,  ...
                                     beta_d, alpha_s, beta_s, alpha_shock);
 
                  
% price and quantity
disp('Error^2')
disp(' ')
disp((output - [eq_p2, demand(eq_p2), surplus_L1 surplus_L2 surplus_L3, ...
            surplus_D1, surplus_S1, surplus_D2, surplus_S2]).^2)




                                     
                                     
                                     