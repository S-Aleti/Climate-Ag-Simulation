function [ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                          elas_D, elas_S, price, quantity)

% CALCULATECOEFFICIENTS Uses elasticity to determinet the coefficients
% of a linear curve
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

%% Calculate demand function

% slope of the (linear) demand curve 
beta_d = -(1/elas_D)*(price/quantity);

% intercept of the (linear) demand curve
alpha_d = price + beta_d*quantity;

%% Calculate supply function

% slope of (linear) supply curve
beta_s = -(1/elas_S)*(price/quantity);

% intercept of the (linear) supply curve
alpha_s = price + beta_s*quantity;

end

