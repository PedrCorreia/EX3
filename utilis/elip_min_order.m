function [n] = elip_min_order_fixed(Wp, Ws, Rp, Rs, maxOrder)
%ELIP_MIN_ORDER_FIXED Find minimum elliptic filter order by iterative design
%   [n] = elip_min_order_fixed(Wp, Ws, Rp, Rs, maxOrder)
%   Wp and Ws are normalized frequencies in (0,1], where 1 corresponds to Nyquist.

% Frequency grid for testing (rad/sample)
Nfft = 8192;
w = linspace(0, pi, Nfft);
fn = w / pi; % normalized 0..1

stop_idx = fn >= Ws & fn <= 1;

found = false;
for n_try = 1:maxOrder
    try
        [b, a] = ellip(n_try, Rp, Rs, Wp);
    catch
        % some orders may not be valid; continue searching
        continue
    end

    H = freqz(b, a, w);
    stop_mag = max(abs(H(stop_idx)));
    stop_attn_db = -20*log10(stop_mag + eps);
    if stop_attn_db >= Rs && ~found
        n = n_try;
        found = true;
        if found
            return
        end
    end
end

end

 
