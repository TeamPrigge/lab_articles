lengthTimeRange_ =length(timeRange)+equilibriumLength; 

vSoma = nan(nNeurons, lengthTimeRange_);
vDendrite = nan(nNeurons, lengthTimeRange_);

mGate = nan(nNeurons, lengthTimeRange_);
nGate = nan(nNeurons, lengthTimeRange_);
hGate = nan(nNeurons, lengthTimeRange_);
pGate = nan(nNeurons, lengthTimeRange_);
yGate = nan(nNeurons, lengthTimeRange_);
yGateD = nan(nNeurons, lengthTimeRange_);

iNa = nan(nNeurons, lengthTimeRange_);
iK = nan(nNeurons, lengthTimeRange_);
iL = nan(nNeurons, lengthTimeRange_);
iP = nan(nNeurons, lengthTimeRange_);
iAhp = nan(nNeurons, lengthTimeRange_);
iAhpD = nan(nNeurons, lengthTimeRange_);

mInfCa = nan(nNeurons, lengthTimeRange_);
iCa = nan(nNeurons, lengthTimeRange_);
iCaD = nan(nNeurons, lengthTimeRange_);
gRect = nan(nNeurons, lengthTimeRange);


iAlpha2SomatoSomatic = zeros(nNeurons, lengthTimeRange_);
iAlpha2DendroDemdratic= zeros(nNeurons, lengthTimeRange_);
% Ca_ap(1,1) = 0;
% Ca_apD(1,1) = 0;


% connectivityDendriteGapJunction = ones(nNeurons); %Can be redefined diagonal is always one as it gets subtracted from self and becomes zero.  %


% initial value begin
vSoma(:,1)= -70+Vref - zeros(nNeurons,1);
random_ = normrnd(0, 1, [nNeurons, 1]);
vDendrite(:,1)= -50+Vref+random_;
mGate(:,1) = update_m(vSoma(:,1), 0, dt, 1, 0); %V_S, m, dt, init,alvaraz%
nGate(:,1) = update_n(vSoma(:,1), 0, dt, 1, 0); 
hGate(:,1) = update_h(vSoma(:,1), 0, dt, 1, 0); 
pGate(:,1) = update_p(vSoma(:,1), 0, dt, 1, 0);  
yGate(:,1) = update_y(vSoma(:,1), 0, dt, 1, 0, sign_y); 
yGateD(:,1) = update_y(vDendrite(:,1), 0, dt, 1, 0, sign_y); 

Ca(:,1)    = update_ca(vSoma(:,1),0, dt, vCa, mCa, 1, 0); %micromolar
CaD(:,1)    = update_ca(vDendrite(:,1),0, dt, vCa, mCa, 1, 0); %micromolar
 
