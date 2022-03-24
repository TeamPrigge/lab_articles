
kCa = 2;
mCa  = 40;

Vref =0;
%Initial Voltage
V0_ini =  -65 - Vref; 

% Conductances
gL   =   1;    % return to 1.0 % 0.5 my value % Alvarez value 1 µS/mm^2
gNa  = 500;    % µS/mm^2
gK   =  50;    % µS/mm^2

gCa  =   5.5;    % 7  my value % Alvarez value 2.5 µS/mm^2
gAhp =   10;    % 10 my value  % Alvarez value 2 µS/mm^2  1.8
gP   =   1;    % 0.6 µS/mm^2  % Alvarez value 0.6 µS/mm^2
 
gLd = 0.1;    % leak on dendrite 0.01;
gD = 0.3;     %0.3
g = 10;   % 0.025, 0.08  [Gap junction Connection]

% Reversal Potentials
vL   = -65 - Vref; % mV
vNa  =  30 - Vref; % 30 mV my value % Alvarez value 50 mV
vK   = -110 - Vref; % 80 mV mu value % Alavarez value -110 mV
vCa  = 120 - Vref; % 80 mV my value % Alvarez value 120 mV
vLd  = -67 - Vref;  

% Capacitance of a cell
C = 10; %muF/mm^2



sign_y = 1;

% Alpha2 channel properties
tauFast = 300; 
tauSlow = 350;
k =1; 
Ca_high= 2;
