function [B, A, n, Wn_norm] = elip_lp(Wp_hz, Ws_hz, Rp, Rs, fs)
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

    narginchk(5,5);
    validateattributes(Wp_hz, {'numeric'}, {'scalar','>',0}, mfilename, 'Wp_hz', 1);
    validateattributes(Ws_hz, {'numeric'}, {'scalar','>',0}, mfilename, 'Ws_hz', 2);
    validateattributes(Rp, {'numeric'}, {'scalar','>=',0}, mfilename, 'Rp', 3);
    validateattributes(Rs, {'numeric'}, {'scalar','>=',0}, mfilename, 'Rs', 4);
    validateattributes(fs, {'numeric'}, {'scalar','>',0}, mfilename, 'fs', 5);

    if Ws_hz <= Wp_hz
        error('Stopband edge Ws_hz must be strictly greater than passband edge Wp_hz.');
    end
    nyq = fs/2;
    if Wp_hz >= nyq || Ws_hz >= nyq
        error('Passband and stopband edges must be less than Nyquist frequency (fs/2).');
    end

    % Normalize to [0,1] where 1 corresponds to Nyquist (fs/2)
    Wp = Wp_hz / nyq;
    Ws = Ws_hz / nyq;

    % Determine minimum order and critical frequency (normalized)
    [n, Wn_norm] = ellipord(Wp, Ws, Rp, Rs);

    % Design elliptic filter of order n using normalized edge
    [B, A] = ellip(n, Rp, Rs, Wn_norm);
end
