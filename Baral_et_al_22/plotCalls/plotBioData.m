T = readtable('../Test/DataAllBio/SingleCell.xlsx');
f = figure(); 
ax=gca;
plot(T.Time-50, T.sweepNo__5,'LineWidth',2); hold on; plot(timeRange , vSomaAnalysis(I_all==0,:),'LineWidth',2);

lgd = legend('\textbf{Experimental Neuron}', '\textbf{Simulated Neuron}'); 
lgd = legendProperties(lgd);

% lg.Location = 'northeastoutside';
xlabel('\textbf{Time [ms]}','Interpreter', 'latex')
ylabel('\textbf{Membrane Voltage [mV]}','Interpreter', 'latex')
ax = axProperties(ax);
axis square
title('\textbf{Soma}','Interpreter', 'latex')
box off
ax.YLim = [-110, 80];
% ax.XLim = [20, 300];
ax.TickLabelInterpreter = 'latex';

if saveGraph
name = "Images/testSimulation/BioVsSimulation.pdf";
name_eps = "Images/testSimulation/BioVsSimulation.eps";
print(name_eps,'-dpdf','-fillpage');

savePlot(name,f)
end

%% Simuated Neuron at Spontaneous state
f = figure(); 
ax=gca;
plot(timeRange , vSomaAnalysis(I_all==0,:),'LineWidth',2);
ax = axProperties(ax);
xlabel('\textbf{Time [ms]}','Interpreter', 'latex')
ylabel('\textbf{Membrane Voltage [mV]}','Interpreter', 'latex')
axis square
title(' \textbf {Simuated Neuron at Spontaneous state}', 'Interpreter', 'latex')
box off
ax.TickLabelInterpreter = 'latex';
ax.YLim = [-110, 40];
if saveGraph
name = "Images/testSimulation/SimuatedMembrane.pdf";
name_eps = "Images/testSimulation/SimuatedMembrane.eps";
 print(name_eps,'-dpdf','-fillpage');
savePlot(name,f)
end
%% Simuated Neuron Spike Shape

f = figure(); 
ax=gca;
plot(timeRange , vSomaAnalysis(I_all==0,:),'LineWidth',2);
ax = axProperties(ax);
xlabel('\textbf{Time [ms]}','Interpreter', 'latex')
ylabel('\textbf{Membrane Voltage [mV]}','Interpreter', 'latex')
axis square
title(' \textbf {Simuated Neuron Spike Shape}', 'Interpreter', 'latex')
box off
ax.YLim = [-110, 40];
ax.XLim = [420, 520];
ax.XTick = 0:20: 1000; 

ax.TickLabelInterpreter = 'latex';

if saveGraph
name = "Images/testSimulation/SimuatedMembraneZoomed.pdf";
name_eps = "Images/testSimulation/SimuatedMembraneZoomed.eps";
 print(name_eps,'-dpdf','-fillpage');
savePlot(name,f)

end