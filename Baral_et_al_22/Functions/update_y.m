function new_y = update_y(V_S,y,dt, init,alvaraz, sign_y) 
    y_inf_V = 1./(1 + (exp(sign_y.*(V_S + 77)./5))); 
    tau_y_V = 20 + 100./(1 + exp((V_S + 76)./3));
    if init
       new_y =  y_inf_V;
    else
        if alvaraz
            dy = (0.75.*(y_inf_V - y)./(tau_y_V)).*dt;
            new_y = y + dy;
        else
            new_y = y_inf_V+(y-y_inf_V).*exp(-dt./tau_y_V);
        end
    end
end

 