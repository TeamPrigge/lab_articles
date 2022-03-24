close all;
fontSize =30;
plotrange = 1; %100./dt; 
f = figure();
ax=gca;
plot(timeRange(1, plotrange:end), vSomaAnalysis(2,plotrange:end),'LineWidth',3);
hold on
plot(timeRange(1,plotrange:end), vDendriteAnalysis(2,plotrange:end),'LineWidth',3);

ax = axProperties(ax);
lgd = legend('\textbf{Soma}', '\textbf{Dendrite}'); 
lgd = legendProperties(lgd);
% lg.Location = 'northeastoutside';

xlabel('\textbf{Time [ms]}','Interpreter', 'latex')
ylabel('\textbf{V Soma [mV]}','Interpreter', 'latex')
axis square
title('\textbf{Soma}','Interpreter', 'latex')
box off
ax.YLim = [-110, 80];
% ax.XLim = [20, 300];
ax.TickLabelInterpreter = 'latex';

name = "Images/SpikeShapeSomaAndDendrite"+ appendFilename+ ".pdf";
savePlot(name,f)
   
