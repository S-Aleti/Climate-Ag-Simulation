function [ price_eqls, quantity_eqls ] = runSimulation( price, quantity,...
                    elas_D, elas_S, alpha_shocks, iterations, plot_results)
                
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
%   price_eqls           (matrix) general equillibrium prices for each 
%                                 supply shock
%   quantity_eql         (matrix) general equillibrium quantities for each
%                                 supply shock
% ========================================================================

% initialize vars to 0
price_eqls     = zeros(size(price,1),size(alpha_shocks,2));
quantity_eqls  = price_eqls;

for shock_num = 1:size(alpha_shocks,2)
    
    % specific supply shock
    alpha_shock = alpha_shocks(:,shock_num);
    
    % results of each shock
    [ ~, ~, ~, ~, price_eql, quantity_eql ] = simulateShock(price, ...
          quantity, elas_D, elas_S, alpha_shock, iterations, plot_results);

    price_eqls(:,shock_num)     = price_eql;
    quantity_eqls(:,shock_num)  = quantity_eql;  
    
    
end

end

