function L = ivmEPLogLikelihood(model, x, y);

% IVMEPLOGLIKELIHOOD Return the EP approximation to the log-likelihood for the IVM (as given in Kuss & Rasmussen).

% IVM

if nargin < 3
  % This implies evaluate for the training data.
  mu = model.mu;
  varsigma = model.varSigma;
  y = model.y;
else
  [mu, varsigma] = ivmPosteriorMeanVar(model, x);
end

if model.noise.spherical
else
  varSigSlash = ...
      1./(1./model.varSigma(model.I, :) - model.beta(model.I, :));
  muSlash = ...
      (model.mu(model.I, :)./model.varSigma(model.I, :) ...
       - model.m(model.I, :).*model.beta(model.I, :)).*varSigSlash;
  
  L = 0.5*(sum(sum(log(varSigSlash+1./model.beta(model.I, :))))...
              + sum(sum((model.m(model.I, :) - muSlash)...
                        .*(model.m(model.I, :)-muSlash) ...
                        ./((varSigSlash+1./model.beta(model.I, :))))));
end
L = L + noiseLogLikelihood(model.noise, muSlash, varSigSlash, ...
                           y(model.I, :));

L = L + ivmApproxLogLikelihood(model);

% check if there is a prior over kernel parameters
if isfield(model.kern, 'priors')
  fhandle = str2func([model.kern.type 'KernExpandParams']);
  params = fhandle(model.kern);
  for i = 1:length(model.kern.priors)
    index = model.kern.priors(i).index;
    L = L + priorLogProb(model.kern.priors(i), params(index));
  end
end