 % fresh workspace
clear all; clc;
close all;

% add all the paths
addpath('../initialization/', '../Util/', '../Functions/')
addpath('../plotCalls/', '../plotCalls/Images/')

flags; % Sets flags
stepInjection =0;
parameters; % loads parameters to run the simulation; defined by us; 

% time factors
dt= 0.01;
timeRange= 1:dt:5000; % ms%
lengthTimeRange = length(timeRange);
initialInhibitionCurrent = -12; % suppress firing before stimulation
equilibriumLength = length(1:dt:1000); % achieve equilibrium in given time; 
 
if stepInjection
    nNeurons =2;
    I_inj = 270; 
    I = zeros(nNeurons, lengthTimeRange);
    I(1, 500/dt:1500/dt) = I_inj;
    I(1, 3000/dt:4000/dt) = I_inj;
    I = [zeros(nNeurons, equilibriumLength)+ initialInhibitionCurrent  I];
else 
    I_all = -20:5:280; 
    nNeurons = length(I_all);
    I = zeros(nNeurons, lengthTimeRange)+ I_all';
    I = [zeros(nNeurons, equilibriumLength)+ initialInhibitionCurrent  I];
    
end
gD = 0;
g = 0;
gLd = 0;
addNoise=0;    
initialization

% creates folders if not exist
if addNoise
    noise = addNoiseFunc(equilibriumLength+lengthTimeRange, nNeurons, dt, plotflagOU);
    appendFilename = "_withNoise";
else
    noise = zeros(nNeurons,equilibriumLength+lengthTimeRange);
    appendFilename = "_withoutNoise";
end
Ca_high = 1.5;
ap = nan(nNeurons, 1); 
ap(:, 1) = 1; 
timeRange_ = [1:dt:1000, timeRange];
for iNeuron = 1:nNeurons
    ApCount = 0;
    clear girk
    for iTime=1:length(I)-1
        
        mInfCa(iNeuron,iTime) = 1./(1 + exp(-(vSoma(iNeuron,iTime)+Vref + 55)./9));     
        % Spike generating current
        iNa(iNeuron,iTime)  = gNa.*(mGate(iNeuron,iTime).^3).*hGate(iNeuron,iTime).*(vSoma(iNeuron,iTime) - vNa);
        iK(iNeuron,iTime)   = gK.* (nGate(iNeuron,iTime).^4) .*(vSoma(iNeuron,iTime) - vK);
        iL(iNeuron,iTime)   = gL.*(vSoma(iNeuron,iTime) -vL);                                               % leak current
        iP(iNeuron,iTime)   = gP.*(pGate(iNeuron,iTime).^2) .*(vSoma(iNeuron,iTime) - vNa);                       % a slow persistent sodium current
        iAhp(iNeuron,iTime) = gAhp.*(Ca(iNeuron,iTime)./(Ca(iNeuron,iTime) + 1)).*(vSoma(iNeuron,iTime) - vK);          % afterhyperpolarization current
        iCa(iNeuron,iTime)  = gCa.*(mInfCa(iNeuron,iTime)).^2.* yGate(iNeuron,iTime).*(vSoma(iNeuron,iTime) - vCa);     % calcium current

        % The membrane potential Soma
        dVS = (I(iNeuron,iTime) - iNa(iNeuron,iTime) - iK(iNeuron,iTime) - iL(iNeuron,iTime) - iCa(iNeuron,iTime) - iP(iNeuron,iTime) - iAhp(iNeuron,iTime)...
            - gD.*(vSoma(iNeuron,iTime) - vDendrite(iNeuron,iTime)) - iAlpha2SomatoSomatic(iNeuron,iTime) + noise(iNeuron, iTime)).*dt./C;
         assert(sum(isnan(dVS))==0,"Nan found in soma")
        vSoma(iNeuron,iTime + 1) = vSoma(iNeuron,iTime)+ dVS;

        if or(addGapJunction,allowgap)     
                 gapJunctionCurrent(iNeuron,iTime) = (sum(g.*((vDendrite(iNeuron,iTime) - vDendrite(iNeuron,iTime)') .* connectivityDendriteGapJunction),2));
        else
            gapJunctionCurrent(iNeuron,iTime) = 0;
        end

         % The membrane potential Dendrite
         dVD = ((-gLd.*(vDendrite(iNeuron,iTime) - vLd)) - gD.*(vDendrite(iNeuron,iTime) - vSoma(iNeuron,iTime))- gapJunctionCurrent(iNeuron,iTime)).*dt./C;
         vDendrite(iNeuron,iTime+1) = vDendrite(iNeuron,iTime) + dVD;        

         %pick action potential
        if iTime+1> equilibriumLength        
           gRect(iNeuron,iTime+1) = 0.2./(1+exp(0.05.*(vSoma(iNeuron,iTime+1)-vK)));
           f = ((tauFast/tauSlow)^(tauFast/(tauSlow-tauFast)) - (tauFast/tauSlow)^(tauSlow/(tauSlow-tauFast)))^-1;
 
         if vSoma(iNeuron,iTime)<0 && vSoma(iNeuron,iTime+1)>0 
            ap(iNeuron, ApCount+1) = timeRange_(iTime);
            ApCount = ApCount+1; 
            Ca_ap(iNeuron, ApCount) = Ca(iNeuron, iTime);
            
         end
         if ApCount~=0
            calciumDependence(iNeuron, 1:ApCount) = (2.* Ca_ap(iNeuron, 1:ApCount).^k)./(Ca_high^k + Ca_ap(iNeuron, 1:ApCount).^k); 
         else
             calciumDependence(iNeuron, 1:ApCount) = 0; 
         end
            time = timeRange_(iTime);
             
            % calculate slow and fast
            fast(1:ApCount, iTime)  = exp(-(time-ap(iNeuron,1:ApCount)')./tauFast);
            slow(1:ApCount, iTime) = exp(-(time-ap(iNeuron,1:ApCount)')./tauSlow);  
            girk(1:ApCount, iTime+1) = (slow(1:ApCount, iTime)-fast(1:ApCount, iTime)).* calciumDependence(iNeuron, 1:ApCount)';
           iAlpha2SomatoSomatic(iNeuron,iTime+1) = sum(girk(1:ApCount,iTime+1), 1) .* gRect(iNeuron,iTime+1).*(vSoma(iNeuron,iTime+1) - vK).*f * 5; %somatoSomaticConnectivity(2,1);
          
        end

        % Gating variable m
        mGate(iNeuron,iTime+1) = update_m(vSoma(iNeuron,iTime+1)+Vref, mGate(iNeuron,iTime), dt, 0, 0);

        % Gating variable n
        nGate(iNeuron,iTime+1) = update_n(vSoma(iNeuron,iTime+1)+Vref, nGate(iNeuron,iTime), dt, 0, 0);

        % Gating variable h
        hGate(iNeuron,iTime+1) = update_h(vSoma(iNeuron,iTime+1)+Vref, hGate(iNeuron,iTime), dt, 0, 0);

        % Gating variable p for a slow persistent sodium current
        pGate(iNeuron,iTime+1) = update_p(vSoma(iNeuron,iTime+1)+Vref, pGate(iNeuron,iTime), dt,0, 0);

        % Calcium update ca
        Ca(iNeuron,iTime+1) = update_ca(vSoma(iNeuron,iTime+1)+Vref,Ca(iNeuron,iTime),dt, vCa, mCa, 0, 0);

        % Gating variable y
        yGate(iNeuron,iTime+1) = update_y(vSoma(iNeuron,iTime+1)+Vref, yGate(iNeuron,iTime), dt,0, 0, sign_y);

    end
    if stepInjection
     StoreGirk{iNeuron} =  girk(:, :);
     if iNeuron==1
         girkAnalysis1 =  girk(:, :);
     end
     if iNeuron==2
         girkAnalysis2 =  girk(:, :);
     end
    end
end

vSomaAnalysis = vSoma(:, equilibriumLength+1:end);
[spiketrain,spikeTime,frequencySoma, fi_SomaStart,fi_SomaMean, fi_SomaStable,SpikeTimeInterval, numSpikes]...
    = analyseApFrequency(nNeurons,timeRange, vSomaAnalysis, dt);
if stepInjection
    girkAnalysis1 = girkAnalysis1(:, equilibriumLength+1:end);
    girkAnalysis2 = girkAnalysis2(:, equilibriumLength+1:end);
    PlotSelfInhibitionGirkComparision; 
    name = "Images/SelfInhibitionGirkComparision"+ appendFilename+ ".pdf";
    savePlot(name,f)
else
    plotFIcurve
    title('\textbf {Simulated Neuron(SI) FI Curve}', 'Interpreter', 'latex')
    name = "Images/FISomaWithSelfInhibition"+ appendFilename+ ".pdf";
    savePlot(name,f1)
end   

