function noise = addNoiseFunc(lengthTimeRange, nNeurons, dt, plotflagOU)
    mu_s = 0.9;
    sigma_s = 18;
    tau_s = dt;
    Tmax = 0.5; 
    Npoints = lengthTimeRange;
    Nrealizations= nNeurons;
    noise = (OU_process( mu_s, sigma_s, tau_s, Tmax, Npoints, Nrealizations, plotflagOU));
end

