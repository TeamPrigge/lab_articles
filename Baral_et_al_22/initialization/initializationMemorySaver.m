lengthTimeRange_ =length(timeRange)+equilibriumLength; 

vSoma = single(nan(nNeurons, 2));
vDendrite =  single(nan(nNeurons, 2));

iAlpha2SomatoSomatic = single(zeros(nNeurons, 2));

% initial value begin
vSoma(:,1)= -70+Vref - zeros(nNeurons,1);
random_ = normrnd(0, 1, [nNeurons, 1]);
vDendrite(:,1)= -50+Vref+random_;
mGate = update_m(vSoma(:,1), 0, dt, 1, 0); %V_S, m, dt, init,alvaraz%
nGate = update_n(vSoma(:,1), 0, dt, 1, 0); 
hGate = update_h(vSoma(:,1), 0, dt, 1, 0); 
pGate = update_p(vSoma(:,1), 0, dt, 1, 0);  
yGate = update_y(vSoma(:,1), 0, dt, 1, 0, sign_y); 
yGateD = update_y(vDendrite(:,1), 0, dt, 1, 0, sign_y); 

Ca    = update_ca(vSoma(:,1),0, dt, vCa, mCa, 1, 0); %micromolar
 
