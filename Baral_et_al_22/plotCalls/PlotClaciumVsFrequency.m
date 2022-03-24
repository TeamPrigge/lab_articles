f2 = figure(2);
ax=gca;
LineWidth = 2;
lgd = legend();
ax = axProperties(ax);
ax.YLim = [-0.1 1.6]; 
ax.XLim = [-0.1 24]; 
lgd = legendProperties(lgd);

sz= 20;
hold all
plot(fi_SomaStable, min(Ca'), '-', 'MarkerSize', sz,'LineWidth',2)
plot(fi_SomaStable, max(Ca'), '-', 'MarkerSize', sz,'LineWidth',2)

xline(20, 'k--','LineWidth', 2)
yline(1.3, 'k--','LineWidth', 2)
plot([20 1.3], [1.3 20], 'k*', 'LineWidth', 2, 'MarkerSize', 15)
% plot(fi_SomaStable, zeros(size(I_all)), 'k--');
% plot([0 0], [0 max(fi_SomaStable)], 'k--');


xlabel('\textbf {Firing Rate $\gamma$ [Hz]}', 'Interpreter', 'latex')
ylabel('\textbf {[Ca]}', 'Interpreter', 'latex')


% yyaxis right;
% plot(I_all, numSpikes, '-', 'MarkerSize', sz,'LineWidth',2)
% ylabel('\textbf {# Spikes}', 'Interpreter', 'latex')
% ax.YLim = [-1 9]; 
% ax.XLim = [-20 150]; 
ax.XTick = [0:4:24];
axis square
hold off

lgd.String = {'$[Ca]_{min}$', '$$[Ca]_{max}$'};
