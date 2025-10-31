%Q2: Compute and visualize the transfer function of an IIR filter

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

%Visualize transfer function of an IIR filter

% Given:
B1 = [0.0725 0.2200 0.4085 0.4883 0.4085 0.2200 0.0725];
A1 = [1.0000 -0.5835 1.7021 -0.8477 0.8401 -0.2823 0.0924];

M  = 1024;                       % number of frequency points
[Hf1, f] = transfer(B1, A1, M);  % [H,f] = transfer(B1, A1, M)

% Plots (magnitude (|H(f)|) and phase vs normalized frequency f in [-1/2, 1/2])
figure;
subplot(2,1,1);
plot(f, abs(Hf1), 'LineWidth', 1); 
grid on;
title('Spectrum by transfer function');
xlabel('f/fs');
ylabel('|H_1(f)|');

subplot(2,1,2);
plot(f, angle(Hf1), 'LineWidth', 1); 
grid on;
xlabel('f/fs');
ylabel('Phase Angle H_1(f)');