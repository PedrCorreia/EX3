function [B, A, n] = elip_lp(Wp_hz, Ws_hz, Rp, Rs, fs)
%ELIP_LP Design an elliptic (Cauer) low-pass IIR filter using Hz inputs.
%   [B, A, n, Wn_norm] = elip_lp(Wp_hz, Ws_hz, Rp, Rs, fs) designs an
%   elliptic digital low-pass IIR filter where pass/stop edges are given in Hz.
%
%   Inputs:
%     Wp_hz - Passband edge in Hz (positive scalar)
%     Ws_hz - Stopband edge in Hz (positive scalar, > Wp_hz)
%     Rp    - Passband ripple in dB (positive scalar, e.g. 1)
%     Rs    - Stopband attenuation in dB (positive scalar, e.g. 45)
%     fs    - Sampling frequency in Hz (positive scalar)
%
%   Outputs:
%     B, A      - IIR filter numerator and denominator coefficients
%     n         - filter order determined by ellipord
%     Wn_norm   - critical (normalized) passband edge used by ellip (1 = Nyquist)
%
%   Notes:
%     - This function normalizes the Hz edges to the [0,1] range expected by
%       MATLAB's ellipord/ellip where 1 corresponds to the Nyquist frequency fs/2.
%     - Example: [B,A,n] = elip_lp(500, 570, 1, 45, 2000)

    % Normalize to [0,1] where 1 corresponds to Nyquist (fs/2)
    nyq = fs/2;
    Wp = Wp_hz / nyq;
    Ws = Ws_hz / nyq;

    % Determine minimum order using custom search routine (returns order)
    maxOrder = 100; % safety cap; adjust if needed
    n = elip_min_order(Wp, Ws, Rp, Rs, maxOrder);

    % Design elliptic filter of order n using the found normalized passband edge
    [B, A] = ellip(n, Rp, Rs, Wp);
end
