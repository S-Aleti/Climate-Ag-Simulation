function [ price_t, quantity_t, price_shock, quantity_shock, price_eql, ...
    quantity_eql ] = simulateShock(price, quantity, elas_D, elas_S,     ...
    alpha_shock, iterations, plot_results)

% SIMULATESHOCK determines the change in price and quantity over time given
% a shock to a system
% ========================================================================
% INPUT ARGUMENTS:
%   price                (vector)  current price ($/tonnes)
%   quantity             (vector)  current quantity (tonnes)
%   elas_D               (matrix)  diagonal entries are elasticity of demand
%                                  and non-diagonal entries are cross elas
%   elas_S               (matrix)  same as elas_D but for supply
%   alpha_shock          (scalar)  shift in supply curve
%   iterations           (scalar)  iterations of the supply and
%                                  demand simulation
%   plot_results         (boolean) set to true to produce plots of supply
%                                  and demand effects
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
quantity_shock = alpha_s2 + beta_s*price_shock;

price_eql = linsolve(beta_s - beta_d, alpha_d - alpha_s2);
quantity_eql = alpha_s2 + beta_s*price_eql;

%% Plot results

if nargin < 7
    plot_results = false;
end

if plot_results
    for c = 1:size(price_t,1) % for each commodity
        
        x = linspace(0.85*min([price(c), price_shock(c), price_eql(c)]),...
                  1.15*max([price(c), price_shock(c), price_eql(c)]), 100);
        
        figure;
        hold on;
        
        % intial supply and demand
        ptemp = repmat(price, 1, 100);
        ptemp(c,:) = x;
        q_demand = repmat(alpha_d, 1, 100) + beta_d*ptemp;
        q_supply = repmat(alpha_s, 1, 100) + beta_s*ptemp;
        
        % intial demand graph
        plot(q_demand(c,:), x, 'color', colormap([0 0 0]));
        % intial supply graph
        plot(q_supply(c,:), x, 'color', colormap([0 0 0]));
            
        % each step of the simulation
        for t = 1:iterations
            
            % price vector without fixed commodity c price
            ptemp = repmat(price_t(:,t), 1, 100);
            ptemp(c,:) = x;
            
            q_demand = repmat(alpha_d,  1, 100) + beta_d*ptemp;
            q_supply = repmat(alpha_s2, 1, 100) + beta_s*ptemp;
            
            % demand graph
            plot(q_demand(c,:), x, 'color', ...
                colormap([t/iterations 0 1]));
            
            % supply graph
            plot(q_supply(c,:), x, 'color', ...
                colormap([1 t/iterations/2 0]));
            
        end
        
        % intial value
        plot(quantity(c), price(c), 'ko');
        
        % partial equilibrium
        plot(quantity_shock(c), price_shock(c), 'k+');
        
        % final value
        plot(quantity_eql(c), price_eql(c), 'kx');
        
        title(['Commodity ' , num2str(c)]);
        xlabel(['Quantity']);
        ylabel(['Price']);
        
    end
end

end

