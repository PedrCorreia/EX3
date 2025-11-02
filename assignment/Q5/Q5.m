% Q5

%% Parameters (edit these at the top)
Wp_hz = 500;    % passband edge in Hz (≤ 500 per assignment)
Ws_hz = 570;    % stopband edge in Hz (≥ 570 per assignment)
Rp    = 1;      % passband ripple in dB
Rs    = 45;     % stopband attenuation in dB (dB)
fs    = 2000;   % sampling frequency in Hz
M     = 2048;   % number of frequency samples for plotting

%% Setup

try
	fprintf('Running Q4 to obtain reference FIR...\n');
	run("assignment\q4\Q4.m");
catch err
	if isprop(err, 'identifier')
		warning(err.identifier, '%s', err.message);
	else
		warning('Q4 run error: %s', err.message);
	end
	error('Q4 script failed. Q5 requires Q4 to provide B_fir/A_fir/N_fir — aborting.');
end


% Harmonize order variable
if ~exist('N_fir','var')
	if exist('N_min','var')
		N_fir = N_min;
	else
		N_fir = length(B_fir)-1;
	end
end
fprintf('Q4 produced FIR order: %d\n', N_fir);

%% Design elliptic IIR using Hz inputs
[B_iir, A_iir, n_iir] = elip_lp(Wp_hz, Ws_hz, Rp, Rs, fs);

%% Compute transfer functions
[H_fir, f] = transfer(B_fir, A_fir, M);
[H_iir, ~] = transfer(B_iir, A_iir, M);

% Convert normalized frequency vector (cycles/sample in [-0.5,0.5]) to Hz
f_hz = f * fs;  % now ranges [-fs/2, fs/2]

%% Magnitude in dB
Hf_fir_db = 20*log10(abs(H_fir) + eps);
Hf_iir_db = 20*log10(abs(H_iir) + eps);

% Compute measured passband ripple and stopband attenuation (use non-negative freqs)
f_pos = f_hz >= 0;
fp = f_hz(f_pos);
Hf_fir_db_pos = Hf_fir_db(f_pos);
Hf_iir_db_pos = Hf_iir_db(f_pos);

% passband: 0..Wp_hz
pb_idx = fp <= Wp_hz;
if any(pb_idx)
	ripple_fir = max(Hf_fir_db_pos(pb_idx)) - min(Hf_fir_db_pos(pb_idx));
	ripple_iir = max(Hf_iir_db_pos(pb_idx)) - min(Hf_iir_db_pos(pb_idx));
else
	ripple_fir = NaN;
	ripple_iir = NaN;
end

% stopband: Ws_hz..fs/2
sb_idx = fp >= Ws_hz & fp <= (fs/2);
if any(sb_idx)
	stop_attn_fir = -20*log10(max(10.^(Hf_fir_db_pos(sb_idx)/20)) + eps);
	stop_attn_iir = -20*log10(max(10.^(Hf_iir_db_pos(sb_idx)/20)) + eps);
else
	stop_attn_fir = NaN;
	stop_attn_iir = NaN;
end

% Print measured metrics
fprintf('\nMeasured metrics (non-negative frequencies):\n');
fprintf('FIR:  order=%d, passband ripple=%.3f dB, stopband attenuation=%.2f dB\n', N_fir, ripple_fir, stop_attn_fir);
fprintf('IIR:  order=%d, passband ripple=%.3f dB, stopband attenuation=%.2f dB\n', n_iir, ripple_iir, stop_attn_iir);

%% Multiplication estimates
fir_mults = N_fir + 1;
iir_mults = (n_iir + 1) + n_iir; % numerator + feedback (approx)

%% Print summary
fprintf('Design specs: Wp = %g Hz, Ws = %g Hz, Rp = %g dB, Rs = %g dB, fs = %g Hz\n', Wp_hz, Ws_hz, Rp, Rs, fs);
fprintf('FIR order: %d (multiplies per output ~ %d)\n', N_fir, fir_mults);
fprintf('Elliptic IIR order: %d (multiplies per output ~ %d)\n', n_iir, iir_mults);
fprintf('Estimated multiplication ratio IIR/FIR = %.2f\n', iir_mults / max(1,fir_mults));

%% Plot magnitude (dB) — show non-negative normalized frequencies (0..0.5 cycles/sample)
pos = f >= 0; % normalized frequency vector f is in cycles/sample [-0.5,0.5]
figure;
plot(f(pos), Hf_fir_db(pos), 'LineWidth', 1); hold on;
plot(f(pos), Hf_iir_db(pos), 'LineWidth', 1);
grid on;
xlabel('Normalized frequency (cycles/sample)');
ylabel('Magnitude (dB)');
title(sprintf('Magnitude response (dB) — FIR vs Elliptic IIR (order %d)', n_iir));
legend('FIR (reference)', 'Elliptic IIR');
% Draw dashed lines marking Wp and Ws (normalized) to match Q4 visuals
yl = ylim;
Wp_norm = Wp_hz / (fs/2); % normalized (0..1 corresponds to 0..Nyquist)
Ws_norm = Ws_hz / (fs/2);
plot([Wp_norm Wp_norm], yl, 'k--');
plot([Ws_norm Ws_norm], yl, 'k--');
