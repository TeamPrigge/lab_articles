fontSize =30;
plotrange = 1; %100./dt; 
f = figure();
subplot(1,2,1)
ax=gca;

plot(timeRange(1, plotrange:end), vSomaAnalysis(1,plotrange:end),'LineWidth',3); hold on;
p1 = plot(timeRange(1, plotrange:end), vSomaAnalysis(2,plotrange:end),'LineWidth',3);
p1.Color(4) = 0.4;
ax = axProperties(ax);
lgd = legend('\textbf{Neuron 1}', '\textbf{Neuron 2}'); 
lgd = legendProperties(lgd);

% lg.Location = 'northeastoutside';

xlabel('\textbf{Time [ms]}','Interpreter', 'latex')
ylabel('\textbf{V Soma [mV]}','Interpreter', 'latex')
axis square
title('\textbf{Soma}','Interpreter', 'latex')
box off
ax.YLim = [-110, 40];
% ax.XLim = [20, 300];
ax.TickLabelInterpreter = 'latex';

subplot(1,2,2)
ax=gca;
plot(timeRange(1,plotrange:end), vDendriteAnalysis(1,plotrange:end),'LineWidth',3); hold on;
p1 = plot(timeRange(1,plotrange:end), vDendriteAnalysis(2,plotrange:end),'LineWidth',3);  hold on;
p1.Color(4) = 0.4;
% plot(timeRange(1,plotrange:end), gapJunctionCurrentAnalysis(2,plotrange:end),'LineWidth',3);
lgd = legend('\textbf{Neuron 1}', '\textbf{Neuron 2}'); 
lgd = legendProperties(lgd);
ax = axProperties(ax);
% lg.Location = 'northeastoutside';
title('\textbf{Dendrite}', 'Interpreter', 'latex')
xlabel('\textbf{Time [ms]}', 'Interpreter','latex')
ylabel('\textbf{V Dendrite [mV]}','Interpreter', 'latex')
axis square
box off
ax.YLim = [-110, 0];
% ax.XLim = [20, 300];
sg = sgtitle('\textbf{Soma and dendrites without Gap junction}');
sg.Interpreter = 'latex'; 
sg.FontSize = 30; 
sg.FontWeight = 'bold';
% 
% name = "Images/Fig4_GapJunSpikeShapeSomaAndDendrite"+ appendFilename+ ".pdf";
% savePlot(name,f)
  


   
