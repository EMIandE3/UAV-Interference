%% date:2023/12/21
%% purpose: 仿真OFDM信号的原理，该OFDM仿真包含的主要步骤为：二进制序列生成、串并转换、差分编码、IFFT变换、加窗、并串转换、经过信道、接收端对应解调
%% 参考文献: https://blog.csdn.net/qq_42595610/article/details/118194384?ops_request_misc=%257B%2522request%255Fid%2522%253A%2522169668166816800227426045%2522%252C%2522scm%2522%253A%252220140713.130102334..%2522%257D&request_id=169668166816800227426045&biz_id=0&utm_medium=distribute.pc_search_result.none-task-blog-2~all~sobaiduend~default-2-118194384-null-null.142^v95^insert_down28v1&utm_term=ofdm%E4%BB%BF%E7%9C%9F&spm=1018.2226.3001.4187
%% function:输入：
%%          输出：
%% debug:

% clear all;
% close all;
% clc
% set(0,'defaultfigurecolor','w') 
function [Tx_data] = OFDM__Simulate(IFFT_bin_length, carrier_count, bits_per_symbol, symbols_per_carrier, fs, fc)
%% 参数输入
% IFFT_bin_length = 1024;    % FFT的点数
% carrier_count = 200;       % 载波的数量 
% bits_per_symbol = 2;       % 每个符号代表的比特数
% symbols_per_carrier = 50;  % 每个载波使用的符号数                         
baseband_out_length = carrier_count*symbols_per_carrier*bits_per_symbol;  %总比特数
carriers = (1:carrier_count) + (floor(IFFT_bin_length/4) - floor(carrier_count/2));
conjugate_carriers = IFFT_bin_length - carriers + 2;

%% 发送端>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
[modulo_baseband, baseband_out] = BinaryDataGeneration(baseband_out_length, bits_per_symbol); %产生随机二进制数据:
carrier_matrix = reshape(modulo_baseband, carrier_count, symbols_per_carrier)'; % 串并转换
complex_carrier_matrix = DifferentialCoding(carrier_matrix, carrier_count, symbols_per_carrier, bits_per_symbol); % 对每一个载波的符号进行差分编码
IFFT_modulation = IfftModulationPosition(complex_carrier_matrix, carriers, conjugate_carriers, symbols_per_carrier, IFFT_bin_length); % 分配载波到指定的IFFT位置
% Draw(1, 0:IFFT_bin_length-1, abs(IFFT_modulation(2,1:IFFT_bin_length)), 'b*-', 'IFFT Bin', 'Magnitude', 'OFDM Carrier Frequency Magnitude'); % 画出频域中的OFDM信号代表
% Draw(2, 0:IFFT_bin_length-1, (180/pi)*angle(IFFT_modulation(2,1:IFFT_bin_length)), 'go', 'IFFT Bin', 'Phase (degrees)', 'OFDM Carrier Phase');
time_wave_matrix = ifft(IFFT_modulation')'; % 通过IFFT将频域转化为时域，得到时域信号
% Draw(3, 0:IFFT_bin_length-1, time_wave_matrix(2,:), 'b-', 'IFFT Bin', 'Phase (degrees)', 'OFDM Carrier Phase'); %画出一个符号周期的时域OFDM信号
% DrawEveryCarrier(IFFT_modulation, carriers, conjugate_carriers, carrier_count, IFFT_bin_length); %画出每一个载波对应的时域信号（分离的OFDM信号）
windowed_time_wave_matrix = AddWindows(time_wave_matrix, symbols_per_carrier, IFFT_bin_length); %加窗
ofdm_modulation = reshape(windowed_time_wave_matrix',1,IFFT_bin_length*(symbols_per_carrier+1)); %并串转换
% 画出整个时域OFDM
temp_time = IFFT_bin_length*(symbols_per_carrier+1);
 
% 画出频域OFDM信号
% freq = (0:length(ofdm_modulation)-1)/length(ofdm_modulation);
% ofdm_modulation_fft = abs(fft(ofdm_modulation));
% Draw(6, freq, ofdm_modulation_fft, 'b-', 'Normalized Frequency(0.5 = fs/2)', 'Magnitude/dB', 'OFDM Signal Spectrum'); 

% 上变频，这个模型中我们把经过IFFT运算后OFDM直接发送
t = (0:temp_time-1)*1/fs;
modulation_carrier = cos(2*pi*fc*t);
Tx_data = ofdm_modulation.*modulation_carrier;
Tx_data = Tx_data/max(ofdm_modulation);
% Draw(5, (0:temp_time-1)*1/fs, Tx_data, 'b-', 'Time/Samples', 'Amplitude/Volts', 'OFDM Time Signal');

%% 以下为用户封装函数
%产生随机二进制数据
function [modulo_baseband, baseband_out] = BinaryDataGeneration(baseband_out_length, bits_per_symbol)
baseband_out = round(rand(1,baseband_out_length));
convert_matrix = reshape(baseband_out,bits_per_symbol,length(baseband_out)/bits_per_symbol);
for k = 1:(baseband_out_length/bits_per_symbol)
    modulo_baseband(k) = 0;
    for i = 1:bits_per_symbol
        modulo_baseband(k)=modulo_baseband(k)+convert_matrix(i,k)*2^(bits_per_symbol-i); %将每一个符号由2进制转换为10进制
    end
end
end

%差分编码
function complex_carrier_matrix = DifferentialCoding(carrier_matrix, carrier_count, symbols_per_carrier, bits_per_symbol)
carrier_matrix = [zeros(1,carrier_count);carrier_matrix];
for i = 2:(symbols_per_carrier + 1)
    carrier_matrix(i,:)=rem(carrier_matrix(i,:)+carrier_matrix(i-1,:),2^bits_per_symbol);
end
carrier_matrix = carrier_matrix * ((2*pi)/(2^bits_per_symbol)); % 把差分符号代码转换成相位
[X,Y] = pol2cart(carrier_matrix, ones(size(carrier_matrix,1),size(carrier_matrix,2))); % 把相位转换成复数
complex_carrier_matrix = complex(X,Y);
end

%IFFT调制位置确定
function IFFT_modulation = IfftModulationPosition(complex_carrier_matrix, carriers, conjugate_carriers, symbols_per_carrier, IFFT_bin_length)
IFFT_modulation = zeros(symbols_per_carrier + 1, IFFT_bin_length);
IFFT_modulation(:,carriers) = complex_carrier_matrix;
IFFT_modulation(:,conjugate_carriers) = conj(complex_carrier_matrix);
end

%画图函数
function Draw(FigNum, X_Data, Y_Data, Str_Choose, Str_Xlabel, Str_Ylabel, Str_Title)
figure(FigNum)
plot(X_Data, Y_Data, Str_Choose)
xlabel(Str_Xlabel)
ylabel(Str_Ylabel)
title(Str_Title)
grid on
end

%专用画图函数
function DrawEveryCarrier(IFFT_modulation, carriers, conjugate_carriers, carrier_count, IFFT_bin_length)
for f = 1:carrier_count
    temp_bins(1:IFFT_bin_length)=0+0j;
    temp_bins(carriers(f))=IFFT_modulation(2,carriers(f));
    temp_bins(conjugate_carriers(f))=IFFT_modulation(2,conjugate_carriers(f));
    temp_time = ifft(temp_bins');
    Draw(4, 0:IFFT_bin_length-1, temp_time, 'b-', 'Time', 'Amplitude', 'Separated Time Waveforms Carriers');
    %    pause(0.1);
    %    hold on
end
end

%加窗
function windowed_time_wave_matrix = AddWindows(time_wave_matrix, symbols_per_carrier, IFFT_bin_length)
for i = 1:symbols_per_carrier + 1
    windowed_time_wave_matrix(i,:)=real(time_wave_matrix(i,:)).*hamming(IFFT_bin_length)';
    windowed_time_wave_matrix(i,:) = real(time_wave_matrix(i,:));
end
end
end
