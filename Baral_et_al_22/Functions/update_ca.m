function new_ca = update_ca(V_S,Ca,dt, V_Ca,mCa, init, alvaraz)
%Alverz
if init
   new_ca =  (-mCa ./ 132.6).*(V_S- V_Ca)./ (1+exp(-(V_S +25)./2.5));
else
    if alvaraz
        d_Ca = ((-mCa ./ 132.6).*(V_S- V_Ca)./ (1+exp(-(V_S +25)./2.5)) - (Ca./80)).*dt;
        new_ca = Ca + d_Ca;
    else
    
        ca_infty = (-mCa ./ 132.6).*(V_S- V_Ca)./ (1+exp(-(V_S +25)./2.5));
        new_ca = ca_infty+(Ca-ca_infty).*exp(-dt./80);
    end
    
end
% braun
%         ca_inf = -0.002 .* k_Ca .*(V_S- V_Ca)./(1+exp(-(V_S +25)./2.5));
%         d_Ca =(-Ca./80 + ca_inf + 0.0027.*I_Ca).*dt;

%grestner
%     d_Ca = -tau^-1*Ca+phi+I_ca
end