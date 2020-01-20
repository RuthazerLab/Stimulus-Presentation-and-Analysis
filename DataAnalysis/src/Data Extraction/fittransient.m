function [fitresult, gof] = fitransient(V,I);
% [fitresult, gof] = FitBoltzman(V,I,Vhalf,K0,ERev,Gmx) fits (V,I) with the function
% 	i = (v-ERev)/(Gmx*(1+exp((v-v50)/k)))
% fitresult is ordered as [ERev Gmx k v50]


[xData, yData] = prepareCurveData( V, I );

% Set up fittype and options.
ft = fittype( 'A*(1-exp(-(v-v1)/k1))/(1+exp((v-v2)/k2))', 'independent', 'v', 'dependent', 'y' );
opts = fitoptions( 'Method', 'NonlinearLeastSquares' );
opts.Algorithm = 'Trust-Region';
opts.DiffMaxChange = 100;
opts.Display = 'Off';
opts.MaxFunEvals = 600;
opts.MaxIter = 400;
opts.StartPoint = [0.1,5,5,1,10];
opts.Lower = [-Inf,0,0,-Inf,0];
opts.Upper = [Inf,Inf,Inf,26,26];
opts.TolFun = 1e-6;


% Fit model to data.
[fitresult, gof] = fit( xData, yData, ft, opts );


