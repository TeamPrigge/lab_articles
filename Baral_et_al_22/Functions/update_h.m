function new_h = update_h(V_S,h,dt,init, alvaraz)
     alpha_h_V = 3.* 0.07.*exp(-(V_S + 40)./20);
     beta_h_V = 3.*1./(1 + exp(-0.1.*(V_S + 14)));
    if init
        new_h    = alpha_h_V./(alpha_h_V + beta_h_V);
    else
        if alvaraz
            dh = ((alpha_h_V).*(1-h) - beta_h_V .* h).*dt;
            new_h = h + dh;
        else        
            h_infty =  alpha_h_V./(alpha_h_V + beta_h_V);
            tau_h = 1./(alpha_h_V + beta_h_V);
            new_h = h_infty+(h-h_infty).*exp(-dt./tau_h);
        end
    end

%     alpha_h_V = 0.07.*exp(-(V_S + 70)./20);
%      beta_h_V = 1./(1 + exp(-0.1.*(V_S + 40)));
%     dh = (3.*(alpha_h_V).*(1-h) - beta_h_V .* h).*dt;
%     new_h = h + dh;
end

