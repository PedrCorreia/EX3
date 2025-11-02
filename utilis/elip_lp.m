function [B, A, n] = elip_lp(Wp_hz, Ws_hz, Rp, Rs, fs)
nyq = fs/2;
Wp = Wp_hz / nyq;
Ws = Ws_hz / nyq;
n = elip_min_order(Wp, Ws, Rp, Rs, 100);
[B, A] = ellip(n, Rp, Rs, Wp);
end
