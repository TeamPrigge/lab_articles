function new_m = update_m(V_S,m, dt,init, alvaraz)

    % calculates alpha beta and tau
    if (V_S + 25)==0
        alpha_m_V=3; 
    else
         alpha_m_V  = 3* 0.1 .* (V_S + 25)./(1 - exp(-0.1 .*(V_S + 25)));
    end
         beta_m_V   = 3*4 .* exp(-(V_S + 50)./18);
         
         
    % if initialization is being called    
    if init
         new_m = alpha_m_V./(alpha_m_V + beta_m_V);
         
    else
        if alvaraz % if using alavarez parameters%
            dm = (1./3.*(alpha_m_V.*(1-m) - beta_m_V .* m)).*dt;
            new_m = m + dm;
            new_m = alpha_m_V./(alpha_m_V + beta_m_V);
            
        else % our updated parameters
            tau_m = 1./(alpha_m_V+beta_m_V);
            m_infty  =alpha_m_V./(alpha_m_V + beta_m_V);
            new_m = m_infty+(m-m_infty).*exp(-dt./tau_m);
        end
    end
end

