%% =====> 噪声生器的初始化<========
%%全局参数
% Ts = model.Parameters.NoiseGen.NoiseTs;           %采样时间
% fs = 1/Ts;
%% 控制位
model.Parameters.NoiseGen.Control.Source;    % 噪声源的控制位：1，高斯白噪声
model.Parameters.NoiseGen.Control.Modulator; % 噪声源的调制方式控制位，默认为0. 0，调制器不工作 1,2AM调制方式 2，2PM调制方式 3，2FM调制方式
model.Parameters.NoiseGen.Control.Jamming;   % 噪声源的干扰方式控制位，默认为0. 0，干扰方式不工作
model.Parameters.NoiseGen.Type;              % 噪声源类型 默认:"高斯白噪声"
%% 噪声发生器模块参数初始化

%%%===干扰源参数===%%%
%===1.高斯白噪声===
model.Parameters.NoiseGen.GaussPower;
model.Parameters.NoiseGen.GaussSeed;
%===2.随机二元码调制噪声参数===%
model.Parameters.NoiseGen.RandBFZero;  % 二进制随机数的-1的概率       初始值：1e-4
model.Parameters.NoiseGen.RandBPFA ;   % 二进制随机调制噪声的幅度     初始值：1
model.Parameters.NoiseGen.RandBPFF ;   % 二进制随机调制噪声的频率     初始值：1e3
model.Parameters.NoiseGen.RandBPFF;    % 二进制随机调制噪声的初始相位 初始值: 0
%===3.单音参数===% 
model.Parameters.NoiseGen.SineNoiseA;    % 单音正弦噪声的幅度         初始值 1         
model.Parameters.NoiseGen.SineNoiseF;    % 单音正弦噪声的频率         初始值 1000
model.Parameters.NoiseGen.SineNoisePhi0; % 单音正弦噪声的初始相位     初始值 0
%===4.射频干扰噪声参数===%
model.Parameters.NoiseGen.RFNoiseFilterObj;  %滤波器结构体
model.Parameters.NoiseGen.RFNoisePower;      %射频干扰噪声的功率    
model.Parameters.NoiseGen.RFNoiseSeed;       %射频干扰噪声的随机数种子
%===5.PN码MSK噪声参数===%
model.Parameters.NoiseGen.PNMSKPolynomial;   %PN码的生成器多项式，决定了PN码的周期
model.Parameters.NoiseGen.PNMSKInitialstate; %PN码生成器的初始状态
model.Parameters.NoiseGen.PNMSKM;            %MSK每个符号的样本数
model.Parameters.NoiseGen.PNMSKF;            %MSK的中心频率
model.Parameters.NoiseGen.PNMSKPhi0;         %MSK的初始相位

%%%===调制方式参数===%%%
%===1.AM调制参数===%
model.Parameters.NoiseGen.Modulator.AMA;       %AM调制的幅度
model.Parameters.NoiseGen.Modulator.AMF;       %AM调制的高频载波频率
model.Parameters.NoiseGen.Modulator.carrier_lower_freq;  %AM调制信号的频率
model.Parameters.NoiseGen.Modulator.Ma         %AM调制的调幅度

%===2.PM调制参数===%
model.Parameters.NoiseGen.Modulator.PMA;       %PM调制的幅度
model.Parameters.NoiseGen.Modulator.PMF;       %PM调制的频率
model.Parameters.NoiseGen.Modulator.PMPhi0;    %PM调制的初始相位
model.Parameters.NoiseGen.Modulator.PMK;       %PM调制的调相灵敏度
%===3.FM调制参数===%
model.Parameters.NoiseGen.Modulator.FMA;       %FM调制的幅度
model.Parameters.NoiseGen.Modulator.FMF;       %FM调制的频率
model.Parameters.NoiseGen.Modulator.FMPhi0;    %FM调制的初始相位
model.Parameters.NoiseGen.Modulator.FMK;       %FM调制的调相灵敏度



%%%===干扰方式参数===%%%
%===1.线性调频(chirp)参数===%
model.Parameters.NosieGen.Jamming.LinearSweepFmin ;  %线性扫频的最小频率
model.Parameters.NosieGen.Jamming.LinearSweepFmax ;  %线性扫频的最大频率
model.Parameters.NosieGen.Jamming.LinearSweepT ;     %线性扫频的调频时间
model.Parameters.NosieGen.Jamming.LinearSweepK ;     %线性扫频的调频斜率

%===2.步进调频参数===%
model.Parameters.NoiseGen.Jamming.StepSweepFmin;      %步进扫频的最小频率
model.Parameters.NoiseGen.Jamming.StepSweepFmax;      %步进扫频的最大频率
model.Parameters.NoiseGen.Jamming.StepSweepTDwell;    %步进扫频的时间间隔
model.Parameters.NoiseGen.Jamming.StepSweepDeltaFstep;%步进扫频的频率间隔
model.Parameters.NoiseGen.Jamming.StepSweepN ;        %步进扫频的一个周期内的频率个数
model.Parameters.NoiseGen.Jamming.StepSweepT ;         %步进扫频的一个周期的时间

%%%===多频干扰参数===%%%
%===1.MultiFreq调制参数===%
model.Parameters.NoiseGen.MultiFreq.MFA ;      %MF调制的幅度
model.Parameters.NoiseGen.MultiFreq.MFF ;        %MF调制的频率
model.Parameters.NoiseGen.MultiFreq.MFSequence ; %MF调制的跳频序列
model.Parameters.NoiseGen.MultiFreq.MFNum ;       %MF调制的跳频个数
model.Parameters.NoiseGen.MultiFreq.MFDistance ; %MF调制的最小跳频间隔
model.Parameters.NoiseGen.MultiFreq.MFTime  ;    %MF调制的跳频驻留时间

%===2.MultiFreq随机调制参数===%
model.Parameters.NoiseGen.MultiFreq.MFA_2 ;      %MF调制的幅度
model.Parameters.NoiseGen.MultiFreq.MFF_2 ;        %MF调制的频率
model.Parameters.NoiseGen.MultiFreq.MF_2 ; %MF调制的跳频序列
model.Parameters.NoiseGen.MultiFreq.MFNum_2 ;       %MF调制的跳频个数
model.Parameters.NoiseGen.MultiFreq.MFDistance_2 ; %MF调制的最小跳频间隔
model.Parameters.NoiseGen.MultiFreq.MFTime_2  ;    %MF调制的跳频驻留时间

