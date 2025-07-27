% 设计参数
Fs = 1/3.5e-9; % 采样率
Fpass = [29e6 30e6]; % 通带截止频率
Fstop = [28e6 31e6]; % 阻带截止频率
dev = [60 0.05 60]; % 通阻带波动
[n, Wn] = kaiserord([Fstop(1) Fpass Fstop(2)], [0 1 0], dev, Fs); % 计算阶数和归一化截止频率
% 窗函数类型 = 'kaiser'; % 可选 'hamming', 'blackman' 等

% 生成系数
b = fir1(n, Wn, 'bandpass', window(@kaiser, n+1)); % 注意窗函数长度需为n+1
[h,w] = freqz(b, 1, 2048); % 验证频率响应

figure
plot(w*Fs/(2*pi), abs(h))


%% 画出滤波后的频谱图


Signal_filter = reshape(out.sending_modulation_wave.Data,1,[]);

Signal_filter = Signal_filter(1:length(out.sending_modulation_wave.Time));

N_length = length(Signal_filter);
Fs2 = Fs*1;
freq = -Fs2/2:Fs2/N_length:Fs2/2-Fs2/N_length;
figure;
plot(real(Signal_filter))

figure;
plot(freq, abs(fftshift(fft(Signal_filter))))




