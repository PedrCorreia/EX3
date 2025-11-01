%Q1: Stability Analysis of IIR filters

% A discrete-time IIR filter is stable if all poles lie inside the unit circle (|p| < 1).

clc; clear; close all;

% Filter 1
B1 = [0.0725 0.2200 0.4085 0.4883 0.4085 0.2200 0.0725];
A1 = [1.0000 -0.5835 1.7021 -0.8477 0.8401 -0.2823 0.0924];

% Filter 2
B2 = [1.0000 1.3000 0.4900 -0.0130 -0.0290];
A2 = [1.0000 -0.4326 -1.6656 0.1253 0.2877];

% Filter 3
B3 = [1.0000 -1.4000 0.2400 0.3340 -0.1305];
A3 = [1.0000 0.5913 -0.6436 0.3803 -1.0091];

% Store all filters for looping
filters = {B1, A1; B2, A2; B3, A3};

% Loop through each filter to analyze stability
for k = 1:length(filters)
    B = filters{k,1};
    A = filters{k,2};
    
    fprintf('--- Filter %d ---\n', k);
    
    % Find poles using roots() function
    poles = roots(A);
    disp('Poles:');
    disp(poles);
    
    % Compute magnitude of each pole
    mag_poles = abs(poles);
    disp('Magnitude of Poles:');
    disp(mag_poles);
    
    % Plot the pole-zero diagram
    figure;
    zplane(B, A);
    title(sprintf('Pole-Zero Plot for Filter %d', k));
    grid on;

    % Make poles, zeros, and the unit circle all have LineWidth = 1.2
    ax = gca;
    ln = findobj(ax, 'Type', 'Line');   % finds pole/zero markers and unit circle
    set(ln, 'LineWidth', 1.2);
end

% Verify stability with impulse (delta) response using filter()
% Compare the impulse responses of Filter 1 (stable) and Filter 2 (unstable)

% Create delta input
N  = 200;                 % number of samples
x  = [1, zeros(1, N-1)];  % delta function δ[n]
n  = 0:N-1;               % time index

% Compute impulse responses
h1 = filter(B1, A1, x);   % Filter 1 (expected stable)
h2 = filter(B2, A2, x);   % Filter 2 (expected unstable)
h3 = filter(B3, A3, x);   % Filter 2 (expected unstable)

% Display quick numerical info
fprintf('Filter 1 : Max |h[n]| = %.6g, |h[end]| = %.6g\n', max(abs(h1)), abs(h1(end)));
fprintf('Filter 2 : Max |h[n]| = %.6g, |h[end]| = %.6g\n', max(abs(h2)), abs(h2(end)));
fprintf('Filter 3 : Max |h[n]| = %.6g, |h[end]| = %.6g\n', max(abs(h3)), abs(h3(end)));
% Plot impulse responses
figure;

subplot(3,1,1);
h1s = stem(n, h1, 'filled');
set(h1s, 'MarkerSize', 3);     % Make markers smaller (default ≈ 6)
grid on;
title('Impulse Response — Filter 1');
xlabel('n');
ylabel('h_1[n]');
xlim([0 70]);
ylim([-0.25 0.5]);

subplot(3,1,2);
h2s = stem(n, h2, 'filled');
set(h2s, 'MarkerSize', 3);
grid on;
title('Impulse Response — Filter 2');
xlabel('n');
ylabel('h_2[n]');
xlim([0 70]);
ylim([-2.5*10^10 10*10^10]);

subplot(3,1,3);
h3s = stem(n, h3, 'filled');
set(h3s, 'MarkerSize', 3);
grid on;
title('Impulse Response — Filter 2');
xlabel('n');
ylabel('h_3[n]');
xlim([0 70]);
ylim([-10*10^10 10*10^10]);

% OPTIONAL: Semilog plot to highlight decay/growth
figure;

subplot(2,1,1);
semilogy(n, abs(h1) + eps);
grid on;
title('|h_1[n]| (semilog) — Filter 1');
xlabel('n');
ylabel('|h_1[n]|');

subplot(2,1,2);
semilogy(n, abs(h2) + eps);
grid on;
title('|h_2[n]| (semilog) — Filter 2');
xlabel('n');
ylabel('|h_2[n]|');

% Notes:
% - Stable filter: impulse response decays → |h[n]| → 0
% - Unstable filter: impulse response grows or oscillates without decay
