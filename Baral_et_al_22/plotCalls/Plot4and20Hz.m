
fontSize = 30;
LineWidth = 3;
t = floor(fi_SomaStable);
hz4 = find(t>=4,1);
hz20 = find(t>=20,1);
f1 = figure();

subplot(2,2,[1,2])
ax = gca();
test__ = nan(nNeurons, lengthTimeRange);
test__(hz20,:) = hz20*spiketrain(hz20, :);
test__(hz4,:) = hz4*spiketrain(hz4, :);
test__(test__==0) =nan; 
scatter(timeRange,test__, 500, 'K', '|')
xlabel('\textbf {Time [ms]}', 'Interpreter', 'latex')
ylabel('\textbf {Current nA}', 'Interpreter', 'latex')
box off
title("\textbf {Spike train}", 'Interpreter', 'latex')

box on
ax.LineWidth = 2;
ax.FontSize = fontSize;
ax.FontWeight = 'Bold';
ax.TickLabelInterpreter = 'latex';
ax.YTick = [hz4, hz20];
ax.YLim = [hz4-3 hz20+3];
ax.XLim = [-10 1010];
ax.TickLength = [0,0];
ax.YTickLabel = [I_all(hz4) I_all(hz20)];

subplot(2,2,3)
ax = gca;
plot( Ca(hz4,1:end), vSoma(hz4,1:end),'LineWidth', LineWidth);
box on
% axis square
% xlabel('\textbf {Time [ms]}', 'Interpreter', 'latex')
xlabel('\textbf {Ca [$\mu$M]}', 'Interpreter', 'latex')
ylabel('\textbf {V Soma  [mV]}', 'Interpreter', 'latex')
ax.XLim = [-0.5 1.6];
ax.LineWidth = 2;
ax.FontSize = fontSize;
ax.FontWeight = 'Bold';
ax.TickLabelInterpreter = 'latex';
title("\textbf {Evolution of Calcium at 4 Hz}", 'Interpreter', 'latex')


subplot(2,2,4)
ax = gca;
% plot3(timeRange(1:end), Ca(hz20,1:end), vSoma(hz20,1:end),'LineWidth', LineWidth);
plot(Ca(hz20,1:end), vSoma(hz20,1:end),'LineWidth', LineWidth);
box on
% axis square
% xlabel('\textbf {Time [ms]}', 'Interpreter', 'latex')
xlabel('\textbf {Ca [ $\mu$M]}', 'Interpreter', 'latex')
ylabel('\textbf {V Soma [mV]}', 'Interpreter', 'latex')
% view(76.2313, -2.7370)
ax.XLim = [-0.5 1.6];
ax.LineWidth = 2;
ax.FontSize = fontSize;
ax.FontWeight = 'Bold';
ax.TickLabelInterpreter = 'latex';
title("\textbf {Evolution of Calcium at ~20 Hz}", 'Interpreter', 'latex')

% 
% name = "Images/Fig3_Calciumat4and20hz"+ appendFilename+ ".pdf";
% savePlot(name,f1)


%%
f2=figure();
subplot(1,2,1)
ax = gca;
plot3(timeRange(1:end), CaAnalysis(hz4,1:end), vSomaAnalysis(hz4,1:end),'LineWidth', LineWidth);
% plot( Ca(hz4,1:end), vSoma(hz4,1:end),'LineWidth', LineWidth);
% axis square
xlabel('\textbf {Time [ms]}', 'Interpreter', 'latex')
ylabel('\textbf {Ca [$\mu$M]}', 'Interpreter', 'latex')
zlabel('\textbf {V Soma  [mV]}', 'Interpreter', 'latex')
% ax.XLim = [-0.5 1.6];
ax.LineWidth = 2;
ax.FontSize = fontSize;
ax.FontWeight = 'Bold';
ax.TickLabelInterpreter = 'latex';
title("\textbf {Evolution of Calcium at 4 Hz}", 'Interpreter', 'latex')


subplot(1,2,2)
ax = gca;
plot3(timeRange(1:end), CaAnalysis(hz20,1:end), vSomaAnalysis(hz20,1:end),'LineWidth', LineWidth);
% plot(Ca(hz20,1:end), vSoma(hz20,1:end),'LineWidth', LineWidth);
box on
% axis square
xlabel('\textbf {Time [ms]}', 'Interpreter', 'latex')
ylabel('\textbf {Ca [ $\mu$M]}', 'Interpreter', 'latex')
zlabel('\textbf {V Soma [mV]}', 'Interpreter', 'latex')
% view(76.2313, -2.7370)
% ax.XLim = [-0.5 1.6];
ax.LineWidth = 2;
ax.FontSize = fontSize;
ax.FontWeight = 'Bold';
ax.TickLabelInterpreter = 'latex';
title("\textbf {Evolution of Calcium at ~20 Hz}", 'Interpreter', 'latex')


