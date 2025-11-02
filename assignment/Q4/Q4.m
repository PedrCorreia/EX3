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
    %   n     - Filter order - 1 
    %   fs    - Sampling frequency (Hz)
    %   fp    - Passband edge (Hz)
    %   fst   - Stopband start (Hz)
    %   atten - Desired stopband attenuation (dB)
    %
    % Outputs:
    %   b - Filter coefficients
    %   N - Filter order
    
    % Set the order
    N = n + 1;

    % Normalize frequencies to Nyquist
    nyq = fs/2;
    f = [0 fp fst nyq] / nyq;
    a = [1 1 0 0];  % Desired amplitudes at each frequency edge

    fprintf('Filter order: %d\n', N);

    % Design the FIR filter using Parks-McClellan
    b = firpm(n, f, a);

    % Compute the full two-sided frequency response
    M = 2048;                            % number of frequency samples
    [H, f_norm] = transfer(b, 1, M);     % normalized frequencies [-0.5, 0.5]
    f_Hz = f_norm * fs;                  % convert to Hz

    % Plot magnitude (linear)
    subplot(3,1,1)
    plot(f_Hz, abs(H), 'LineWidth', 2);
    xlabel('Frequency (Hz)', 'FontSize', 20);
    ylabel('|H(f)|', 'FontSize', 20);
    title(sprintf('Low-pass FIR filter (Order = %d)', N), 'FontSize', 20);
    grid on;

    % Plot magnitude in dB
    subplot(3,1,2)
    plot(f_Hz, 20*log10(abs(H)), 'LineWidth', 2);
    xlabel('Frequency (Hz)', 'FontSize', 20);
    ylabel('Magnitude (dB)', 'FontSize', 20);
    title('Two-sided frequency response', 'FontSize', 20);
    axis([-fs/2 fs/2 -100 5]);
    grid on;

    % Plot phase
    subplot(3,1,3)
    plot(f_Hz, angle(H), 'LineWidth', 2);
    xlabel('Frequency (Hz)', 'FontSize', 20);
    ylabel('Phase (radians)', 'FontSize', 20);
    title('Phase Response', 'FontSize', 20);
    grid on;
end

%%

n= 64; % as was defined in Q3 

[b, N] = design_lowpass_fir(n, 2000, 500, 570, 45);


%% 

figure;
stem(0:length(b)-1, b, 'filled');
xlabel('Sample index n', 'FontSize', 20);
ylabel('Amplitude', 'FontSize', 20);
title('Impulse Response of the FIR Filter', 'FontSize', 22);
grid on;


%%

function [H, f] = transfer(B, A, M)
%TRANSFER Compute the complex transfer function H(e^{j2πf}) of an IIR filter.
%   [H, f] = transfer(B, A, M) returns the complex frequency response H and
%   the corresponding normalized frequency vector f in [-1/2, 1/2], using M points.
%
%   Inputs:
%     B - row/column vector of numerator coefficients
%     A - row/column vector of denominator coefficients
%     M - number of frequency samples (positive integer)
%
%   Outputs:
%     H - complex frequency response (Mx1)
%     f - normalized frequencies in [-1/2, 1/2] (Mx1)
%
%   Notes:
%     - Frequencies are normalized (cycles/sample). Multiply by fs to get Hz.
%     - This evaluates H(z) on the unit circle with z = e^{j2πf}.

    narginchk(3,3);
    validateattributes(B, {'double','single'}, {'vector','nonempty'}, mfilename, 'B', 1);
    validateattributes(A, {'double','single'}, {'vector','nonempty'}, mfilename, 'A', 2);
    validateattributes(M, {'numeric'}, {'scalar','integer','>=',2}, mfilename, 'M', 3);

    % Ensure column vectors
    B = B(:);
    A = A(:);

    % Frequency vector in [-1/2, 1/2]
    % linspace from -M/2 to M/2 mapped by 1/M gives exactly [-1/2, 1/2]
    f = linspace(-M/2, M/2, M).' / M;   % Mx1

    % Build Vandermonde-like matrices to evaluate sums efficiently:
    % For each frequency f(m), evaluate sum_k B(k)*exp(-j*2*pi*f(m)*kIdx(k))
    kB = (0:numel(B)-1);                      % 1xNb
    kA = (0:numel(A)-1);                      % 1xNa
    EB = exp(-1j*2*pi * f * kB);              % MxNb
    EA = exp(-1j*2*pi * f * kA);              % MxNa

    % Numerator and denominator
    Num = EB * B;                              % Mx1
    Den = EA * A;                              % Mx1

    % Guard against division by ~0 (very sharp notches)
    tiny = 1e-15;
    Den = Den + (abs(Den) < tiny).*tiny;

    H = Num ./ Den;                            % Mx1
end