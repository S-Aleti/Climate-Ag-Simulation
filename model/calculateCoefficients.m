function [ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                          elas_D, elas_S, price, quantity)
% ========================================================================
% CALCULATECOEFFICIENTS Uses elasticity to determinet the coefficients
% of a linear curve: quantity = alpha + beta*price
% ========================================================================
% INPUT ARGUMENTS:
%   elas_D               (scalar) elasticity of demand 
%   elas_S               (scalar) elasticity of suppy 
%   price                (scalar) current price ($/tonne)
%   quantity             (scalar) control (tonne)
% ========================================================================
% OUTPUT:
%   alpha_d              (scalar) intercept of demand curve
%   beta_d               (scalar) slope of demand curve
%   alpha_s              (scalar) intercept of supply curve
%   beta_s               (scalar) slope of supply curve
% ========================================================================

%% New Variables for Multiple Commodities

Q = repmat(quantity, 1, size(quantity,1));
P = repmat(price, 1, size(price,1));

%% Calculate demand function

% slope of the (linear) demand curve 
beta_d = (elas_D) .* (Q) ./ (P') ;

% intercept of the (linear) demand curve
alpha_d = quantity - (beta_d) * (price);

%% Calculate supply function

% slope of (linear) supply curve
beta_s = (elas_S) .* (Q) ./ (P') ;

% intercept of the (linear) supply curve
alpha_s = quantity - (beta_s) * (price);

end

