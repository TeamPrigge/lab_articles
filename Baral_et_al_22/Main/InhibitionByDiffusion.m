% fresh workspace
clear all; clc;
% close all;

addpath('../initialization/', '../Util/', '../Functions/')
addpath('../plotCalls/', '../plotCalls/Images/')

% add all the paths
flags; % Sets flags


parameters; % loads parameters to run the simulation; defined by us; 


% time factors
dt= 0.01;
timeEnd = 10000;
timeRange= 1:dt:timeEnd; % ms%
lengthTimeRange = length(timeRange);

initialInhibitionCurrent = -12; % suppress firing before stimulation
equilibriumLength = length(1:dt:1000); % achieve equilibrium in given time; 

% Current Injection
nNeurons =2;
sptime = 500;
I_inj = 270; 
I = zeros(nNeurons, lengthTimeRange);

I(1, sptime/dt:1500/dt) = I_inj;
I(1, 3000/dt:4000/dt) = I_inj;    
I(1, 5000/dt:6000/dt) = I_inj;
I(1, 8000/dt:9000/dt) = I_inj;

I(2, :) = 15;
I = [zeros(nNeurons, equilibriumLength)+ initialInhibitionCurrent  I]; 
    
Ca_ap(1, 1) =0;
initialization
addNoise =0;
if addNoise
    noise = addNoiseFunc(equilibriumLength+lengthTimeRange, nNeurons, dt, plotflagOU);
    appendFilename = "_withNoise";
else
    noise = zeros(nNeurons,equilibriumLength+lengthTimeRange);
    appendFilename = "_withoutNoise";
end
ApCount = 0; 
ap(1, 1) = 0; 
gD = 0.01;
gLd = 0.1;
Ca_high = 1.3;
timeRange_ = [1:dt:1000, timeRange];
tauFast = 1200;
tauSlow = 1400;
for iTime=1:length(I)-1
    mInfCa(:,iTime) = 1./(1 + exp(-(vSoma(:,iTime)+Vref + 55)./9));     
    % Spike generating current
    iNa(:,iTime)  = gNa.*(mGate(:,iTime).^3).*hGate(:,iTime).*(vSoma(:,iTime) - vNa);
    iK(:,iTime)   = gK.* (nGate(:,iTime).^4) .*(vSoma(:,iTime) - vK);
    iL(:,iTime)   = gL.*(vSoma(:,iTime) -vL);                                               % leak current
    iP(:,iTime)   = gP.*(pGate(:,iTime).^2) .*(vSoma(:,iTime) - vNa);                       % a slow persistent sodium current
    iAhp(:,iTime) = gAhp.*(Ca(:,iTime)./(Ca(:,iTime) + 1)).*(vSoma(:,iTime) - vK);          % afterhyperpolarization current
    iCa(:,iTime)  = gCa.*(mInfCa(:,iTime)).^2.* yGate(:,iTime).*(vSoma(:,iTime) - vCa);     % calcium current

    % The membrane potential Soma
    dVS = (I(:,iTime) - iNa(:,iTime) - iK(:,iTime) - iL(:,iTime) - iCa(:,iTime) - iP(:,iTime) - iAhp(:,iTime)...
        - gD.*(vSoma(:,iTime) - vDendrite(:,iTime)) - iAlpha2SomatoSomatic(:,iTime) + noise(:, iTime)).*dt./C;
     assert(sum(isnan(dVS))==0,"Nan found in soma")
    vSoma(:,iTime + 1) = vSoma(:,iTime)+ dVS;

    if or(addGapJunction,allowgap)     
             gapJunctionCurrent(:,iTime) = (sum(g.*((vDendrite(:,iTime) - vDendrite(:,iTime)') .* connectivityDendriteGapJunction),2));
    else
        gapJunctionCurrent(:,iTime) = 0;
    end

     % The membrane potential Dendrite
     dVD = ((-gLd.*(vDendrite(:,iTime) - vLd)) - gD.*(vDendrite(:,iTime) - vSoma(:,iTime))- gapJunctionCurrent(:,iTime)).*dt./C;
     vDendrite(:,iTime+1) = vDendrite(:,iTime) + dVD;        
    
     %pick action potential
    if iTime+1> equilibriumLength        
       gRect(2,iTime+1) = 0.2./(1+exp(0.05.*(vSoma(2,iTime+1)-vK)));
       f = ((tauFast/tauSlow)^(tauFast/(tauSlow-tauFast)) - (tauFast/tauSlow)^(tauSlow/(tauSlow-tauFast)))^-1;
%                calciumDependence(1, iTime) = (Ca(1, iTime).^k - Ca_low.^k)./(Ca_high.^k - Ca_low.^k);
     if vSoma(1,iTime)<0 && vSoma(1,iTime+1)>0 
        ap(1, ApCount+1) = timeRange_(iTime);
        ApCount = ApCount+1; 
        Ca_ap(1, ApCount) = Ca(1, iTime); 
     end
        time = timeRange_(iTime);
        calciumDependence(1, 1:ApCount) = (2.* Ca_ap(1, 1:ApCount).^k)./(Ca_high^k + Ca_ap(1, 1:ApCount).^k);  
            

        % calculate slow and fast
        fast(1:ApCount, iTime)  = exp(-(time-ap(1,1:ApCount)')./tauFast);
        slow(1:ApCount, iTime) = exp(-(time-ap(1,1:ApCount)')./tauSlow);  
        girk(1:ApCount, iTime) = 0.2.*(slow(1:ApCount, iTime)-fast(1:ApCount, iTime)).* calciumDependence(1, 1:ApCount)';
       iAlpha2SomatoSomatic(2,iTime+1) = sum(girk(1:ApCount,iTime), 1) .* gRect(2,iTime+1).* ((vSoma(2,iTime+1) - vK)).*f * 5; %somatoSomaticConnectivity(2,1);
       iAlpha2SomatoSomatic(1,iTime+1) = 0;
    end
    
    % Gating variable m
    mGate(:,iTime+1) = update_m(vSoma(:,iTime+1)+Vref, mGate(:,iTime), dt, 0, 0);
    
    % Gating variable n
    nGate(:,iTime+1) = update_n(vSoma(:,iTime+1)+Vref, nGate(:,iTime), dt, 0, 0);
    
    % Gating variable h
    hGate(:,iTime+1) = update_h(vSoma(:,iTime+1)+Vref, hGate(:,iTime), dt, 0, 0);
    
    % Gating variable p for a slow persistent sodium current
    pGate(:,iTime+1) = update_p(vSoma(:,iTime+1)+Vref, pGate(:,iTime), dt,0, 0);
    
    % Calcium update ca
    Ca(:,iTime+1) = update_ca(vSoma(:,iTime+1)+Vref,Ca(:,iTime),dt, vCa, mCa, 0, 0);
    
    % Gating variable y
    yGate(:,iTime+1) = update_y(vSoma(:,iTime+1)+Vref, yGate(:,iTime), dt,0, 0, sign_y);
    
end
vSomaAnalysis = vSoma(:, equilibriumLength+1:end);
vDendriteAnalysis = vDendrite(:, equilibriumLength+1:end);
gapJunctionCurrentAnalysis = gapJunctionCurrent(:, equilibriumLength:end);
girkAnalysis = girk(:, equilibriumLength:end);

[spiketrain,spikeTime,frequencySoma, fi_SomaStart,fi_SomaMean, fi_SomaStable,SpikeTimeInterval, numSpikes]...
    = analyseApFrequency(nNeurons,timeRange, vSomaAnalysis, dt);


if twoNeuronInhibition
    plot2neuronInhibition    
    name = "Images/OneNeuronInhibitingAnotherDiffusion"+ appendFilename+ ".pdf";
    savePlot(name,f)
end
%% Poorly written

[~, timeSIndx1]=findpeaks(vSomaAnalysis(2,1:(2000/dt)),'MinPeakHeight',10);
timeS1 = (timeRange(timeSIndx1));

[~, timeSIndx2]=findpeaks(vSomaAnalysis(2,(2000/dt):(4000/dt)),'MinPeakHeight',10);
timeS2 = (timeRange(timeSIndx2));

[~, timeSIndx3]=findpeaks(vSomaAnalysis(2,(4000/dt):(6000/dt)),'MinPeakHeight',10);
timeS3 = (timeRange(timeSIndx3));


[~, timeSIndx4]=findpeaks(vSomaAnalysis(2,(6000/dt):(8000/dt)),'MinPeakHeight',10);
timeS4 = (timeRange(timeSIndx4));

[~, timeSIndx5]=findpeaks(vSomaAnalysis(2,(8000/dt):end),'MinPeakHeight',10);
timeS5 = (timeRange(timeSIndx5));

histogram([diff(timeS1),diff(timeS2), diff(timeS3), diff(timeS4), diff(timeS5)], 5)
hold on
histogram(1./(SpikeTimeInterval{2}),5)

figure()
hold all
histogram(1, [diff(timeS1)], 1)
histogram(2, [diff(timeS2)], 1)
histogram(3, [diff(timeS3)], 1)
histogram(4, [diff(timeS4)], 1)
histogram(5, [diff(timeS5)], 1)
%%

f = figure();
means = [mean(diff(timeS1)),mean(diff(timeS2)), mean(diff(timeS3)), mean(diff(timeS4)), mean(diff(timeS5))];
deviatins = [std(diff(timeS1)),std(diff(timeS2)), std(diff(timeS3)), std(diff(timeS4)), std(diff(timeS5))];
e = errorbar(1:5,means,deviatins, 'LineWidth',2);
e.Marker = '.'; 
e.MarkerSize = 50;
ax = gca();
title("\textbf {Effect of diffusion}", 'Interpreter', 'latex')
ylabel('\textbf {ISI}', 'Interpreter', 'latex')
xlabel('\textbf {Time bin of 2 [S]}', 'Interpreter', 'latex')
box on;
ax.XLim= [0.8, 5.2];
ax.XTick = 1:5;
ax.XTickLabel= [2, 4, 6, 8, 10];
ax.LineWidth = 2;
ax.FontSize = fontSize;
ax.FontWeight = 'Bold';
ax.TickLabelInterpreter = 'latex';
name = "Images/OneInhibitinganother/OneNeuronInhibitingAnotherDiffusionErrorbar"+ appendFilename+ ".pdf";
name_eps = "Images/OneInhibitinganother/OneNeuronInhibitingAnotherDiffusionErrorbar"+ appendFilename+ ".eps";
print(name_eps,'-dpdf','-fillpage');
savePlot(name,f)
