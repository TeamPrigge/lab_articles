function [new_n]= update_n(V_S,n,dt, init, alvaraz)

    if V_S + 34 ==0
        alpha_n_V =3;
    else
       alpha_n_V =  3* 0.01.*(V_S + 34)./(1 - exp(-0.2.*(V_S + 34)));
    end
        beta_n_V = 3* 0.125.* exp(-(V_S + 40)./80);
    
    if init
        new_n = alpha_n_V./(alpha_n_V + beta_n_V);
    else
       if alvaraz
           dn = ((alpha_n_V).*(1-n) - beta_n_V .* n).*dt; 
            new_n = n + dn;
       else 
           n_infty =  alpha_n_V./(alpha_n_V + beta_n_V);
           tau_n = 1./(alpha_n_V + beta_n_V);
           new_n = n_infty+(n-n_infty).*exp(-dt./tau_n);
       end
    end
end

