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

%% Main

m = size(elas,1);
n = size(elas,2);

switch lower(rv_type)
    
    case 'triangle'
        rv = arg2 + sqrt(rand(1)).*(arg1-arg2 + rand(1)*(elas-arg1));
        elas_randomized = rv;
        
    case 'uniform'
        rv = unifrnd(arg1, arg2, m, n);
        elas_randomized = rv;
        
    case 'normal'
        if arg1 > 0
            rv = normrnd(0, arg1, m, n);
        else
            elas_randomized = elas;
            return;
        end
        
        % use truncated normal for own price elasticities
        for i = 1:length(elas)
            
            % create normal distribution object
            normal_dist = makedist('Normal', 0, arg1);
            
            % truncate based on elasticity
            if elas(i,i) > 0
                normal_dist_trun = truncate(normal_dist, -elas(i,i), 100);
            else
                normal_dist_trun = truncate(normal_dist, -100, -elas(i,i));
            end

            rv(i,i) = random(normal_dist_trun);
        end
        
        elas_randomized = elas + rv;
        
    otherwise
        error('Unknown distribution type')
end

end
