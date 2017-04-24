function [ output ] = calculateShockCrossEffects( price, quantity, ...
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
             .* (price - max(0, -alpha_s ./ diag(beta_s)))

%% Introduce Supply Shock
% New supply schedule: Q = (alpha_s + supply_shock) + beta_s*P

% new intercept 
alpha_s2 = alpha_s + alpha_shock;

% solve system Dx = Y
D = beta_d - beta_s;
Y = alpha_s2 - alpha_d;
new_price = linsolve(D,Y)
new_quantity = alpha_s2 + beta_s*new_price;

%% Calculate New Surpluses

% New Consumer surplus
surplus_C2 = (1/2)*(new_quantity).*((-alpha_d ./ diag(beta_d)) - new_price);

% New Producer surplus
surplus_S2 = (1/2)*(max(0, alpha_s2) + new_quantity)...
             .* (new_price - max(0, -(alpha_s2) ./ diag(beta_s)));

%% Calculate Change in Surpluses

% quantity if price doesn't adjust
pe_quantity = alpha_s2 + diag(beta_s).*price;

% lost consumer surplus captured by producer
surplus_L1 = (new_price - price) .* (pe_quantity + new_quantity) / 2;

% lost consumer surplus not captured by producer
surplus_L2 = (quantity - pe_quantity) .* (new_price - price) / 2;

% lost producer surplus
surplus_L3 = (quantity .* (price - (alpha_s./( -diag(beta_s) ))) / 2) ...
           - (pe_quantity .* (price - (alpha_s2./( -diag(beta_s )))) / 2);

for i = 1:length(price)
    
    if new_price(i) < 0
        new_quantity(i) = 0;
        surplus_L1(i)   = 0;
        surplus_L2(i)   = 0;
        surplus_L3(i)   = 0;
        surplus_C2(i)   = 0;
        surplus_S2(i)   = 0;
    end

end

output = [new_price, new_quantity, surplus_L1, surplus_L2, surplus_L3, ...
          surplus_C1, surplus_S1, surplus_C2, surplus_S2];
      
end
