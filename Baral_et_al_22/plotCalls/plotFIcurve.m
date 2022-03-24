f1 = figure(1);
ax=gca;
LineWidth = 2;
lgd = legend();
ax = axProperties(ax);
ax.YLim = [-2 20]; 
ax.XLim = [-30 270]; 
lgd = legendProperties(lgd);

sz= 20;
hold all
plot(I_all,fi_SomaStart, '-', 'MarkerSize', sz, 'LineWidth',2)
plot(I_all,fi_SomaStable, '-', 'MarkerSize', sz,'LineWidth',2)
plot(0, fi_SomaStart(I_all ==0), 'k*', 'LineWidth', 2, 'MarkerSize', 10)
plot(I_all, zeros(size(I_all)), 'k--');
plot([0 0], [0 max(fi_SomaStable)], 'k--');
ylabel('\textbf {Firing Rate $\gamma$ [Hz]}', 'Interpreter', 'latex')
xlabel('\textbf {Current nA}', 'Interpreter', 'latex')


% yyaxis right;
% plot(I_all, numSpikes, '-', 'MarkerSize', sz,'LineWidth',2)
% ylabel('\textbf {# Spikes}', 'Interpreter', 'latex')
% ax.YLim = [-1 9]; 
% ax.XLim = [-20 150]; 

axis square
hold off

lgd.String = {'$f_{0}$', '$f_{\infty}$'};


box off
%%
% if saveGraph
    
% end