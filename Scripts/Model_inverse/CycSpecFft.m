%% date:2023/12/05
%% purpose: 循环谱代码：频域计算改进法（频域算法,对信号做FFT补零操作以及对频谱2抽取操作）
%% 参考文献: [1] 李创, 基于循环谱的调制识别和参数估计, 2021, 重庆大学.
%%           [2] 魏阳杰，基于循环谱的调制样式识别与参数估计，2015，电子科技大学
%%           [3] 马国宁，高效循环谱估计算法的研究及其应用，2006，电子科技大学
%% function:输入：x:      signal sequence
%%                MapN:   the size of output cyclic spectrum
%%                fs:     sample rate
%%                M:      smooth length in frequency spectrum, should be even
%%          输出：f:      frequency meshgrid of cyclic spectrum (size: (MapN+1)*(MapN+1))
%%                alpha:  cyclic frequency meshgrid of cyclic spectrum (size: (MapN+1)*(MapN+1))
%%                CS:     cyclic spectrum (size: (MapN+1)*(MapN+1))
%% debug:
%% 

function [f,alpha,CS] = CycSpecFft(x,MapN,fs,M)
span = lcm(2*MapN,2*length(x)); %找补0后FFT长度和循环频率长度的最小公倍数
spanRate = span/(2*MapN);
X0 = fft(x,span)/sqrt(length(x));
X = zeros(1,2*MapN);
for i = 1:2*MapN
    X(i) = X0(1+(i-1)*spanRate); %以循环频率长度为标准，对FFT结果进行抽取
end
[f,alpha]=meshgrid(-fs/2:fs/MapN:fs/2,-fs/2:fs/MapN:fs/2); %此处为频率-循环频率的尺度标定
CS = zeros(MapN+1,MapN+1);
for index_a = 0:MapN %由于下述循环中运用了频谱2抽取，故只分析0~MapN片段
    if ((M>1) && (mod(M,2) == 0))
        for m = -M:2:M
            X1 = [X(mod(m+round(MapN/2)+index_a,2*MapN)+1:end),X(1:mod(m+round(MapN/2)+index_a,2*MapN))]; %循环移位，须满足X1、X2中心为f0，且X1、X2相距alpha
            X2 = [X(mod(m-round(MapN/2)-index_a,2*MapN)+1:end),X(1:mod(m-round(MapN/2)-index_a,2*MapN))];
            X1_down_rate = zeros(1,MapN+1);
            X2_down_rate = zeros(1,MapN+1);
            for i = 1:MapN  %对频谱2抽取，从而式频域频率适应24行的尺度标定，但也会增大栅栏效应问题
                X1_down_rate(i) = X1(2*i-1);
                X2_down_rate(i) = X2(2*i-1);
            end
            CS(index_a+1,:) = CS(index_a+1,:) + 1/(M+1) * X1_down_rate.*conj(X2_down_rate);
        end
    else
        X1 = [X(mod(round(MapN/2)+index_a,2*MapN)+1:end),X(1:mod(round(MapN/2)+index_a,2*MapN))];
        X2 = [X(mod(-round(MapN/2)-index_a,2*MapN)+1:end),X(1:mod(-round(MapN/2)-index_a,2*MapN))];
        X1_down_rate = zeros(1,MapN+1);
        X2_down_rate = zeros(1,MapN+1);
        for i = 1:MapN
            X1_down_rate(i) = X1(2*i-1);
            X2_down_rate(i) = X2(2*i-1);
        end
        CS(index_a+1,:) = CS(index_a+1,:) + X1_down_rate.*conj(X2_down_rate);
    end
end
