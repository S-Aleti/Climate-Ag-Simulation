function [ output_args ] = calculateShockCrossEffects( price, quantity, ...
                             alpha_d, beta_d, alpha_s, beta_s, alpha_shock)

% CALCULATESHOCKCROSSEFFECTS finds the change in consumer and producer
% surplus given a shock to a supply and demand schedule with non-zero cross 
% price elasticities
% ========================================================================
% INPUT ARGUMENTS:
%   price                (vector) current price ($/tonne)
%   quantity             (vector) control (tonne)
%   alpha_d              (vector) intercept of demand curve
%   beta_d               (matrix) slope of demand curve
%   alpha_s              (vector) intercept of supply curve
%   beta_s               (vector) coefficients of supply curve
%   supply_shock         (vector) shift in supply curve
% ========================================================================
% OUTPUT:
%   output               (matrix) new_price, new_quantity, surplus_L1, 
%                                 surplus_L2, surplus_L3, surplus_C1,
%                                 surplus_S1, surplus_C2, surplus_S2

%% Calculate Original Surpluses

% Consumer surplus
surplus_C1 = (1/2) * (quantity) .* ( (-alpha_d./diag(beta_d)) - price)

% Producer surplus
surplus_S1 = (1/2) * (max(0, alpha_s) + quantity)...
             .* (price - max(0, -alpha_s ./ beta_s))

%% Introduce Supply Shock
% New supply schedule: Q = (alpha_s + supply_shock) + beta_s*P

% new intercept 
alpha_s2 = alpha_s + alpha_shock;

% solve system Dx = Y
D = beta_d - diag(beta_s);
Y = alpha_d - alpha_s2;
new_price = linsolve(D,Y');
         
end

