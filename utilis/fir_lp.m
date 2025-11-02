function [h_best, N_min, H_best, f_best, stop_attn_db] = fir_lp(Wp_hz, Ws_hz, fs, Rs, M, maxOrder)
nyq = fs/2;
Wp = Wp_hz / nyq;
Ws = Ws_hz / nyq;
for N = 3:maxOrder
    h = firpm(N, [0 Wp Ws 1], [1 1 0 0], [1 10]);
    [H, f] = transfer(h, 1, M);
    f_hz = f * fs;
    stop_idx = f_hz >= Ws_hz & f_hz <= nyq;
    if ~any(stop_idx)
        continue
    end
    stop_mag = max(abs(H(stop_idx)));
    stop_attn_db = -20*log10(stop_mag + eps);
    if stop_attn_db >= Rs
        N_min = N;
        h_best = h(:).';
        H_best = H;
        f_best = f_hz;
        return
    end
end
error('Could not find FIR order up to %d that meets Rs = %g dB', maxOrder, Rs);
end
