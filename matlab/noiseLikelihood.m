function L = noiseLikelihood(noise, mu, varsigma, y);

% NOISELIKELIHOOD Return the likelihood for each point under the noise model.

L = feval([noise.type 'Likelihood'], noise, mu, varsigma, y);