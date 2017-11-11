function [ output ] = calculateShockEffects( price, quantity, alpha_d,  ...
                                     beta_d, alpha_s, beta_s, alpha_shock)

% CALCULATESHOCKEFFECTS finds the change in consumer and producer surplus 
% given a shock to a linear demand and supply schedule
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
% OUTPUT:
%   output               (matrix) new_price, new_quantity, surplus_L1, 
%                                 surplus_L2, surplus_L3, surplus_C1,
%                                 surplus_S1, surplus_C2, surplus_S2

%% Calculate Original Surpluses

% Consumer surplus
surplus_C1 = (1/2) * (quantity) * ( (-alpha_d/beta_d) - price);

% Producer surplus
surplus_S1 = (1/2) * (max(0, alpha_s) + quantity)...
             *(price - max(0, -alpha_s / beta_s));

         
%% Introduce Supply Shock
% New supply schedule: Q = (alpha_s + supply_shock) + beta_s*P

% new intercept 
alpha_s2 = alpha_s + alpha_shock;

new_price    =  (alpha_s2 - alpha_d) / (beta_d - beta_s);
new_quantity = alpha_d + beta_d * new_price;

% if supply shock prevents any production
if new_price < 0
    
    output = zeros(1,9);
	% include original surpluses
	output(6) = surplus_C1;
	output(7) = surplus_S1;
	% welfare loss is all of present surplus
	output(4) = surplus_C1 + surplus_S1;
    return 
    
end


%% Calculate New Surpluses

% New Consumer surplus
surplus_C2 = (1/2)*(new_quantity)*( (-alpha_d / beta_d) - new_price );

% New Producer surplus
surplus_S2 = (1/2)*(max(0, alpha_s2) + new_quantity)...
             * (new_price - max(0, -(alpha_s2) / beta_s));

         
%% Calculate Change in Surpluses

% quantity if price doesn't adjust
pe_quantity = alpha_s2 + beta_s*price;

% lost consumer surplus captured by producer
surplus_L1 = (new_price - price) * (pe_quantity + new_quantity) / 2;

% lost consumer surplus not captured by producer 
surplus_L2 = (quantity - pe_quantity) * (new_price - price) / 2;

% lost producer surplus 
surplus_L3 = surplus_S1 - ( (1/2)*(price - max((-alpha_s2/beta_s), ...
                            0)) * ((alpha_s2 + beta_s*price) +    ...
                            (max(0, alpha_s2))));
              


%% Output

output = [new_price, new_quantity, surplus_L1, surplus_L2, surplus_L3, ...
          surplus_C1, surplus_S1, surplus_C2, surplus_S2];

end



