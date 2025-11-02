% Q6_fixed - cleaned Q6 that mirrors Q5 plotting style
% Use this if Q6.m is corrupted. It expects the same exported variables:
% SOS_elip_lp, G_elip_lp, FIR_de

%% Parameters (edit as needed)
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

% Plot magnitude (blue/orange), legend without '(reference)'
figure;
plot(f_hz, Hf_fir_db, 'Color', [0 0.4470 0.7410], 'LineWidth', 1); hold on;
plot(f_hz, Hf_iir_db, 'Color', [0.8500 0.3250 0.0980], 'LineWidth', 1);
grid on; xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)');
legend('FIR','Elliptic IIR'); set(gca,'FontSize',14); ylim([-60 5]); xlim([-fs/2 fs/2]);

% FIR-only
figure;
plot(f_hz, Hf_fir_db, 'Color', [0 0.4470 0.7410],'LineWidth',1); grid on;
xlabel('Frequency (Hz)'); ylabel('Magnitude (dB)'); set(gca,'FontSize',14); ylim([-60 5]); xlim([-fs/2 fs/2]);

% Phase rectangular
phi_fir = unwrap(angle(H_fir)); phi_iir = unwrap(angle(H_iir));
fig = figure; fig.Position(3:4) = [700 350];
plot(f_hz, phi_fir, 'Color', [0 0.4470 0.7410],'LineWidth',1.25); grid on; xlabel('Normalized frequency'); ylabel('Phase (rad)'); set(gca,'FontSize',14); xlim([-fs/2 fs/2]);

fig2 = figure; fig2.Position(3:4) = [700 350];
plot(f_hz, phi_iir, 'Color', [0.8500 0.3250 0.0980],'LineWidth',1.25); grid on; xlabel('Normalized frequency'); ylabel('Phase (rad)'); set(gca,'FontSize',14); xlim([-fs/2 fs/2]);

% Save images if desired
if save_figures
    imagesDir = fullfile(pwd,'images'); if ~exist(imagesDir,'dir'); mkdir(imagesDir); end
    exportgraphics(gcf, fullfile(imagesDir,'Q6_fixed_last.png'),'Resolution',300);
end
