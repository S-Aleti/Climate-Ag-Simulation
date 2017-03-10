function [ output ] = calculateShock( price, quantity, alpha_d, beta_d, ...
                                            alpha_s, beta_s, supply_shock)

% CALCULATESHOCK finds the change in consumer and producer surplus given a
% shock to a linear demand and supply schedule
% ========================================================================
% INPUT ARGUMENTS:
%   price                (scalar) current price ($/tonne)
%   quantity             (scalar) control (tonne)
%   alpha_d              (scalar) intercept of demand curve
%   beta_d               (scalar) slope of demand curve
%   alpha_s              (scalar) intercept of supply curve
%   beta_s               (scalar) slope of supply curve
%   supply_shock         (scalar) shift in supply curve
% ========================================================================

%% Calculate Original Surpluses

% Consumer surplus
surplus_C1 = (1/2)*(quantity)*(alpha_d-price);

% Producer surplus
surplus_S1 = (1/2)*(quantity)*(price-alpha_s);

%% Introduce Supply Shock

% New supply schedule: Q = (alpha_s + supply_shock) + beta_s*P

new_price =  ((alpha_s + supply_shock) - (alpha_d)) / (beta_d - beta_s);
new_quantity = alpha_d + beta_d*new_price;

%% Calculate New Surpluses

% New Consumer surplus
surplus_C2 = (1/2)*(new_quantity)*(alpha_d-new_price);

% New Producer surplus
surplus_S2 = (1/2)*(new_quantity)*(new_price-(alpha_2 + supply_shock));




end



