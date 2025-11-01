%% Q4

% There are many functions for designing both FIR filters and IIR filters. The desired amplification, 
% cutoff frequencies and filter order is given to the routines, and the output is the filter coefficients. One of
% these is the function firpm in Matlab (scipy.signal.remez in Python), that designs linear phase
% FIR filters. Use this routine to design a low-pass FIR filter with a pass band up to 500 Hz and a stop
% band after 570 Hz. Use a sampling frequency of 2000 Hz and design a filter with an order that you
% determine to obtain a stop-band attenuation of 45 dB. Make a procedure that inputs all the parameters
% and plots the resulting transfer function with amplification in dB. Which order is necessary?