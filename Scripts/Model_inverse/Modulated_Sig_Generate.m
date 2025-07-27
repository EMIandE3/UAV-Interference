%% date:2023/12/04
%% purpose: 生成各种调制信号
%% 参考文献: [1] 
%%           [2] 
%%           [3] 
%% function:输入：
%%          输出：
%% debug:

function [s] = Modulated_Sig_Generate(modulatedType, fs, Rs, fc, M, t_end)  %默认结束时间为1

%% Part1： 幅度调制
if modulatedType == "BASK" %% BASK调制
    t=0:1/fs:t_end-1/fs;   %1s，一秒传10bit的信号
    code_num = ceil(Rs);
    a=randi([0,1],1,code_num); %10个随机数 非0即1
    s=a(ceil(code_num*t+1/fs/Rs)).*cos(2*pi*fc*t);%调制信号

%     figure;
%     subplot(211);
%     plot(t,a(ceil(code_num*t+1/fs/Rs)));
%     axis([0,1-1/fs,-0.2,1.2]);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('二进制码元时域波形');
%     
%     subplot(212);
%     plot(t,s);
%     axis([0,1-1/fs,-1.2,1.2]);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');

elseif modulatedType == "MASK"  %% MASK调制
%     M = 4;

    t=0:1/fs:t_end-1/fs;
    code_num = ceil(Rs);   %二进制bit的码元速率
    a=randi(M,1,code_num)-1;    %产生随机比特流 限制幅度最大为2
    s=a(ceil(code_num*t+1/fs/Rs)).*cos(2*pi*fc*t);

%     L=2^(nextpow2(length(s)));
%     f=(-L/2:L/2-1)*(fs/L);
%     S=fft(s,L);
%     P=abs(fftshift(S)).^2;

%     figure;
%     subplot(311);
%     plot(t,a(ceil(code_num*t+1/fs/Rs)));
%     axis([0,1,-0.3,M+0.3])
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('M进制码元时域波形');
% 
%     subplot(312);
%     plot(t,s);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');
% 
%     subplot(313);
%     plot(f,P);
%     xlabel('f/Hz');
%     ylabel('magnitude');
%     title('调制信号功率谱函数');

elseif modulatedType == "QAM"     %% QAM调制

    t=0:1/fs:t_end-1/fs;
    code_num = ceil(Rs); 
    if mod(code_num,2) == 1
        code_num = code_num +1;
    end

    %脉冲
    a=randi(2,1,2*code_num)-1;
    %幅度分量
    Ai=2*a(1:2:code_num)-1;
    Aq=2*a(2:2:code_num)-1;
    %调制
    s=Ai(ceil((code_num*t+1/fs/Rs)/2)).*cos(2*pi*fc*t)...
        +Aq(ceil((code_num*t+1/fs/Rs)/2)).*sin(2*pi*fc*t);

%     figure;
%     subplot(221)
%     plot(t,Ai(ceil((code_num*t+1/fs/Rs)/2)));
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('i路二进制码元时域波形');
% 
%     subplot(222)
%     plot(t,Aq(ceil((code_num*t+1/fs/Rs)/2)));
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('q路二进制码元时域波形');
% 
%     subplot(2,2,3)
%     plot(t,a(ceil(code_num*t+1/fs/Rs)));
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('二进制码元整体时域波形');
% 
%     subplot(224);
%     plot(t,s);%QAM波形
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');
% %     scatterplot(Ai+1j*Aq);%QAM星座图

    elseif modulatedType == "MQAM"     %% QAM调制

    t=0:1/fs:t_end-1/fs;
    code_num = ceil(Rs); 
    if mod(code_num,2) == 1
        code_num = code_num +1;
    end

    %脉冲
    a=randi(M,1,2*code_num)-1;
    %幅度分量
    Ai=2*a(1:2:code_num)-1;
    Aq=2*a(2:2:code_num)-1;
    %调制
    s=Ai(ceil((code_num*t+1/fs/Rs)/2)).*cos(2*pi*fc*t)...
        +Aq(ceil((code_num*t+1/fs/Rs)/2)).*sin(2*pi*fc*t);

%     L=2^(nextpow2(length(s)));
%     f=(-L/2:L/2-1)*(fs/L);
%     S=fft(s,L);
%     P=abs(fftshift(S)).^2;

%     figure;
%     subplot(221)
%     plot(t,Ai(ceil((code_num*t+1/fs/Rs)/2)));
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('i路M进制码元时域波形');
% 
%     subplot(222)
%     plot(t,Aq(ceil((code_num*t+1/fs/Rs)/2)));
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('q路M进制码元时域波形');
% 
%     subplot(223);
%     plot(t,s);%QAM波形
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');
%     
%     subplot(224);
%     plot(f,P);
%     xlabel('f/Hz');
%     ylabel('magnitude');
%     title('调制信号功率谱函数');
% %     scatterplot(Ai+1j*Aq);%QAM星座图

%% Part2： 频率调制
elseif modulatedType == "BFSK"     %% BFSK调制

    t = 0:1/fs:t_end-1/fs;
    df=100;%频偏
    code_num = ceil(Rs); 
    a=randi(2,1,code_num)-1;
    m=a(ceil(code_num*t+1/fs/Rs));
    s=cos(2*pi*(fc+m*df).*t);%f0=50Hz

%     L=2^(nextpow2(length(s)));
%     f=(-L/2:L/2-1)*(fs/L);
%     S=fft(s,L);
%     P=abs(fftshift(S)).^2;

%     figure;
%     subplot(311)
%     plot(t,a(ceil(code_num*t+1/fs/Rs)));
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('二进制码元时域波形');
% 
%     subplot(312)
%     plot(t,s);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');
% 
%     subplot(313);
%     plot(f,P);
%     xlabel('f/Hz');
%     ylabel('magnitude');
%     title('调制信号功率谱函数');

elseif modulatedType == "MFSK"    %% MFSK调制
    df = 1000;
%     M = 4;

    t=0:1/fs:t_end-1/fs;
    code_num = ceil(Rs); 
    a=randi(M,1,code_num)-1;
    m=a(ceil(code_num*t+1/fs/Rs));
    s=cos(2*pi*(fc+m*df).*t);

%     L=2^(nextpow2(length(s)));
%     f=(-L/2:L/2-1)*(fs/L);
%     S=fft(s,L);
%     P=abs(fftshift(S)).^2;

%     figure;
%     subplot(311)
%     plot(t,m);
%     axis([0,1,-0.3,M+0.3]);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('M进制码元时域波形');
% 
%     subplot(312)
%     plot(t,s);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');
% 
%     subplot(313);
%     plot(f,P)
%     xlabel('f/Hz');
%     ylabel('magnitude');
%     title('调制信号功率谱函数');

elseif modulatedType == "MSK"     %% BFSK调制

    t = 0:1/fs:t_end-1/fs;
    df=Rs/4;%频偏
    code_num = ceil(Rs); 
    a=randi(2,1,code_num)-1;

    fai_flag_fuzhu = zeros(1,code_num);
    fai_flag_fuzhu(2:2:end) = 1;

    m=a(ceil(code_num*t+1/fs/Rs))*2-1;
    m_fuzhu = fai_flag_fuzhu(ceil(code_num*t+1/fs/Rs));

    fai_flag = [0 abs(diff(m))/2];
    fai_flag_1 = find(fai_flag == 1);
    for i=1:length(fai_flag_1)
        fai_flag(fai_flag_1(i):fai_flag_1(i)+fix(1/Rs*fs)-1)  = 1;
    end
    if length(fai_flag) ~= length(m_fuzhu)
        fai_flag(end) = [];
    end

    fai_flag = fai_flag & m_fuzhu;
    
    s = cos(2*pi*(fc+m*df).*t + fai_flag*pi);%f0=50Hz

%     L=2^(nextpow2(length(s)));
%     f=(-L/2:L/2-1)*(fs/L);
%     S=fft(s,L);
%     P=abs(fftshift(S)).^2;

%     figure;
%     subplot(311)
%     plot(t,a(ceil(code_num*t+1/fs/Rs)));
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('二进制码元时域波形');
% 
%     subplot(312)
%     plot(t,s);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');
% % 
%     subplot(313);
%     plot(f,P);
%     xlabel('f/Hz');
%     ylabel('magnitude');
%     title('调制信号功率谱函数');

%% Part3： 相位调制
elseif modulatedType == "BPSK"     %% BPSK调制

    t = 0:1/fs:t_end-1/fs;
    code_num = ceil(Rs); 
    a=randi(2,1,code_num)-1;
    m=a(ceil(code_num*t+1/fs/Rs));
    s=cos(2*pi*fc*t+m*pi);

%     L=2^(nextpow2(length(s)));
%     f=(-L/2:L/2-1)*(fs/L);
%     S=fft(s,L);
%     P=abs(fftshift(S)).^2;

%     figure;
%     subplot(311)
%     plot(t,a(ceil(code_num*t+1/fs/Rs)));
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('二进制码元时域波形');
% 
%     subplot(312)
%     plot(t,s);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');
% 
%     subplot(313);
%     plot(f,P);
%     xlabel('f/Hz');
%     ylabel('magnitude');
%     title('调制信号功率谱函数');

elseif modulatedType == "QPSK"    %% QPSK调制
    t=0:1/fs:t_end-1/fs;
    code_num = ceil(Rs); 
    if mod(code_num,2) == 1
        code_num = code_num +1;
    end

    a=randi(2,1,code_num)-1;
    sym=a(1:2:code_num)+a(2:2:code_num);
    m=sym(ceil((code_num*t+1/fs/Rs)/2));

    M=4;  %调制
    s=cos(2*pi*fc*t+2*m*pi/M);

%     L=2^(nextpow2(length(s)));
%     f=(-L/2:L/2-1)*(fs/L);
%     S=fft(s,L);
%     P=abs(fftshift(S)).^2;
% 
%     figure;
%     subplot(311)
%     plot(t,a(ceil(code_num*t+1/fs/Rs)));
%     axis([0,1,-0.2,1.2]);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('二进制码元时域波形');
% 
%     subplot(312)
%     plot(t,s);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');
% 
%     subplot(313)
%     plot(f,P);
%     xlabel('f/Hz');
%     ylabel('magnitude');
%     title('调制信号功率谱函数');

elseif modulatedType == "OQPSK"   %% OQPSK调制

    t=0:1/fs:t_end-1/fs;
    TRs = 1/Rs;
    code_num = ceil(Rs); 
    if mod(code_num,2) == 1
        code_num = code_num +1;
    end

    a=randi(2,1,code_num);
    m=2*a-1;
    I=m(1:2:code_num);
    Q=m(2:2:code_num);
    I=[I(ceil((code_num*t+1/fs/Rs)/2)),ones(1,round(fs*TRs/2))];
    Q=[ones(1,round(fs*TRs/2)),Q(ceil((code_num*t+1/fs/Rs)/2))];

    t=0:1/fs:t_end-1/fs+round(fs*TRs/2)/fs;
    s=I.*cos(2*pi*fc*t)-Q.*sin(2*pi*fc*t);

%     L=2^(nextpow2(length(s)));
%     f=(-L/2:L/2-1)*(fs/L);
%     S=fft(s,L);
%     P=abs(fftshift(S)).^2;

%     figure;
%     subplot(411)
%     plot(t,I);
%     axis([0,1.05,-0.03,3.3])
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('i路二进制码元时域波形');
% 
%     subplot(412)
%     plot(t,Q);
%     axis([0,1.05,-0.3,3.3]);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('q路二进制码元时域波形');
% 
%     subplot(413)
%     plot(t,s);
%     axis([0,1.05 -inf inf])
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');
% 
%     subplot(414)
%     plot(f,P);
%     xlabel('f/Hz');
%     ylabel('magnitude');
%     title('调制信号功率谱函数');

    elseif modulatedType == "MPSK"     %% BPSK调制
%     M = 4;
    dp = pi/M;

    t = 0:1/fs:t_end-1/fs;
    code_num = ceil(Rs); 
    a=randi(M,1,code_num)-1;
    m=a(ceil(code_num*t+1/fs/Rs));
    s=cos(2*pi*fc*t+m*dp);

%     L=2^(nextpow2(length(s)));
%     f=(-L/2:L/2-1)*(fs/L);
%     S=fft(s,L);
%     P=abs(fftshift(S)).^2;

%     figure;
%     subplot(311)
%     plot(t,a(ceil(code_num*t+1/fs/Rs)));
%     axis([0,1,-0.3,M+0.3]);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('M进制码元时域波形');
% 
%     subplot(312)
%     plot(t,s);
%     xlabel('t/s');
%     ylabel('magnitude');
%     title('调制信号时域波形');
% 
%     subplot(313);
%     plot(f,P);
%     xlabel('f/Hz');
%     ylabel('magnitude');
%     title('调制信号功率谱函数');

 elseif modulatedType == "OFDM"     %% OFDM调制
     if Rs < 1e4
         bits_per_symbol = 2;       % 每个符号代表的比特数
         symbols_per_carrier = 50;  % 每个载波使用的符号数
         carrier_count = round(Rs/bits_per_symbol/symbols_per_carrier);       % 载波的数量
         IFFT_bin_length = 2^nextpow2(max((t_end*fs+1)/(symbols_per_carrier+1), 2*carrier_count) ); % FFT的点数
         s = OFDM__Simulate(IFFT_bin_length, carrier_count, bits_per_symbol, symbols_per_carrier, fs, fc); % modulatedType, fs, Rs, fc, M, t_end
     elseif Rs >= 1e4  && Rs < 1e7 
         bits_per_symbol = 16;       % 每个符号代表的比特数
         symbols_per_carrier = 100;  % 每个载波使用的符号数
         carrier_count = round(Rs/bits_per_symbol/symbols_per_carrier);       % 载波的数量
         IFFT_bin_length = 2^nextpow2(max((t_end*fs+1)/(symbols_per_carrier+1), 2*carrier_count) ); % FFT的点数
         s = OFDM__Simulate(IFFT_bin_length, carrier_count, bits_per_symbol, symbols_per_carrier, fs, fc); % modulatedType, fs, Rs, fc, M, t_end
     else
         bits_per_symbol = 16;       % 每个符号代表的比特数
         symbols_per_carrier = 500;  % 每个载波使用的符号数
         carrier_count = round(Rs/bits_per_symbol/symbols_per_carrier);       % 载波的数量
         IFFT_bin_length = 2^nextpow2(max((t_end*fs+1)/(symbols_per_carrier+1), 2*carrier_count) ); % FFT的点数
         s = OFDM__Simulate(IFFT_bin_length, carrier_count, bits_per_symbol, symbols_per_carrier, fs, fc); % modulatedType, fs, Rs, fc, M, t_end
     end
    

end
s=s/max(s);
end














