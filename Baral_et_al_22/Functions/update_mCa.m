function new_mCa = update_mCa(V_S,mCa,Ca,dt)
alpha = 2.5.*10.^5 .*Ca.*exp(V_S./24);
beta = 0.1.*exp(-V_S./24);

dmCa = (alpha.*mCa - beta.*(1-mCa)).*dt;
    new_mCa = mCa + dmCa;
end

 