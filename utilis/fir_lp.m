function [h_best, N_min, H_best, f_best, stop_attn_db] = fir_lp(Wp_hz, Ws_hz, fs, Rs, M, maxOrder)
% fir_lp  Find minimum-order linear-phase FIR lowpass using firpm
%
% [h_best, N_min, H_best, f_best, stop_attn_db] = fir_lp(Wp_hz, Ws_hz, fs, Rs, M, maxOrder)
%
% Inputs:
%  Wp_hz     - passband edge in Hz
%  Ws_hz     - stopband start in Hz
%  fs        - sampling frequency in Hz
%  Rs        - required stopband attenuation in dB
%  M         - number of frequency samples for analysis
%  maxOrder  - maximum FIR order to try
%
% Outputs:
%  h_best        - FIR coefficients (row vector)
%  N_min         - minimum order found
%  H_best        - frequency response corresponding to h_best (complex)
%  f_best        - frequency vector in Hz for H_best
%  stop_attn_db  - measured stopband attenuation (dB)

% Basic input validation
validateattributes(Wp_hz, {'numeric'}, {'scalar','positive'});
validateattributes(Ws_hz, {'numeric'}, {'scalar','positive'});
validateattributes(fs, {'numeric'}, {'scalar','positive'});
validateattributes(Rs, {'numeric'}, {'scalar','nonnegative'});
if nargin < 6 || isempty(maxOrder)
    maxOrder = 300;
end
if nargin < 5 || isempty(M)
    M = 4096;
end

nyq = fs/2;
Wp = Wp_hz / nyq;
Ws = Ws_hz / nyq;

if Wp <= 0 || Ws <= 0 || Wp >= 1 || Ws >= 1
    error('Cutoff frequencies must be between 0 and Nyquist (fs/2).');
end
if Ws <= Wp
    error('Ws_hz must be greater than Wp_hz');
end

found = false;
for N = 2:maxOrder
    % design with firpm: frequency breakpoints [0 Wp Ws 1]
    freq = [0 Wp Ws 1];
    amp  = [1 1 0 0];
    weights = [1 10];
    try
        h = firpm(N, freq, amp, weights);
    catch
        continue; % skip unsupported N values
    end

    % frequency response
    [H, w] = freqz(h, 1, M);
    f_hz = (w/pi) * nyq; % 0..Nyquist

    % stopband indices (from Ws_hz to Nyquist)
    stop_idx = f_hz >= Ws_hz & f_hz <= nyq;
    if ~any(stop_idx)
        continue
    end
    stop_mag = max(abs(H(stop_idx)));
    stop_attn_db = -20*log10(stop_mag + eps);

    if stop_attn_db >= Rs
        found = true;
        N_min = N;
        h_best = h(:).';
        H_best = H;
        f_best = f_hz;
        break
    end
end

if ~found
    error('Could not find FIR order up to %d that meets Rs = %g dB', maxOrder, Rs);
end
end
