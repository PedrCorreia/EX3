% Q5 (script): design elliptic IIR from Hz specs, plot transfer in dB, print order
% Uses utilities: utilises/elip_lp.m and utilis/transfer.m

%% Parameters (edit these at the top)
Wp_hz = 500;    % passband edge in Hz (≤ 500 per assignment)
Ws_hz = 570;    % stopband edge in Hz (≥ 570 per assignment)
Rp    = 1;      % passband ripple in dB
Rs    = 45;     % stopband attenuation in dB (dB)
fs    = 2000;   % sampling frequency in Hz
M     = 2048;   % number of frequency samples for plotting

%% Setup
addpath(fullfile('..','..','utilis'));

% Reference FIR (replace with your FIR if required)
B_fir = [0.0725 0.2200 0.4085 0.4883 0.4085 0.2200 0.0725];
A_fir = 1;
N_fir = numel(B_fir)-1;

%% Design elliptic IIR using Hz inputs
[B_iir, A_iir, n_iir, ~] = elip_lp(Wp_hz, Ws_hz, Rp, Rs, fs);

%% Compute transfer functions
[H_fir, f] = transfer(B_fir, A_fir, M);
[H_iir, ~] = transfer(B_iir, A_iir, M);

% Convert normalized frequency vector (cycles/sample in [-0.5,0.5]) to Hz
f_hz = f * fs;  % now ranges [-fs/2, fs/2]

%% Magnitude in dB
Hf_fir_db = 20*log10(abs(H_fir) + eps);
Hf_iir_db = 20*log10(abs(H_iir) + eps);

%% Multiplication estimates
fir_mults = N_fir + 1;
iir_mults = (n_iir + 1) + n_iir; % numerator + feedback (approx)

%% Print summary
fprintf('Design specs: Wp = %g Hz, Ws = %g Hz, Rp = %g dB, Rs = %g dB, fs = %g Hz\n', Wp_hz, Ws_hz, Rp, Rs, fs);
fprintf('FIR order: %d (multiplies per output ~ %d)\n', N_fir, fir_mults);
fprintf('Elliptic IIR order: %d (multiplies per output ~ %d)\n', n_iir, iir_mults);
fprintf('Estimated multiplication ratio IIR/FIR = %.2f\n', iir_mults / max(1,fir_mults));

%% Plot magnitude (dB) — show non-negative frequencies (0..fs/2)
pos = f_hz >= 0;
figure;
plot(f_hz(pos), Hf_fir_db(pos), 'b', 'LineWidth', 1); hold on;
plot(f_hz(pos), Hf_iir_db(pos), 'r--', 'LineWidth', 1);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title(sprintf('Magnitude response (dB) — FIR vs Elliptic IIR (order %d)', n_iir));
legend('FIR (reference)', 'Elliptic IIR');

%% Commentary (brief)
fprintf('\nCommentary:\n');
fprintf('- The FIR filter above has order %d (length %d). It requires about %d multiplies per output sample (direct FIR).\n', N_fir, N_fir+1, fir_mults);
fprintf('- The elliptic IIR requires order %d. A direct-form implementation typically needs about %d multiplies per output (numerator + feedback).\n', n_iir, iir_mults);
fprintf('- Elliptic IIR filters are often lower order than equivalent FIRs for similar magnitude specs; this reduces multiplications but introduces feedback states and potential quantization issues.\n');
 
