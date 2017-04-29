function [ price_t, quantity_t, price_shock, quantity_shock, price_eql, ...
    quantity_eql ] = simulateShock(price, quantity, elas_D, elas_S,     ...
    alpha_shock, iterations)

% SIMULATESHOCK determines the change in price and quantity over time given
% a shock to a system
% ========================================================================
% INPUT ARGUMENTS:
%   price                (vector) current price ($/tonnes)
%   quantity             (vector) current quantity (tonnes)
%   elas_D               (matrix) diagonal entries are elasticity of demand
%                                 and non-diagonal entries are cross elas
%   elas_S               (matrix) same as elas_D but for supply
%   alpha_shock          (scalar) shift in supply curve
%   iterations           (scalar) iterations of the supply and
%                                 demand simulation
% ========================================================================
% OUTPUT:
%   price_t              (matrix) price vectors over time
%   quantity_t           (matrix) quantity vectors over time
%   price_shock          (vector) prices after shock (partial equilibrium)
%   quantity_shock       (vector) quantities after shock
%   price_eql            (vector) general equillibrium prices
%   quantity_eql         (vector) general equillibrium quantities

%% Determine Coefficients

[ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                          elas_D, elas_S, price, quantity);

                                      
%% Calculate Shock Effects

output = calculateShockCrossEffects( price, quantity, ...
                            alpha_d, beta_d, alpha_s, beta_s, alpha_shock);

alpha_s2 = alpha_s + alpha_shock;

%% Simulate price and quantity movement over time

% solve system after intiial supply shock without moving demand
price_t    = linsolve((beta_s - diag(diag(beta_d))), -(alpha_s2 - alpha_d));
quantity_t = alpha_s2 + beta_s*price_t;


% Simulate supply and demand movements
for t = 2:iterations
        
    % find beta_j * P_j where j =/= i
    temp_j = beta_d*price_t(:,t-1) - diag(diag(beta_d))*price_t(:,t-1);
    
    % calculate price and quantity at time t
    for i = 1:size(price_t,1)
        
        ptemp           = linsolve(beta_s - diag(diag(beta_d)), ...
                                   alpha_d + sum(temp_j(i,:)) - alpha_s2);
        price_t(i,t)    = ptemp(i);
        
        qtemp           = alpha_s2 + beta_s*ptemp;
        quantity_t(i,t) = qtemp(i);
        
    end
    
end

%% Find precise price and quantity in equilibrium

price_shock    = linsolve((beta_s - diag(diag(beta_d))), alpha_d + ...
                    (beta_d*price - diag(diag(beta_d))*price) - alpha_s2);
quantity_shock = alpha_s2 + beta_s*price_shock

price_eql = linsolve(beta_s - beta_d, alpha_d - alpha_s2);
quantity_eql = alpha_s2 + beta_s*price_eql;


end

