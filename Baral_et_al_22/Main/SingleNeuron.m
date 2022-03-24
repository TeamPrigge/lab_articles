% fresh workspace
clear all; clc;
% close all;

addpath('../initialization/', '../Util/', '../Functions/')
addpath('../plotCalls/', '../plotCalls/Images/')
% add all the paths
flags; % Sets flags
saveGraph = 0; 
addNoise = 0;

% ONLY ONE OF THESES FLAGS CAN BE SET
% **********************************
singleNeuronProperties =0; 
addGapJunction = 0; 
fourAnd20HzSpikeStudy =1;
flagCheck = singleNeuronProperties+ addGapJunction+fourAnd20HzSpikeStudy; 
assert(flagCheck==1,"One(Only one) flag (singleNeuronProperties or addGapJunction or  fourAnd20HzSpikeStudy) must be set to 1");
% **********************************

parameters; % loads parameters to run the simulation; defined by us; 

% time factors
dt= 0.01;
timeRange= 1:dt:1000; % ms%
lengthTimeRange = length(timeRange);

initialInhibitionCurrent = -12; % suppress firing before stimulation
equilibriumLength = length(1:dt:1000); % achieve equilibrium in given time; 

% Current Injection
stepInjection = 0;

if singleNeuronProperties
    gD = 0;
    g = 0;
    gLd = 0;
    I_all = -20:10:280;% -20:20:250;    
    if isempty(find(I_all==0, 1)) 
        I_all = [0 I_all];
        I_all = sort(I_all);
    end
    nNeurons = length(I_all);
    
    if stepInjection
        I = zeros(nNeurons, lengthTimeRange);
        I(: , 260/dt:560/dt) =I(: , 260/dt:560/dt)+ I_all';
        I = [zeros(nNeurons, equilibriumLength)+initialInhibitionCurrent  I];
    else
        I = [zeros(nNeurons, equilibriumLength)+initialInhibitionCurrent  zeros(nNeurons, lengthTimeRange)+I_all'];
    end
    
elseif addGapJunction
    nNeurons = 2; 
    I_all = [10, -10];
    I = [zeros(nNeurons, equilibriumLength)+initialInhibitionCurrent  zeros(nNeurons, lengthTimeRange)+I_all'];

elseif fourAnd20HzSpikeStudy
    nNeurons = 2; 
    I_all = [1, 270];
    I = [zeros(nNeurons, equilibriumLength)+initialInhibitionCurrent  zeros(nNeurons, lengthTimeRange)+I_all'];    
end
    
initialization

if addNoise
    noise = addNoiseFunc(lengthTimeRange, nNeurons, dt, plotflagOU);
    appendFilename = "_withNoise";
    
    noise = [zeros(nNeurons,equilibriumLength) noise];
else
    noise = zeros(nNeurons,equilibriumLength+lengthTimeRange);
    appendFilename = "_withoutNoise";
end

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
            - gD.*(vSoma(:,iTime) - vDendrite(:,iTime)) + noise(:, iTime)).*dt./C;
         assert(sum(isnan(dVS))==0,"Nan found in soma")
        vSoma(:,iTime + 1) = vSoma(:,iTime)+ dVS;
        
        if addGapJunction     
%           gapJunctionCurrent(:,iTime) = (sum(g.*((vDendrite(:,iTime) - vDendrite(:,iTime)') .* connectivityDendriteGapJunction),2));
            dVD(1,1) = ((-gLd.*(vDendrite(1,iTime) - vLd)) - gD.*(vDendrite(1,iTime) - vSoma(1,iTime+1))- 0*(vDendrite(1,iTime) - vDendrite(2,iTime))).*dt./C;
            dVD(2,1) = ((-gLd.*(vDendrite(2,iTime) - vLd)) - gD.*(vDendrite(2,iTime) - vSoma(2,iTime+1))- 0.2*(vDendrite(2,iTime) - vDendrite(1,iTime))).*dt./C;
            vDendrite(:,iTime+1) = vDendrite(:,iTime) + dVD; 
        else
            gapJunctionCurrent(:,iTime) = 0;
         dVD = ((-gLd.*(vDendrite(:,iTime) - vLd)) - gD.*(vDendrite(:,iTime) - vSoma(:,iTime+1))- gapJunctionCurrent(:,iTime)).*dt./C;
         vDendrite(:,iTime+1) = vDendrite(:,iTime) + dVD;
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
CaAnalysis = Ca(:, equilibriumLength+1:end);
vDendriteAnalysis = vDendrite(:, equilibriumLength+1:end);
% gapJunctionCurrentAnalysis = gapJunctionCurrent(:, equilibriumLength:end);
[spiketrain,spikeTime,frequencySoma, fi_SomaStart,fi_SomaMean, fi_SomaStable,SpikeTimeInterval, numSpikes]...
    = analyseApFrequency(nNeurons,timeRange, vSomaAnalysis, dt);
%%
if singleNeuronProperties 
    plotFIcurve;
    PlotClaciumVsFrequency;
    title('\textbf{FI Curve}', 'Interpreter', 'latex')
    if saveGraph
        name = "Images/testSimulation/FISimulation"+ appendFilename+ ".pdf";      
        savePlot(name,f2)        
        name = "Images\CaVsF.pdf";
        savePlot(name,f2)
    end
end

if addGapJunction
    plotGapJunctionInfluence; 
     if saveGraph
        name = "Images/testSimulation/GapJunSpikeShapeSomaAndDendrite"+ appendFilename+ ".pdf";
        savePlot(name,f)
     end
end

if fourAnd20HzSpikeStudy
    Plot4and20Hz; 
     if saveGraph
         name1 = "Images/Calciumat4and20hz"+ appendFilename+ ".pdf";
        savePlot(name1,f1)
         
        name2 = "Images/Calcium4and20hzCavsMembranePlot"+ appendFilename+ ".pdf";
        savePlot(name2,f2)
     end
end