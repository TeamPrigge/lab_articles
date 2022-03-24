fontSize = 30;
LineWidth = 3; 
close all; clc;
f = figure;
subplot(3, 1, 1)
ax = gca(); 

test__ = nan(17, lengthTimeRange);
test__(6,:) = 6*spiketrain(1, :);
test__(12,:) = 12*spiketrain(2, :);
test__(test__==0) =nan; 
scatter(timeRange,test__, 500, 'K', '|')
ylabel('\textbf {Current nA}', 'Interpreter', 'latex')
title("\textbf {Spike train}", 'Interpreter', 'latex')
box on
ax.LineWidth = 2;
ax.FontSize = fontSize;
ax.FontWeight = 'Bold';
ax.TickLabelInterpreter = 'latex';
ax.YTick = [6, 12];
ax.YLim = [3 15];
ax.XLim = [-10 5510];
ax.TickLength = [0,0];
ax.YTickLabel = ["N1", "N2"];