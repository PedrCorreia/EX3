% Q6_fixed - cleaned Q6 that mirrors Q5 plotting style
% Use this if Q6.m is corrupted. It expects the same exported variables:
% SOS_elip_lp, G_elip_lp, FIR_de

%% Parameters
Wp_hz = 500; Ws_hz = 570; fs = 2000; M = 2048; save_figures = true;

% Validate
needVars = {'SOS_elip_lp','G_elip_lp','FIR_de'};
for k=1:numel(needVars)
    if ~exist(needVars{k},'var')
        error('Missing %s in workspace', needVars{k});
    end
end

SOS = SOS_elip_lp; G = G_elip_lp; B_fir = FIR_de(:).'; A_fir = 1;

% SOS -> tf
if size(SOS,2) >= 7
    [b_iir,a_iir] = sos2tf(SOS(:,1:6), SOS(:,7));
else
    [b_iir,a_iir] = sos2tf(SOS);
end
% apply gain
if exist('G','var') && ~isempty(G)
    if isscalar(G)
        b_iir = b_iir * double(G);
    elseif isvector(G)
        b_iir = b_iir * prod(double(G(:)));
    else
        b_iir = b_iir * double(G(1));
    end
end

N_fir = length(B_fir)-1; n_iir = length(a_iir)-1;
[H_fir,f] = transfer(B_fir,A_fir,M);
[H_iir,~] = transfer(b_iir,a_iir,M);
f_hz = f*fs;
Hf_fir_db = 20*log10(abs(H_fir)+eps);
Hf_iir_db = 20*log10(abs(H_iir)+eps);
fig_mag = figure;
plot(f_hz, Hf_fir_db, 'Color', [0 0.4470 0.7410], 'LineWidth', 1); hold on;
plot(f_hz, Hf_iir_db, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1);
grid on; xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
title('Magnitude response (dB) — FIR vs Elliptic IIR');
legend('FIR','Elliptic IIR'); set(gca,'FontSize',14); ylim([-60 5]); xlim([-fs/2 fs/2]);
yl = ylim;
plot([Wp_hz Wp_hz], yl, 'k--', 'HandleVisibility', 'off');
plot([-Wp_hz -Wp_hz], yl, 'k--', 'HandleVisibility', 'off');
plot([Ws_hz Ws_hz], yl, 'k--', 'HandleVisibility', 'off');
plot([-Ws_hz -Ws_hz], yl, 'k--', 'HandleVisibility', 'off');
fig = gcf; fig.Position(3:4) = [700 350]; fig.PaperPositionMode = 'auto';

% FIR-only
fig_fir_only = figure;
plot(f_hz, Hf_fir_db, 'Color', [0 0.4470 0.7410],'LineWidth',1); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); set(gca,'FontSize',14); ylim([-60 5]); xlim([-fs/2 fs/2]);

% Phase (square) — match Q5 formatting exactly
phi_fir = unwrap(angle(H_fir)); phi_iir = unwrap(angle(H_iir));
% FIR phase (square)
fig_fir_phase = figure;
fig_fir_phase.Position(3:4) = [350 350];
plot(f_hz, phi_fir, 'Color', [0 0.4470 0.7410], 'LineWidth', 1.25); grid on;
xlabel('Normalized frequency'); ylabel('Phase (rad)');
title('FIR phase response'); set(gca, 'FontSize', 14); xlim([-fs/2 fs/2]);

% IIR phase (square)
fig_iir_phase = figure;
fig_iir_phase.Position(3:4) = [350 350];
plot(f_hz, phi_iir, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1.25); grid on;
xlabel('Normalized frequency'); ylabel('Phase (rad)');
title('Elliptic IIR phase response'); set(gca, 'FontSize', 14); xlim([-fs/2 fs/2]);

% Save images if desired (match Q5 naming/outputs)
if save_figures
    imagesDir = fullfile(pwd,'images'); if ~exist(imagesDir,'dir'); mkdir(imagesDir); end

    % Save magnitude response (PDF + PNG)
    try
        targetPdf = fullfile(imagesDir, 'Q6_response.pdf');
        targetPng = fullfile(imagesDir, 'Q6_response.png');
        fprintf('Q6: saving %s and %s\n', targetPdf, targetPng);
        exportgraphics(fig_mag, targetPdf, 'ContentType', 'vector');
        exportgraphics(fig_mag, targetPng, 'Resolution', 300);
        fprintf('Q6: saved response files\n');
    catch err
        fprintf('Q6: exportgraphics failed for response: %s\n', err.message);
        try
            print(fig_mag, fullfile(imagesDir, 'Q6_response.pdf'), '-dpdf');
            print(fig_mag, fullfile(imagesDir, 'Q6_response.png'), '-dpng', '-r300');
            fprintf('Q6: print fallback succeeded for response\n');
        catch err2
            fprintf('Q6: print fallback failed for response: %s\n', err2.message);
        end
    end

    % Save FIR-only (PDF + PNG)
    try
        targetPdf = fullfile(imagesDir, 'Q6_FIR_only.pdf');
        targetPng = fullfile(imagesDir, 'Q6_FIR_only.png');
        fprintf('Q6: saving %s and %s\n', targetPdf, targetPng);
        exportgraphics(fig_fir_only, targetPdf, 'ContentType', 'vector');
        exportgraphics(fig_fir_only, targetPng, 'Resolution', 300);
        fprintf('Q6: saved FIR-only files\n');
    catch err
        fprintf('Q6: exportgraphics failed for FIR-only: %s\n', err.message);
        try
            print(fig_fir_only, fullfile(imagesDir, 'Q6_FIR_only.pdf'), '-dpdf');
            print(fig_fir_only, fullfile(imagesDir, 'Q6_FIR_only.png'), '-dpng', '-r300');
            fprintf('Q6: print fallback succeeded for FIR-only\n');
        catch err2
            fprintf('Q6: print fallback failed for FIR-only: %s\n', err2.message);
        end
    end

    % Save phase figures (PDF + PNG)
    try
        targetPdf = fullfile(imagesDir, 'Q6_phase_FIR.pdf');
        targetPng = fullfile(imagesDir, 'Q6_phase_FIR.png');
        fprintf('Q6: saving %s and %s\n', targetPdf, targetPng);
        exportgraphics(fig_fir_phase, targetPdf, 'ContentType', 'vector');
        exportgraphics(fig_fir_phase, targetPng, 'Resolution', 300);
        fprintf('Q6: saved FIR phase files\n');
    catch err
        fprintf('Q6: exportgraphics failed for FIR phase: %s\n', err.message);
        try
            print(fig_fir_phase, fullfile(imagesDir, 'Q6_phase_FIR.pdf'), '-dpdf');
            print(fig_fir_phase, fullfile(imagesDir, 'Q6_phase_FIR.png'), '-dpng', '-r300');
            fprintf('Q6: print fallback succeeded for FIR phase\n');
        catch err2
            fprintf('Q6: print fallback failed for FIR phase: %s\n', err2.message);
        end
    end

    try
        targetPdf = fullfile(imagesDir, 'Q6_phase_IIR.pdf');
        targetPng = fullfile(imagesDir, 'Q6_phase_IIR.png');
        fprintf('Q6: saving %s and %s\n', targetPdf, targetPng);
        exportgraphics(fig_iir_phase, targetPdf, 'ContentType', 'vector');
        exportgraphics(fig_iir_phase, targetPng, 'Resolution', 300);
        fprintf('Q6: saved IIR phase files\n');
    catch err
        fprintf('Q6: exportgraphics failed for IIR phase: %s\n', err.message);
        try
            print(fig_iir_phase, fullfile(imagesDir, 'Q6_phase_IIR.pdf'), '-dpdf');
            print(fig_iir_phase, fullfile(imagesDir, 'Q6_phase_IIR.png'), '-dpng', '-r300');
            fprintf('Q6: print fallback succeeded for IIR phase\n');
        catch err2
            fprintf('Q6: print fallback failed for IIR phase: %s\n', err2.message);
        end
    end
end
