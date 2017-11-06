close all

%% Params

% Example values that generate visually clear supply and demand graph
price    = 10;
quantity = 11;
elas_D = -0.75;
elas_S = 1.1;

[ alpha_d, beta_d, alpha_s, beta_s ] = calculateCoefficients( ...
                                          elas_D, elas_S, price, quantity);
alpha_shock = -70;
alpha_s2 = alpha_s + alpha_shock;


%% Create supply and demand curve
                                      
demand  = @(p) alpha_d + beta_d*p;
supply  = @(p) alpha_s + beta_s*p;
supply2 = @(p) alpha_s + alpha_shock + beta_s*p;

eq_p1 = (alpha_s - alpha_d)/ (beta_d - beta_s);
eq_p2 = (alpha_s2 - alpha_d)/ (beta_d - beta_s);


%% Plot curves

fig = figure; hold on;

% price range
price_range = linspace(0, (-alpha_d/beta_d), 10);

% get data
quantity_demand  = demand(price_range);
quantity_supply  = supply(price_range);
quantity_supply2 = supply2(price_range);

% plot data
plot(quantity_demand,  price_range, 'b--', 'LineWidth', 1);
plot(quantity_supply,  price_range, 'r--', 'LineWidth', 1);
plot(quantity_supply2, price_range, 'Color',[1 0.3 0.3]);

plot([0 demand(eq_p1)], [eq_p1 eq_p1], 'k--')
plot([0 demand(eq_p2)], [eq_p2 eq_p2], 'k--')

% plot options
axis([0 quantity*2 0 1.1*max(price_range)])
xlabel('Q'); ylabel('P');
set(gca,'xtick',[])
set(gca,'ytick',[])


%% Regions

demand_Q0 = fzero(demand, 0);
supply_Q0 = max(fzero(supply,0), 0);
supply2_Q0 = max(fzero(supply2,0), 0);

% Surplus L1
L1_x = [0, supply2(eq_p1), supply2(eq_p2), 0];
L1_y = [eq_p1, eq_p1, eq_p2, eq_p2];

% Surplus L2
L2_x = [supply2(eq_p1), supply(eq_p1), supply2(eq_p2)];
L2_y = [eq_p1, eq_p1, eq_p2];

% Surplus L3
L3_x = [alpha_s2, alpha_s, supply(eq_p1), supply2(eq_p1)];
L3_y = [0, 0, eq_p1, eq_p1];

alpha = 0.4;
fill(L1_x, L1_y, [0 0 1], 'facealpha', alpha, 'LineStyle', 'none')
fill(L2_x, L2_y, [0 1 0], 'facealpha', alpha, 'LineStyle', 'none')
fill(L3_x, L3_y, [1 0 0], 'facealpha', alpha, 'LineStyle', 'none')

% Labels
fontsize = 10;
text((supply2(eq_p1)+ supply2(eq_p2))/5, (eq_p1 + eq_p2)/2, 'L1',      ...
        'HorizontalAlignment', 'center', 'FontSize', fontsize)
text(sum([supply2(eq_p1)/4,  quantity/4, demand(eq_p2)/2]),            ...
        (eq_p1 + eq_p2)/2, 'L2', 'HorizontalAlignment', 'center',      ...
        'FontSize', fontsize)
text(supply2(eq_p1), mean([eq_p1, (supply2(eq_p1) - alpha_s)/beta_s]), ...
        'L3', 'HorizontalAlignment', 'center', 'FontSize', fontsize)

legend({'Demand', 'Supply', 'Supply_{shock}'})

%%

fig.PaperPosition = [1 1 5 4];
saveas(gca, 'examples/surplus.png')


