function new_p = update_p(V_S,p,dt, init, alvaraz)
    alpha_p_V = 0.0001.*(V_S + 30)./(1 - exp(-0.05.*(V_S + 30)));
    beta_p_V = 0.004.*exp(-(V_S + 60)./18);
    if init
       new_p = alpha_p_V./(alpha_p_V+beta_p_V);
    else 
        if alvaraz
            dp = ((alpha_p_V).*(1-p) - beta_p_V .* p).*dt;
            new_p = p + dp;
        else        
            p_infty =  alpha_p_V./(alpha_p_V + beta_p_V);
            tau_p = 1./(alpha_p_V + beta_p_V);
            new_p = p_infty+(p-p_infty).*exp(-dt./tau_p);
        end
    end
end

