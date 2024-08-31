clear all;
clear global;

pkg load signal;

window_time = 1.024e-3;
Fs = 100e6;
timebase = linspace(0,window_time, (Fs * window_time));

% In Hz
IF = 1e6;   % Intermediate Freq
MF = 5e3;   % Message Freq
FC = 10e6;  % Carrier Center Freq


% Wave Generation
intermediate = sin(2.0 * pi * IF * timebase);
message = (0.25 * sin(2.0 * pi * MF * timebase)) + 0.75;
FLO = FC + IF - MF;
LO = sin(2.0 * pi * FLO * timebase);

% Create IF and Bandpass Filter
IF_s = intermediate .* message;

IFTAPS = 1;
IF_Passband_W = 500e3;
IF_Wl = ( (IF - IF_Passband_W / 2) / (Fs / 2) );
IF_Wh = ( (IF + IF_Passband_W / 2) / (Fs / 2) );

[IF_B, IF_A] = butter(IFTAPS, [IF_Wl, IF_Wh]);
IF_s_f = filter(IF_B, IF_A, IF_s);

% Create RF Out and Bandpass Filter
Rf_out = LO .* IF_s;

RFTAPS = 1;
RF_Passband_W = 250e3;
RF_Wl = ( (FC - RF_Passband_W / 2) / (Fs / 2) );
RF_Wh = ( (FC + RF_Passband_W / 2) / (Fs / 2) );

[RF_B, RF_A] = butter(RFTAPS, [RF_Wl, RF_Wh]);
RF_s_f = filter(RF_B, RF_A, Rf_out);

% Generate output filter

ifFFT = real(fft(IF_s_f));
outFFT = real(fft(RF_s_f));

% Cut down for FFT without reflection
ifFFT = ifFFT(1:length(ifFFT) / 2);
outFFT = outFFT(1:length(outFFT) / 2);

fftXf = linspace(0, Fs / 2, length(ifFFT));

% Cut down so you can actually see things on the plot
SCF = 4;
ifFFT = ifFFT(1:length(ifFFT) / SCF);
outFFT = outFFT(1:length(outFFT) / SCF);
fftXf = fftXf(1:length(fftXf) / SCF);

% Get ready for plotting output filter
[h, w] = freqz(RF_B, RF_A);
h = real(h);
hh = real(fft(h));
freqX = linspace(0, Fs / 2, length(h));

h = h(1:length(h) / SCF);
hh = hh(1:length(hh) / (2 * SCF));
freqX = freqX(1:length(freqX) / SCF);
freqXhh = freqX(1:length(freqX) / 2);

hold on;
subplot(3,2,1,"align"); plot(fftXf, outFFT); title("RF Out FFT");
subplot(3,2,2,"align"); plot(Rf_out); title("RF Out(t)");
subplot(3,2,3,"align"); plot(fftXf, ifFFT); title("IF FFT");
subplot(3,2,4,"align"); plot(IF_s_f); title("IF (t)");
subplot(3,2,5,"align"); plot(freqX, h); title("RF Filter Response");
subplot(3,2,6,"align"); plot(freqXhh, hh); title("RF Filter ???");
hold off;
