function [FF_w_i f]=  fanofactor(I_all,spikeTime)

fs = 14;

%% load spike trains

Ntrain = numel(I_all);

%% prepare arrays

Ntime = 100000;

Nwindow = 21;
Window = round(10.^linspace(2,4,Nwindow));

FF_w_i = nan(Nwindow,Ntrain);

%% loop over trains and window size
for i = 1 : Ntrain
    
    ist = spikeTime{i};
    
    for w = 1 : Nwindow
        
        winwidth = Window(w);
        
        halfwidth = floor(winwidth/2);
        
        nwin1    = floor(Ntime/winwidth);
        
        nwin2    = floor((Ntime-halfwidth)/winwidth);
        
        %% make rectangular spike array
        
        train = zeros(1,Ntime);
        train(ist) = 1;
        
        array1 = reshape(train(1:nwin1*winwidth),nwin1,winwidth);
        array2 = reshape(train(halfwidth:halfwidth-1+nwin2*winwidth),nwin2,winwidth);
       
        
        %% establish count and FF
        
        count1 = sum(array1,2);
        count2 = sum(array2,2);
        count  = [count1' count2'];
        
        sigma2_w = var(count);
        mu_w = mean(count);
        
        [i w sigma2_w/mu_w];
        
        FF_w_i( w, i ) = sigma2_w / mu_w;
        
    end
end
sample = 4:4:Ntrain; 
f = figure();
for a = 1:15
    i = sample(a); 
    subplot(3,5,a);
    hold on;
    plot(log10(Window),FF_w_i(:,i), 'k.', 'MarkerSize', 30);
    hold off;
    set(gca,'XLim',[2 4],'Ylim', [0.5 2.0]); 
    ax=gca;
    title(['\textbf {I=}' num2str(I_all(i)) '$\mu$A' ],'Interpreter','latex' ,'FontSize',fs);
    if mod(i,5)==1
        ylabel('FF','FontSize',fs, 'Interpreter','latex');
    end
    if i>10
        xlabel('\textbf {log10}','FontSize',fs,'Interpreter','latex');
    end
    ax.LineWidth = 2;
    ax.FontSize = 30;
    ax.FontWeight = 'Bold';
    ax.TickLabelInterpreter = 'latex';
    
end

            
print('FanoFactors', '-depsc2');
        
        
        
        

return ;
