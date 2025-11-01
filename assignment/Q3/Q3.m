%% Q3
clear, close, clc;
% Filter a delta function signal with a length of 64 samples with the stable filter from question 1. Make
% a Fourier transform of the impulse response and compare this transfer function to the one calculated
% with your function transfer. Make plots of the transfer function with an amplification in dB. Are
% the two transfer functions exactly alike and if not, why?

%% Define the delta function
delta = zeros(1,64); % Function of length 64 
delta(1,1) = 1; % with one spike corresponding to dirac(x) 







