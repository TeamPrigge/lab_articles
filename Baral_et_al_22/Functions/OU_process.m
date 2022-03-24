function  s_ji = OU_process( mu_s, sigma_s, tau_s, Tmax, Npoints, Nreal, plotflag)

% generates multiple realizations of time-varying signals
% using a continuously stochastic Ornstein-Uhlenbeck process 

% mu_s mean of signal
% sigma_s^2 variance of signal
% tau_s characteristic time of signal
% Tmax duration of signal
% Npoints number of successive time samples
% Nreal number of realizations
% plotflag true ot false; shows or hides plot

% plotflag = 1;
fs       = 12;

% s_ji(Nreal, Npoints) output array

t_i = single(linspace(0,Tmax,Npoints+1));

dt  = Tmax / Npoints;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% OU process, see Section 10: bioRxiv_ML_FI_derivation.tex
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
 
% increments

e1dt  = exp(-dt/tau_s);
e2dt  = sigma_s * sqrt( 1 - exp(-2*dt/tau_s) );

% allocate and initialize

u_ji      = single(nan( Nreal, Npoints+1 ));     % allocation
u_j0      = single(normrnd( 0, sigma_s, Nreal, 1 ));  % initial condition, select from from steady-state distribution
u_ji(:,1) = u_j0;

% random numbers
xi_ji =  single(normrnd( 0, 1, Nreal, Npoints));  

for i=1:Npoints
    u_j0 = u_j0 * e1dt +  e2dt * xi_ji(:,i);
    u_ji(:,i+1) = u_j0;
end

% shift to mean
s_ji = single(mu_s + u_ji);


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% visualize
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
fontSize = 30;
if plotflag    
    f = figure();
    subplot(2,1,1);
    ax = gca();
    hold on;
    plot( t_i, s_ji(1,:), 'r.', 'LineWidth', 2 );
    
    plot( t_i, s_ji(2,:), 'b.', 'LineWidth', 2 );
    hold off;
    
%     hold off;
%     h = legend('numerical','theoretical','independent','baseline');
%     set(h,'Location','NorthWest','FontSize', fs);
    
%     set(gca, 'PlotBoxAspectRatio', [5 1 1] );
    ax.PlotBoxAspectRatio =[5 1 1];
    ax.LineWidth = 2;
    ax.FontSize = fontSize;
    ax.FontWeight = 'Bold';
    ax.TickLabelInterpreter = 'latex';
    xlabel('\textbf {TR}', 'Interpreter', 'latex' );
    ylabel('\textbf {s(t)}', 'Interpreter', 'latex' );
    title('\textbf {2 realizations}', 'Interpreter', 'latex');
    
    xk = linspace(-3*sigma_s, 3*sigma_s, 101 );
    dx = xk(2)- xk(1);
    pk = hist( s_ji(:)-mu_s, xk ) / ( length(s_ji(:) ) * dx );
    
    subplot(2,2,3);
    ax = gca()
    hold on;
    plot( xk-mu_s, pk, 'r.' );
    plot( xk-mu_s, normpdf( xk, 0, sigma_s ), 'b.' ,'LineWidth', 2);
    hold off;
        axis square
    ax.LineWidth = 2;
    ax.FontSize = fontSize;
    ax.TickLabelInterpreter = 'latex';
    ax.FontWeight = 'Bold';
    title('\textbf {density}', 'Interpreter', 'latex');

    
    
    taumax = 1*tau_s;
    dk = 0:ceil(taumax/dt);
    tk = [-fliplr(dk) dk(2:end)];
    Ck = zeros(1,length(tk));
    for k = 1 : length(dk)
        s_ji_0 = s_ji(:,1:end-dk(k));
        s_ji_1 = s_ji(:,1+dk(k):end);
        
        C      = mean( mean( s_ji_0 .* s_ji_1 ) );
        
        Ck(length(dk)+dk(k)) = C;
        Ck(length(dk)-dk(k)) = C;
    end
    
    subplot(2,2,4);
    
    hold on;
    ax=gca();
    plot( dt*tk, Ck, 'r.','LineWidth', 2 );
    plot( dt*tk, sigma_s^2 * exp(-abs(tk)*dt/tau_s), 'b.' ,'LineWidth', 2);
    hold off;
    ax.LineWidth = 2;
    ax.FontSize = fontSize;
    ax.FontWeight = 'Bold';
    ax.TickLabelInterpreter = 'latex';
    title('\textbf {autocorrelation}', 'Interpreter', 'latex');
    axis square
    print('OUprocess', '-depsc2');
    name_eps = 'OUprocess.eps';
    name = 'OUprocess.pdf';
    print(name_eps,'-dpdf','-fillpage');
    savePlot(name,f)
end
return;


