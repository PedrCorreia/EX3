% Q5

%% Parameters
Wp_hz = 500;    % passband edge in Hz 
Ws_hz = 570;    % stopband edge in Hz
Rp    = 1;      % passband ripple in dB
Rs    = 45;     % stopband attenuation in dB (dB)
fs    = 2000;   % sampling frequency in Hz
M     = 2048;   % number of frequency samples for plotting
% Toggle automatic saving of figures (PDF/PNG) into the images/ folder
% Set to false to disable auto-saving during interactive runs
save_figures = true;

%% Setup
try
	fprintf('Running Q4 to obtain reference FIR...\n');
	run("assignment\q4\Q4_copilot.m");
catch err
	if isprop(err, 'identifier')
		warning(err.identifier, '%s', err.message);
	else
		warning('Q5:Q4RunError', '%s', err.message);
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
% IIR stability: compute poles and classify
p_iir = roots(A_iir(:));
if isempty(p_iir)
	max_pole = NaN;
else
	max_pole = max(abs(p_iir));
end
if isnan(max_pole)
	stability_msg = 'no poles found';
elseif max_pole < 1 - 1e-12
	stability_msg = 'stable ';
elseif max_pole > 1 + 1e-12
	stability_msg = 'unstable ';
else
	stability_msg = 'marginal ';
end
fprintf('IIR stability check: max |pole| = %g -> %s\n', max_pole, stability_msg);
figure;
zplane(B_iir, A_iir);
title('IIR pole-zero plot');
ax = gca;
ln = findobj(ax, 'Type', 'Line');
set(ln, 'LineWidth', 1.2);
% enforce font size
fig_iir_z = gcf;
axs = findall(fig_iir_z, 'Type', 'axes');
set(axs, 'FontSize', 14);
if save_figures
	% ensure images directory exists (save into 'images' under current folder)
	imagesDir = fullfile(pwd, 'images');
	if ~exist(imagesDir, 'dir')
		mkdir(imagesDir);
	end
	try
		exportgraphics(fig_iir_z, fullfile(imagesDir, 'Q5_IIR_pz.pdf'), 'ContentType', 'vector');
	catch
		% older MATLAB: fallback to print as PDF (may rasterize)
		print(fig_iir_z, fullfile(imagesDir, 'Q5_IIR_pz.pdf'), '-dpdf');
	end
end
% FIR stability: compute poles and classify
p_fir = roots(A_fir(:));
if isempty(p_fir)
	max_pole_fir = NaN;
else
	max_pole_fir = max(abs(p_fir));
end
if isnan(max_pole_fir)
	stability_msg_fir = 'no poles found';
elseif max_pole_fir < 1 - 1e-12
	stability_msg_fir = 'stable';
elseif max_pole_fir > 1 + 1e-12
	stability_msg_fir = 'unstable';
else
	stability_msg_fir = 'marginal';
end
fprintf('FIR stability check: max |pole| = %g -> %s\n', max_pole_fir, stability_msg_fir);

figure;
zplane(B_fir, A_fir);
title('FIR pole-zero plot');
ax = gca;
ln = findobj(ax, 'Type', 'Line');
set(ln, 'LineWidth', 1.2);
% enforce font size
fig_fir_z = gcf;
axs = findall(fig_fir_z, 'Type', 'axes');
set(axs, 'FontSize', 14);
if save_figures
	try
		exportgraphics(fig_fir_z, fullfile(imagesDir, 'Q5_FIR_pz.pdf'), 'ContentType', 'vector');
	catch
		print(fig_fir_z, fullfile(imagesDir, 'Q5_FIR_pz.pdf'), '-dpdf');
	end
end

% Impulse response test for IIR (quick stability visual / numeric check)
N_imp = 200;
x = [1, zeros(1, N_imp-1)];
h_iir = filter(B_iir, A_iir, x);
fprintf('IIR impulse response: max |h[n]| = %g, |h[end]| = %g\n', max(abs(h_iir)), abs(h_iir(end)));
figure;
subplot(2,1,1);
stem(0:N_imp-1, h_iir, 'filled'); grid on;
title('IIR impulse response'); xlabel('n'); ylabel('h[n]');
subplot(2,1,2);
semilogy(0:N_imp-1, abs(h_iir) + eps); grid on;
title('|h[n]| (semilog)'); xlabel('n'); ylabel('|h[n]|');
% enforce font size and save impulse response figure
fig_imp = gcf;
axs = findall(fig_imp, 'Type', 'axes');
set(axs, 'FontSize', 14);
if save_figures
	try
		exportgraphics(fig_imp, fullfile(imagesDir, 'Q5_IIR_impulse.pdf'), 'ContentType', 'vector');
	catch
		print(fig_imp, fullfile(imagesDir, 'Q5_IIR_impulse.pdf'), '-dpdf');
	end
end

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


%% Operation estimates
fir_mults = N_fir + 1;
iir_mults = (n_iir + 1) + n_iir; % numerator + feedback (approx)

%% Print summary
fprintf('Design specs: Wp = %g Hz, Ws = %g Hz, Rp = %g dB, Rs = %g dB, fs = %g Hz\n', Wp_hz, Ws_hz, Rp, Rs, fs);
fprintf('FIR order: %d (operations per output ~ %d)\n', N_fir, fir_mults);
fprintf('Elliptic IIR order: %d (operations per output ~ %d)\n', n_iir, iir_mults);
fprintf('Estimated multiplication ratio IIR/FIR = %.2f\n', iir_mults / max(1,fir_mults));

%% Plot magnitude (dB) — full two-sided frequency axis in Hz (-fs/2 .. +fs/2)
% f_hz was computed earlier as f * fs
figure;
% make magnitude figure rectangular to match requested aspect
fig = gcf; fig.Position(3:4) = [700 350];
% explicit MATLAB default colors (blue, orange)
plot(f_hz, Hf_fir_db, 'Color', [0 0.4470 0.7410], 'LineWidth', 1); hold on;
plot(f_hz, Hf_iir_db, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1);
grid on;
xlabel('Frequency (Hz)');
ylabel('Magnitude (dB)');
title('Magnitude response (dB) — FIR vs Elliptic IIR');
legend('FIR', 'Elliptic IIR');

% Formatting: set font size and y-limits common to the plots
set(gca, 'FontSize', 14);
ylim([-60 5]);

% Lock x-limits to the sampling interval and draw dashed lines marking ±Wp and ±Ws
xlim([-fs/2 fs/2]);
yl = ylim;
% Mark both positive and negative edges for clarity
plot([Wp_hz Wp_hz], yl, 'k--', 'HandleVisibility', 'off');
plot([-Wp_hz -Wp_hz], yl, 'k--', 'HandleVisibility', 'off');
plot([Ws_hz Ws_hz], yl, 'k--', 'HandleVisibility', 'off');
plot([-Ws_hz -Ws_hz], yl, 'k--', 'HandleVisibility', 'off');
fig = gcf; fig.PaperPositionMode = 'auto'; % keep on-screen size
if save_figures
	try
		% save vector PDF
		exportgraphics(fig, fullfile(imagesDir, 'Q5_response.pdf'), 'ContentType', 'vector');
		% also save a high-resolution PNG raster for convenience
		exportgraphics(fig, fullfile(imagesDir, 'Q5_response.png'), 'Resolution', 300);
	catch
		print(fig, fullfile(imagesDir, 'Q5_response.pdf'), '-dpdf');
		print(fig, fullfile(imagesDir, 'Q5_response.png'), '-dpng', '-r300');
	end
end
% --- Phase response plots unwrapped
phi_fir = unwrap(angle(H_fir));
phi_iir = unwrap(angle(H_iir));

% FIR phase 
fig_fir_phase = figure;
fig_fir_phase.Position(3:4) = [350 350];
% MATLAB default blue
plot(f_hz, phi_fir, 'Color', [0 0.4470 0.7410], 'LineWidth', 1.25);
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
title('FIR phase response');
set(gca, 'FontSize', 14);
xlim([-fs/2 fs/2]);

if save_figures
	try
		exportgraphics(fig_fir_phase, fullfile(imagesDir, 'Q5_phase_FIR.pdf'), 'ContentType', 'vector');
		exportgraphics(fig_fir_phase, fullfile(imagesDir, 'Q5_phase_FIR.png'), 'Resolution', 300);
	catch
		print(fig_fir_phase, fullfile(imagesDir, 'Q5_phase_FIR.pdf'), '-dpdf');
		print(fig_fir_phase, fullfile(imagesDir, 'Q5_phase_FIR.png'), '-dpng', '-r300');
	end
end

% IIR phase 
fig_iir_phase = figure;
fig_iir_phase.Position(3:4) = [350 350];
% MATLAB default orange
plot(f_hz, phi_iir, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.25);
grid on;
xlabel('Frequency (Hz)');
ylabel('Phase (rad)');
title('Elliptic IIR phase response');
set(gca, 'FontSize', 14);
xlim([-fs/2 fs/2]);
if save_figures
	try
	exportgraphics(fig_iir_phase, fullfile(imagesDir, 'Q5_phase_IIR.pdf'), 'ContentType', 'vector');
	exportgraphics(fig_iir_phase, fullfile(imagesDir, 'Q5_phase_IIR.png'), 'Resolution', 300);
	catch
		print(fig_iir_phase, fullfile(imagesDir, 'Q5_phase_IIR.pdf'), '-dpdf');
		print(fig_iir_phase, fullfile(imagesDir, 'Q5_phase_IIR.png'), '-dpng', '-r300');
	end
end
