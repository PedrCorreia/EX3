%% Q4
clear; close all; clc;
% There are many functions for designing both FIR filters and IIR filters. The desired amplification, 
% cutoff frequencies and filter order is given to the routines, and the output is the filter coefficients. One of
% these is the function firpm in Matlab (scipy.signal.remez in Python), that designs linear phase
% FIR filters. Use this routine to design a low-pass FIR filter with a pass band up to 500 Hz and a stop
% band after 570 Hz. Use a sampling frequency of 2000 Hz and design a filter with an order that you
% determine to obtain a stop-band attenuation of 45 dB. Make a procedure that inputs all the parameters
% and plots the resulting transfer function with amplification in dB. Which order is necessary?

function [b, N] = design_lowpass_fir(n, fs, fp, fst, atten)
    % DESIGN_LOWPASS_FIR designs a linear phase FIR low-pass filter
    % using the Parks-McClellan (firpm) method.
    %
    % Inputs:
    %   n     - Filter order
    %   fs    - Sampling frequency (Hz)
    %   fp    - Passband edge (Hz)
    %   fst   - Stopband start (Hz)
    %   atten - Desired stopband attenuation (dB)
    %
    % Outputs:
    %   b - Filter coefficients
    %   N - Filter order

    % Normalize frequencies to Nyquist
    nyq = fs/2;
    f = [0 fp fst nyq] / nyq;
    a = [1 1 0 0];  % Desired amplitudes at each frequency edge

    fprintf('Filter order: %d\n', n);

    % Design the FIR filter
    b = firpm(n, f, a);
    N = n;

    % Compute and plot the frequency response
    [h, w] = freqz(b, 1, 2048, fs);

    figure;
    plot(w, 20*log10(abs(h)));
    grid on;
    xlabel('Frequency (Hz)');
    ylabel('Magnitude (dB)');
    title(sprintf('Low-pass FIR filter (Order = %d)', N+1));
    axis([0 fs/2 -100 5]);
end

%%

n= 64; % as was defined in Q3 

[b, N] = design_lowpass_fir(n, 2000, 500, 570, 45);


%% 
