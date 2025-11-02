% Q4: design minimum-order linear-phase FIR (firpm) to meet stopband attenuation
% This script searches for the minimum FIR order (N) such that a firpm lowpass with
% cutoff Wp_hz and stopband starting Ws_hz achieves at least Rs dB attenuation.

%% Parameters (edit when needed)
Wp_hz = 500;    % passband edge (Hz)
Ws_hz = 570;    % stopband start (Hz)
fs    = 2000;   % sampling frequency (Hz)
Rs    = 45;     % required stopband attenuation (dB)
M     = 4096;   % frequency samples for analysis/plot
maxOrder = 300; % maximum FIR order to try

%% normalize frequencies (0..1 where 1 = Nyquist)
nyq = fs/2;
Wp = Wp_hz / nyq;
Ws = Ws_hz / nyq;

%% search for minimum order using helper function

[h_best, N_min, H_best, f_best, stop_attn_db] = fir_lp(Wp_hz, Ws_hz, fs, Rs, M, maxOrder);

%% report and plot
fprintf('Minimum FIR order found: N = %d (length = %d taps)\n', N_min, N_min+1);
fprintf('Stopband attenuation at %g Hz and above: %.2f dB\n', Ws_hz, stop_attn_db);

figure;
plot(f_best, 20*log10(abs(H_best)+eps), 'LineWidth', 1);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title(sprintf('FIRpm lowpass (order %d) — magnitude (dB)', N_min));
ylim([-100 5]);
hold on;
yl = ylim;
plot([Wp_hz Wp_hz], yl, 'k--');
plot([Ws_hz Ws_hz], yl, 'k--');
legend('Magnitude (dB)','Wp','Ws');

% save best coefficients to workspace variable
B_fir = h_best(:).';
A_fir = 1;
% export an N_fir variable for compatibility with other scripts
N_fir = N_min;
