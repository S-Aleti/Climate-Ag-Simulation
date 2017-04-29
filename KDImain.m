
%% Gas and Electricity Data

price = [1432.92,90.48]';
quantity = [76579*42*3.78,490399*1000000]';
elas_D = [-0.3,0;0,-0.1];
elas_S = diag([0.15,1/4]);

%% 

calculateCoefficients( 