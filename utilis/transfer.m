function [H, f] = transfer(B, A, M)
%TRANSFER Compute the complex transfer function H(e^{j2πf}) of an IIR filter.
%   [H, f] = transfer(B, A, M) returns the complex frequency response H and
%   the corresponding normalized frequency vector f in [-1/2, 1/2], using M points.
%
%   Inputs:
%     B - row/column vector of numerator coefficients
%     A - row/column vector of denominator coefficients
%     M - number of frequency samples (positive integer)
%
%   Outputs:
%     H - complex frequency response (Mx1)
%     f - normalized frequencies in [-1/2, 1/2] (Mx1)

    narginchk(3,3);
    validateattributes(B, {'double','single'}, {'vector','nonempty'}, mfilename, 'B', 1);
    validateattributes(A, {'double','single'}, {'vector','nonempty'}, mfilename, 'A', 2);
    validateattributes(M, {'numeric'}, {'scalar','integer','>=',2}, mfilename, 'M', 3);

    % Ensure column vectors
    B = B(:);
    A = A(:);

    % Frequency vector in [-1/2, 1/2]
    f = linspace(-M/2, M/2, M).' / M;   % Mx1

    % Build Vandermonde-like matrices to evaluate sums efficiently:
    kB = (0:numel(B)-1);                      % 1xNb
    kA = (0:numel(A)-1);                      % 1xNa
    EB = exp(-1j*2*pi * f * kB);              % MxNb
    EA = exp(-1j*2*pi * f * kA);              % MxNa

    % Numerator and denominator
    Num = EB * B;                              % Mx1
    Den = EA * A;                              % Mx1

    % Guard against division by ~0
    tiny = 1e-15;
    Den = Den + (abs(Den) < tiny).*tiny;

    H = Num ./ Den;                            % Mx1
end
