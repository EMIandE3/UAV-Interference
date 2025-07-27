% function [f,alpha,CS] = CycSpecFft(x,MapN,fs,M)
% Calculate the Cyclic Spectrum by FFT
% ----------------------------------------------
% Input:
%   x:      signal sequence
%   MapN:   the size of output cyclic spectrum
%   fs:     sample rate
%   M:      smooth length in frequency spectrum, should be even
% Output:
%   f:      frequency meshgrid of cyclic spectrum (size: (MapN+1)*(MapN+1))
%   alpha:  cyclic frequency meshgrid of cyclic spectrum (size: (MapN+1)*(MapN+1))
%   CS:     cyclic spectrum (size: (MapN+1)*(MapN+1))
%  ----------------------------------------------
% Version 2023-11-26 最终版
%

function [f,alpha,CS] = Copy_of_CycSpecFft_Revised(x,MapN,fs,M)
span = lcm(MapN,length(x));  %找FFT长度和循环频率长度的最小公倍数
spanRate = span/(MapN);

X0 = fft(x,span)/sqrt(length(x));
X = zeros(1,MapN);
for i = 1:MapN
    X(i) = X0(1+(i-1)*spanRate); %以循环频率长度为标准，对FFT结果进行抽取
end
[f,alpha]=meshgrid(-fs/2:fs/MapN:0,-fs/2:fs/2/MapN*4:0); %此处为频率-循环频率的尺度标定
CS = zeros(MapN/4+1,MapN/2+1);
for index_a = 0:1:MapN/4  %由于0~MapN/2和MapN/2~MapN为共轭对称的，再结合循环频率自身的对称性，为减小运算量，故只分析0~MapN/4片段
    if ((M>1) && (mod(M,2) == 0))
        for m = -M:1:M
            X1 = [X(mod(m+round(MapN/4)+index_a,MapN)+1:end),X(1:mod(m+round(MapN/4)+index_a,MapN))]; %循环移位，须满足X1、X2中心为f0，且X1、X2相距alpha
            X2 = [X(mod(m-round(MapN/4)-index_a,MapN)+1:end),X(1:mod(m-round(MapN/4)-index_a,MapN))];
            X1_down_rate = zeros(1,MapN/2+1);
            X2_down_rate = zeros(1,MapN/2+1);
            for i = 1:MapN/2  %由于频谱的共轭对称性，此处考虑到减小计算量，因此只取一半的点分析
                X1_down_rate(i) = X1(i);
                X2_down_rate(i) = X2(i);
            end
            CS(index_a+1,:) = CS(index_a+1,:) + 1/(M+1) * X1_down_rate.*conj(X2_down_rate); %对循环分量进行平滑以及共轭相乘
        end
    else
        X1 = [X(mod(round(MapN/4)+index_a,MapN)+1:end),X(1:mod(round(MapN/4)+index_a,MapN))];
        X2 = [X(mod(round(MapN/4)-index_a,MapN)+1:end),X(1:mod(round(MapN/4)-index_a,MapN))];
        X1_down_rate = zeros(1,MapN/2+1);
        X2_down_rate = zeros(1,MapN/2+1);
        for i = 1:MapN/2
            X1_down_rate(i) = X1(i);
            X2_down_rate(i) = X2(i);
        end
        CS(index_a+1,:) = CS(index_a+1,:) + X1_down_rate.*conj(X2_down_rate);
    end
end
