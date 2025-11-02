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
	run("assignment\q4\Q4_copilot.m");
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

% --- Z-plane (poles & zeros) plots for stability inspection ---
% Compute zeros and poles
z_fir = roots(B_fir(:));
p_fir = roots(A_fir(:));
z_iir = roots(B_iir(:));
p_iir = roots(A_iir(:));

% IIR stability check
p_mag = abs(p_iir);
max_pole = max(p_mag);
if isempty(max_pole)
	stability_msg = 'no poles found';
elseif max_pole < 1 - 1e-12
	stability_msg = 'stable (all poles strictly inside unit circle)';
elseif max_pole > 1 + 1e-12
	stability_msg = 'unstable (at least one pole outside unit circle)';
else
	stability_msg = 'marginal (pole(s) on or very near unit circle)';
end
fprintf('IIR stability check: max |pole| = %g -> %s\n', max_pole, stability_msg);

% Plot IIR z-plane
figure;
theta = linspace(0,2*pi,512);
plot(cos(theta), sin(theta), 'k--', 'HandleVisibility','off'); hold on; % unit circle
plot(real(z_iir), imag(z_iir), 'bo', 'MarkerSize',8, 'LineWidth',1.2);
plot(real(p_iir), imag(p_iir), 'rx', 'MarkerSize',10, 'LineWidth',1.5);
grid on; axis equal;
xlabel('Real'); ylabel('Imag');
title(sprintf('IIR zeros (o) and poles (x) — order %d — %s', n_iir, stability_msg));
legend('Unit circle','Zeros','Poles','Location','bestoutside');
xlim([-1.5 1.5]); ylim([-1.5 1.5]);

% Plot FIR z-plane (useful: FIR poles usually at origin if A=1)
figure;
plot(cos(theta), sin(theta), 'k--', 'HandleVisibility','off'); hold on;
if ~isempty(z_fir)
	plot(real(z_fir), imag(z_fir), 'bo', 'MarkerSize',8, 'LineWidth',1.2);
end
if ~isempty(p_fir)
	plot(real(p_fir), imag(p_fir), 'rx', 'MarkerSize',10, 'LineWidth',1.5);
end
grid on; axis equal;
xlabel('Real'); ylabel('Imag');
title(sprintf('FIR zeros (o) and poles (x) — order %d', N_fir));
legend('Unit circle','Zeros','Poles','Location','bestoutside');
xlim([-1.5 1.5]); ylim([-1.5 1.5]);
% --------------------------------------------------------------

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

% --- Diagnostic checks (help debug missing/empty plots) ---
f_norm = 2 * f;            % convert cycles/sample (-0.5..0.5) -> normalized -1..1 (we'll use >=0 later)
%% Operation estimates
fir_mults = N_fir + 1;
iir_mults = (n_iir + 1) + n_iir; % numerator + feedback (approx)

%% Print summary
fprintf('Design specs: Wp = %g Hz, Ws = %g Hz, Rp = %g dB, Rs = %g dB, fs = %g Hz\n', Wp_hz, Ws_hz, Rp, Rs, fs);
fprintf('FIR order: %d (operations per output ~ %d)\n', N_fir, fir_mults);
fprintf('Elliptic IIR order: %d (operations per output ~ %d)\n', n_iir, iir_mults);
fprintf('Estimated multiplication ratio IIR/FIR = %.2f\n', iir_mults / max(1,fir_mults));

%% Plot magnitude (dB) — normalized between 0 and 1 (1 = Nyquist)
f_norm = 2 * f;            % convert cycles/sample (-0.5..0.5) -> normalized 0..1 on positive side
pos = f_norm >= 0;         % positive half maps to 0..1
figure;
plot(f_norm(pos), Hf_fir_db(pos), 'LineWidth', 1); hold on;
plot(f_norm(pos), Hf_iir_db(pos), 'LineWidth', 1);
grid on;
xlabel('Normalized frequency');
ylabel('Magnitude (dB)');
title(sprintf('Magnitude response (dB) — FIR vs Elliptic IIR (order %d)', n_iir));
legend('FIR (reference)', 'Elliptic IIR');

% Formatting: set font size and y-limits common to the plots
set(gca, 'FontSize', 14);
ylim([-60 5]);

% Lock x-limits to [0,1] and draw dashed lines marking Wp and Ws (normalized
% to Nyquist i.e. 0..1). Plot lines only if inside [0,1] and don't add legend entries.
xlim([0 1]);
yl = ylim;
Wp_norm = Wp_hz / (fs/2); % normalized to Nyquist (0..1)
Ws_norm = Ws_hz / (fs/2);
if Wp_norm >= 0 && Wp_norm <= 1
	plot([Wp_norm Wp_norm], yl, 'k--', 'HandleVisibility', 'off');
end
if Ws_norm >= 0 && Ws_norm <= 1
	plot([Ws_norm Ws_norm], yl, 'k--', 'HandleVisibility', 'off');
end

fig = gcf;
fig.PaperPositionMode = 'auto'; % keep on-screen size
exportgraphics(fig, 'Q5_response.pdf', 'ContentType', 'vector');
