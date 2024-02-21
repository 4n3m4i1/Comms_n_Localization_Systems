clear all;
clear global;

pkg load signal;

function retval = decode_sym(sym)
  if(sym > 0.2 && sym < 0.4) retval = 3;
  elseif(sym > 0 && sym < 0.2) retval = 2;
  elseif(sym < 0 && sym > -0.2) retval = 1;
  elseif(sym < 0.2 && sym > -0.4) retval = 0;
  else retval = 0;
  endif
endfunction


os_rate = 5;
fc = 100e3;
wc = 2 * pi * fc;
fs = fc * os_rate;
sampling_interval = 1 / fs;

runtime = 0.010;
% start : step : end
timebase = sampling_interval : sampling_interval : runtime;

sincarrier = sin(timebase * wc);
coscarrier = cos(timebase * wc);

% 10kSym/s
datarate = 10e3;

num_symbols = runtime * datarate;
num_symbols
% Send increasing symbols
data = zeros(num_symbols, 1);
% Create symbols bounded 0 - 15 for 4x4 constellation
for n = 1:num_symbols
  data(n) = mod(n,16);
endfor

I = ones(size(timebase));
Q = ones(size(timebase));

size(I)

time_per_sym = length(timebase) / num_symbols;

m = 1;
for n = 1:length(timebase)
  I(n) = bitshift(data(m), -2) * I(n);
  Q(n) = bitand(0x03, data(m)) * Q(n);
  if(mod(n, time_per_sym) == 0)
    m = m + 1;
  endif
endfor
printf("M = %d\n",m);

I = I ./ 3;
I = I - 0.5;
Q = Q ./ 3;
Q = Q - 0.5;

IF_I = I .* sincarrier;
IF_Q = Q .* coscarrier;

RFOUT = IF_I + IF_Q;

%plot(RFOUT);

IF_I = RFOUT .* sincarrier;
IF_Q = RFOUT .* coscarrier;

%subplot(1,1,1,"align");
%plot(IF_I);
%title("IF_I");
%subplot(1,1,2,"align");
%plot(IF_Q);
%title("IF_Q");

lpftaps = fir1(256, 0.5);
freqz(lpftaps);

DEMOD_I = filter(lpftaps, 1, IF_I);
DEMOD_Q = filter(lpftaps, 1, IF_Q);

plot(DEMOD_Q, DEMOD_I, "o");

rxdat = zeros(1, num_symbols);

m = 1;
for n = 1:length(timebase)
  if(mod(n, time_per_sym) == time_per_sym / 2)
    di = decode_sym(DEMOD_I(n));
    dq = decode_sym(DEMOD_Q(n));
    %printf("val: %f %f\tDecoded: %d %d\n", DEMOD_I(n), DEMOD_Q(n), di, dq);
    rxdat(m) = bitor( bitshift(di, 2) , dq);
    m = m + 1;
  endif
endfor

matches = nnz(rxdat == data);
pctmatch = (matches / num_symbols) * 100;

printf("%d Symbol Matches out of %d sent, a %f success rate!\n", matches, num_symbols, pctmatch);


