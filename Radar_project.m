clc; clear; close all;

% Radar Specifications 

freq_op     = 77e9;     % 77 GHz
max_range   = 200;      % m
range_resol = 1;        % m
max_vel     = 100;      % m/s 

c  = 3e8;               % speed of light
fc = freq_op;           % carrier


% Target Initial Range & Velocity

R0 = 110;     % initial range (m)
v  = -20;     % velocity (m/s)

% FMCW Waveform Design

B       = c / (2*range_resol);             % bandwidth
T_chirp = 5.5 * (2*max_range/c);           % chirp time
slope   = B / T_chirp;                     % chirp slope

fprintf("FMCW:\nB = %.2f MHz\nTchirp = %.2f us\nSlope = %.2e Hz/s\n\n", ...
    B/1e6, T_chirp*1e6, slope);


% Sampling Parameters

Nd = 128;        % number of chirps (Doppler cells)
Nr = 1024;       % samples per chirp (Range cells)

t = linspace(0, Nd*T_chirp, Nr*Nd);   % total time

Tx  = zeros(1, length(t));
Rx  = zeros(1, length(t));
Mix = zeros(1, length(t));

r_t = zeros(1, length(t));
td  = zeros(1, length(t));

% Signal Generation + Target Motion

for i = 1:length(t)

    % Target range vs time (constant velocity)
    r_t(i) = R0 + v*t(i);

    % Round trip time delay
    td(i) = 2*r_t(i)/c;

    % Transmit signal
    Tx(i) = cos(2*pi*( fc*t(i) + (slope*t(i)^2)/2 ));

    % Receive signal (time delayed)
    tdel  = t(i) - td(i);
    Rx(i) = cos(2*pi*( fc*tdel + (slope*(tdel^2))/2 ));

    % Beat signal (Mix / Dechirp)
    Mix(i) = Tx(i) .* Rx(i);
end


% RANGE FFT (1D FFT)

Mix_reshaped = reshape(Mix, [Nr, Nd]);

sig_fft = fft(Mix_reshaped, Nr, 1);     % FFT along range dimension
sig_fft = abs(sig_fft/Nr);              % normalize and magnitude

sig_fft_1side = sig_fft(1:Nr/2, :);     % keep one side

% Plot range FFT 
figure('Name','Range from First FFT');
plot(sig_fft_1side(:,1));   
xlabel('Range Bin');
ylabel('Normalized Magnitude');
title('The 1st FFT output (Range)');
grid on;
axis([0 200 0 1]);          


% RANGE DOPPLER MAP (2D FFT)

sig_fft2 = fft2(Mix_reshaped, Nr, Nd);

sig_fft2 = sig_fft2(1:Nr/2, 1:Nd);      
sig_fft2 = fftshift(sig_fft2);          

RDM = abs(sig_fft2);
RDM = 10*log10(RDM + eps);             

% Course-style axes
doppler_axis = linspace(-100, 100, Nd);
range_axis   = linspace(-200, 200, Nr/2);

figure('Name','2D FFT output - Range Doppler Map');
surf(doppler_axis, range_axis, RDM);
xlabel('Velocity (m/s)');
ylabel('Range (m)');
zlabel('Power (dB)');
title('2D FFT output - Range Doppler Map');
shading interp;
colorbar;
view(3);  

% 2D CA-CFAR

Tr = 12; Td = 14;     % training cells (range, doppler)
Gr = 6;  Gd = 8;      % guard cells (range, doppler)
offset = 5;           % SNR offset in dB 

[NR, ND] = size(RDM);
CFAR = zeros(NR, ND);

% Correct number of training cells
numTraining = (2*(Tr+Gr)+1)*(2*(Td+Gd)+1) - (2*Gr+1)*(2*Gd+1);


for i = (Tr+Gr+1) : (NR-(Tr+Gr))
    for j = (Td+Gd+1) : (ND-(Td+Gd))

        % Outer window (training + guard + CUT)
        outer = RDM(i-(Tr+Gr):i+(Tr+Gr), j-(Td+Gd):j+(Td+Gd));

        % Inner window (guard + CUT)
        inner = RDM(i-Gr:i+Gr, j-Gd:j+Gd);

        % Convert dB to power
        outer_pow = db2pow(outer);
        inner_pow = db2pow(inner);

        % Noise power (training cells only)
        noise_pow = sum(outer_pow,'all') - sum(inner_pow,'all');

        % Average noise and convert back to dB
        noise_pow_avg = noise_pow / numTraining;
        threshold = pow2db(noise_pow_avg) + offset;

        % CUT compare
        CUT = RDM(i,j);

        if CUT > threshold
            CFAR(i,j) = 1;
        else
            CFAR(i,j) = 0;
        end
    end
end

%% Plot CFAR 
figure('Name','The output of the 2D CFAR process');
surf(doppler_axis, range_axis, CFAR);
xlabel('Velocity (m/s)');
ylabel('Range (m)');
zlabel('CFAR Output');
title('The output of the 2D CFAR process');
shading interp;
colorbar;
view(3);  
