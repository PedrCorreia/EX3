%% Q3
clear; close all; clc;
% Filter a delta function signal with a length of 64 samples with the stable filter from question 1. Make
% a Fourier transform of the impulse response and compare this transfer function to the one calculated
% with your function transfer. Make plots of the transfer function with an amplification in dB. Are
% the two transfer functions exactly alike and if not, why?

%% Define the delta function
N = 64;
n = 0:N-1;

delta = zeros(1,N); % Function of length 64 
delta(1,1) = 1; % with one spike corresponding to dirac(x) 

%% Stable Filter F1 (REPITITION FROM Q1)
close all; clc;

B1 = [0.0725 0.2200 0.4085 0.4883 0.4085 0.2200 0.0725];
A1 = [1.0000 -0.5835 1.7021 -0.8477 0.8401 -0.2823 0.0924];


% Compute impulse responses
h1 = filter(B1, A1, delta);   % Filter 1 (expected stable)
stem(n, h1)
grid on

% Stable Filter F1 Fourier transform
H1 = fftshift(fft(h1));
axis = -N/2:(N-1)/2;

figure;
plot(axis/N, abs(H1))
grid on

figure;
plot(axis/N, angle(H1))


%% 
close all; clc;
freq_axis = linspace(-0.5, 0.5, N);  % normalized frequency axis

% 1. Impulse Response
subplot(3,1,1);
stem(n, h1, 'filled', 'LineWidth', 1.2);
grid on; 
title('Impulse Response h_1[n]', 'FontWeight', 'bold', FontSize=20);
xlabel('n (samples)', FontSize=20);
ylabel('Amplitude', FontSize=20);
xlim([0 N-1]);

% 2. Magnitude Response (in dB)
subplot(3,1,2);
plot(freq_axis, abs(H1), 'LineWidth', 2);
grid on; 
title('Magnitude Response |H_1(f)|', 'FontWeight', 'bold', FontSize=20);
xlabel('Normalized Frequency (f/fs)', FontSize=20);
ylabel('Magnitude |H(f)|', FontSize=20);
ylim([-0.5 1.5]);

% 3. Phase (Angle) Response
subplot(3,1,3);
plot(freq_axis, angle(H1), 'LineWidth', 2);
grid on; 
title('Phase Response ∠H_1(f)', 'FontWeight', 'bold', FontSize=20);
xlabel('Normalized Frequency (f/fs)', FontSize=20);
ylabel('Phase (radians)', FontSize=20);

sgtitle('Filter F1: Impulse, Magnitude, and Phase Responses', 'FontWeight', 'bold', FontSize=22);



%% Impulse from transfer function
close all; clc;

M = 1000
[H1_1, f_1] = transfer(B1, A1, M);

freq_axis_M = linspace(-0.5, 0.5, M);
figure;

plot(freq_axis, 20*log10(abs(H1)/max(abs(H1))), 'LineWidth', 2); hold on;
plot(freq_axis_M+8*(1/M), 20*log10(abs(H1_1)/max(abs(H1_1))), 'LineWidth', 2);
grid on;
title('Magnitude Response Comparison: H_{1,fft} and H_{1,transfer}', FontSize=22);
xlabel('Normalized Frequency (f/fs)', FontSize=20);
ylabel('Magnitude (dB)', FontSize=20);
legend('|H_{1,fft} |', '|H_{1,transfer} |', fontsize=14);
ylim([-120 10])
xlim([-0.5 0.5])
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