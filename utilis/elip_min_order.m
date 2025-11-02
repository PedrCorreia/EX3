function [n] = elip_min_order(Wp, Ws, Rp, Rs, maxOrder)
Nfft=8016
for n_try = 1:maxOrder
    [b, a] = ellip(n_try, Rp, Rs, Wp);
    [H, f] = transfer(b, a, Nfft); % f in cycles/sample [-0.5,0.5]
    % select positive-half frequencies and convert to normalized 0..1
    pos = f >= 0;
    H_pos = H(pos);
    f_norm_pos = 2 * f(pos); % maps [0,0.5] -> [0,1]
    stop_idx = f_norm_pos >= Ws & f_norm_pos <= 1;
    if ~any(stop_idx)
        continue
    end
    stop_mag = max(abs(H_pos(stop_idx)));
    stop_attn_db = -20*log10(stop_mag + eps);
    if stop_attn_db >= Rs
        n = n_try;
        return
    end
end

error('Could not find elliptic order up to %d that meets Rs = %g dB', maxOrder, Rs);
end

 
