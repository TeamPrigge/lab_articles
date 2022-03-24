for i =1:nNeurons
     upd_spiketrain(i,:) = i.*spiketrain(i,:);
end
figure()
scatter(timeRange,upd_spiketrain, 500, 'K', '|')
ax=gca;
ax = axProperties(ax);
xlabel('\textbf {Time [ms]}', 'Interpreter', 'latex'); 
ax.XLim=([-10, 1010]);
ax.YLim=[1 size(upd_spiketrain,1)];
ax.YTick = 1:10:size(upd_spiketrain,1);
ax.YTickLabel = num2cell(I_all(1:10:end));
title("\textbf {Spike Train}", 'Interpreter', 'latex')