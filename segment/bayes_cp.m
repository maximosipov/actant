function ts = bayes_cp(ts_in)
% BAYES_СP Bayesian online changepoints detection
%
% Description:
%   Demonstration of online detection of a change in 1d Gaussian parameters
%   by Ryan Prescott Adams.
%
%   Implementation of:
%   @TECHREPORT{ adams-mackay-2007,
%       AUTHOR = {Ryan Prescott Adams and David J.C. MacKay},
%       TITLE  = "{B}ayesian Online Changepoint Detection",
%       INSTITUTION = "University of Cambridge",
%       ADDRESS = "Cambridge, UK",
%       YEAR = "2007",
%       NOTE = "arXiv:0710.3742v1 [stat.ML]"
%   }
%
%   Thanks to Ryan Turner and Miguel Lazaro Gredilla for pointing out bugs
%   in this.
%
% Arguments:
%   data - Input data timeseries
%
% Results (all optional):
%   ts - Timeseries of data segments
%

X = ts_in.Data;
T = length(X);

ts = timeseries('Segments');
ts.DataInfo.Unit = 'days';
ts.TimeInfo.Units = 'days';
ts.TimeInfo.StartDate = 'JAN-00-0000 00:00:00';

% Parameters of distributions
mu0    = 0;
kappa0 = 1;
alpha0 = 1;
beta0  = 1;

muT    = mu0;
kappaT = kappa0;
alphaT = alpha0;
betaT  = beta0;

% Matrix that holds probabilities of run lengths at every step, at t=1
% the run length is zero with 100% probability.
R = zeros([T+1 T]);
R(1,1) = 1;
maxes  = zeros([T+1 1]);

% Loop over the data
for t=1:T
    % Evaluate the predictive distribution for the new datum under each of
    % the parameters.  This is the standard thing from Bayesian inference.
    predprobs = studentpdf(X(t), muT, ...
                         betaT.*(kappaT+1)./(alphaT.*kappaT), ...
                         2 * alphaT);
    % Evaluate the hazard function for this interval.
    H = hazard([1:t]');
    % Evaluate the growth probabilities - shift the probabilities down and
    % to the right, scaled by the hazard function and the predictive
    % probabilities.
    R(2:t+1,t+1) = R(1:t,t) .* predprobs .* (1-H);
    % Evaluate the probability that there *was* a changepoint and we're
    % accumulating the mass back down at r = 0.
    R(1,t+1) = sum( R(1:t,t) .* predprobs .* H );
    % Renormalize the run length probabilities for improved numerical
    % stability.
    R(:,t+1) = R(:,t+1) ./ sum(R(:,t+1));
    % Update the parameter sets for each possible run length.
    muT0    = [ mu0    ; (kappaT.*muT + X(t)) ./ (kappaT+1) ];
    kappaT0 = [ kappa0 ; kappaT + 1 ];
    alphaT0 = [ alpha0 ; alphaT + 0.5 ];
    betaT0  = [ beta0  ; betaT + (kappaT .*(X(t)-muT).^2)./(2*(kappaT+1)) ];
    muT     = muT0;
    kappaT  = kappaT0;
    alphaT  = alphaT0;
    betaT   = betaT0;
    % Store the maximum, to plot later.
    maxes(t) = find(R(:,t)==max(R(:,t)));
end

% Ignoring transient run length changes (just go from the end)
t = length(maxes)-1;
while t > 1,
    if maxes(t)+1 < maxes(t+1),
        maxes(t) = maxes(t+1)-1;
    end
    t = t-1;
end

% Add interval to timeseries if run length decreases (may overlap)
t1 = ts_in.Time(1);
for t=2:length(maxes),
    if maxes(t) < maxes(t-1) || t == length(maxes),
        t2 = ts_in.Time(t-1);
        ts = addsample(ts, 'Data', t2, 'Time', t1);
        t1 = t2;
    end
end

if 0
    % Plot the data and we'll have a look.
    subplot(2,1,1);
    plot(ts_in.Data);
    xlim([0 length(ts_in.Data)]);
    grid;
    % Show the log smears and the maximums.
    subplot(2,1,2);
    colormap(gray());
    imagesc(-log(R));
    hold on;
    plot([1:T+1], maxes, 'r-');
    hold off;
end

% Takes time increments since the last changepoint and returns the
% probability of changepoint.
function p = hazard(r)
    lambda = 60;
	p = 1/lambda * ones(size(r));
  
% This form is taken from Kevin Murphy's lecture notes.
function p = studentpdf(x, mu, var, nu)
    c = exp(gammaln(nu/2 + 0.5) - gammaln(nu/2)) .* (nu.*pi.*var).^(-0.5);
    p = c .* (1 + (1./(nu.*var)).*(x-mu).^2).^(-(nu+1)/2);
