function [ elas_randomized ] = randomizeElasticities( elas, rv_type, ...
                                                      arg1, arg2 )

% RANDOMIZEELASTICITIES adds a specified type of random variable to a set 
% of given elasticities
% ========================================================================
% INPUT ARGUMENTS:
%   elas                 (matrix)  contains elasticities; diagonal entries
%                                  are own price elasticities, others are
%                                  cross price elasticities
%   rv_type              (string)  type of distribution to use for the RV;
%                                  'triangle', 'uniform', or 'normal'
%   arg1                 (matrix)  use varies; lower bound for triangle and
%                                  uniform dist or stdev for normal dist
%   arg2                 (matrix)  use varies: upper bound for triangle 
%                                  or uniform dist, ignored for normal dist 
% ========================================================================
% OUTPUT:
%   elas_randomized      (matrix)  elasticities with added RV
% ========================================================================

%% Generate random vars

m = size(elas,1);
n = size(elas,2);

switch rv_type
    case 'triangle'
        rv = arg2 + sqrt(rand(1)).*(arg1-arg2 + rand(1)*(elas-arg1));
        elas_randomized = rv;
    case 'uniform'
        rv = unifrnd(arg1, arg2, m, n);
        elas_randomized = elas + rv;
    case 'normal'
        rv = normrnd(0, arg1, m, n);
        elas_randomized = elas + rv;
    otherwise
        error('Unknown distribution type')
end


%% Add random vars to elasticities

elas_randomized = elas + rv;

% Replace instances where signs flipped with 0
ind = find((sign(diag(elas)) + sign(diag(elas_randomized))) == 0);
for i = 1:length(ind)
    j = ind(i);
    elas_randomized(j, j) = 0;
end

end
