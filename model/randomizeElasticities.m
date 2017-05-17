function [ elas_D2, elas_S2 ] = randomizeElasticities( elas_D, elas_S, ...
                                                       sigma_D, sigma_S )

% RANDOMIZEELASTICITIES adds a normally distributed random variable to 
% a set of given elasticities
% ========================================================================
% INPUT ARGUMENTS:
%   elas_D               (matrix)  diagonal entries are elasticity of demand
%                                  and non-diagonal entries are cross elas
%   elas_S               (matrix)  same as elas_D but for supply
%   sigma_D              (scalar)  standard deviation of normal RV added to
%                                  the demand elasticities
%   sigma_S              (scalar)  same as sigma_D but for supply 
% ========================================================================
% OUTPUT:
%   elas_D2              (matrix)  demand elasticities with added RV
%   elas_S2              (matrix)  supply elasticities with added RV
% ========================================================================

%% Generate random vars

rv_D = normrnd(0, sigma_D, size(elas_D,1), size(elas_D,2));
rv_S = normrnd(0, sigma_S, size(elas_S,1), size(elas_S,2));


%% Add random vars to elasticities

elas_D2 = elas_D + rv_D;
elas_S2 = elas_S + rv_S;

% Replace instances where signs flipped with 0
ind = find((sign(elas_D) + sign(elas_D2)) == 0);
elas_D2(ind) = 0;

ind = find((sign(elas_S) + sign(elas_S2)) == 0);
elas_S2(ind) = 0;

end
