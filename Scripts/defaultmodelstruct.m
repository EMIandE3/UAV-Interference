%% 函数功能:初始化模型的参数
% 包括了Parameters和UserData两个部分
%   -> Parameters参数是Simulink建模仿真时候需要用的参数
%   -> UserData参数是GUI界面用户定义的参数

%% *Parameters* 
% =>该部分数据是模型建模的参数 
% 包括了1.NoiseGen, 2.TR参数


%==> NoiseGen 噪声生成模块的参数 <==
% ->NoiseGen模块是用来生成自定义的干扰噪声，其参数包括:1.公用参数 2.噪声源参数 3.噪声调制方式参数 4.干扰方式参数 
% 一、NoiseGen的公用参数
model.Parameters.NoiseGen.NoiseTs = 1e-3;        % 噪声源的采用时间
model.Parameters.NoiseGen.Type = "None";         % 噪声源类型，默认是无噪声
model.Parameters.NoiseGen.Control.Source = 0;    % 噪声源的控制位，默认为0. 0,None 1,高斯白噪声 2,二进制随机调制噪声 3,单音正弦噪声 4.PN码MSK噪声 5.射频噪声
model.Parameters.NoiseGen.Modulator.Type = "None"; % 调制方式类型，默认是None
model.Parameters.NoiseGen.Control.Modulator = 0; % 噪声源的调制方式控制位，默认为0. 0,调制器不工作 1,AM调制方式 2，PM调制方式 3，FM调制方式
model.Parameters.NoiseGen.Jamming.Type = "None"; % 干扰方式类型，默认是None
model.Parameters.NoiseGen.Control.Jamming = 0;   % 噪声源的干扰方式控制位，默认为0. 0,干扰方式不工作
model.Parameters.NoiseGen.MultiFreq.Type = "None";   % 多频干扰类型，默认是None                          
model.Parameters.NoiseGen.Control.MultiFreq = 0;   % 噪声源的多频干扰控制位，默认为0. 0,多频干扰不工作 
model.Parameters.NoiseGen.NosiePowerEstimation = 0;% 噪声源功率估计
model.Parameters.NoiseGen.noise_filter_b = 1; % 带宽参数

% 二、噪声源参数:噪声源类型有：高斯白噪声，二进制随机调制噪声，单音噪声，PN码MSK调制噪声，射频噪声
% 1->高斯白噪声的参数
model.Parameters.NoiseGen.GaussPower = 10;       % 高斯白噪声的功率密度
model.Parameters.NoiseGen.GaussSeed = 0;         % 高斯白噪声的随机数种子
model.Parameters.NoiseGen.pulse_noise_filter_b = 1;

% 2->二进制随机调制噪声参数
model.Parameters.NoiseGen.RandBFZero = 0.5; % 二进制随机数的-1的概率
model.Parameters.NoiseGen.RandBPFA = 1;     % 二进制随机调制噪声的幅度
model.Parameters.NoiseGen.RandBPFF = 1e6;   % 二进制随机调制噪声的频率
model.Parameters.NoiseGen.RandBPFPhi0 = 0;  % 二进制随机调制噪声的初始相位
model.Parameters.NoiseGen.PRCodeTs = 1e-3;

% 3->单音噪声参数
model.Parameters.NoiseGen.SineNoiseA = 1;    % 单音正弦噪声的幅度
model.Parameters.NoiseGen.SineNoiseF = 1e3;  % 单音正弦噪声的频率
model.Parameters.NoiseGen.SineNoisePhi0 = 0; % 单音正弦噪声的初始相位

model.Parameters.NoiseGen.SineNoiseMulti_selection = 0;
model.Parameters.NoiseGen.SineNoiseFreqNum = 2;       % 多音干扰的频点数参数
model.Parameters.NoiseGen.SineNoiseOtherFreq = [1.e6, 2e6];
model.Parameters.NoiseGen.SineNoiseOtherAmplitude = [1, 1];


% 4->PN码MSK调制噪声参数
model.Parameters.NoiseGen.PNMSKPolynomial = [6 1 0];        %PN码的生成器多项式，决定了PN码的周期
model.Parameters.NoiseGen.PNMSKInitialstate = [0 0 0 0 0 1]; %PN码生成器的初始状态
model.Parameters.NoiseGen.PNMSKM = 4;    %MSK每个符号的样本数
model.Parameters.NoiseGen.PNMSKF = 1e6;  %MSK的中心频率
model.Parameters.NoiseGen.PNMSKPhi0 = 0; %MSK的初始相位
% 5->射频噪声
model.Parameters.NoiseGen.RFNoiseFilterObj=defaultFilter;  %滤波器结构体
model.Parameters.NoiseGen.RFNoisePower=10;      %射频干扰噪声的功率    
model.Parameters.NoiseGen.RFNoiseSeed=0;       %射频干扰噪声的随机数种子

% 三、噪声调制方式参数:调制方式有:AM,PM,FM
% 0-> None
% 1-> AM
model.Parameters.NoiseGen.Modulator.AMA = 1;       %AM调制的幅度
model.Parameters.NoiseGen.Modulator.AMF = 1e6;     %AM调制的频率
% model.Parameters.NoiseGen.Modulator.AMPhi0 = 0;    %AM调制的初始相位
model.Parameters.NoiseGen.Modulator.carrier_lower_freq = 1e3;  %AM调制信号的频率
model.Parameters.NoiseGen.Modulator.Ma = 0.8;         %AM调制的调幅度

% 2-> PM
model.Parameters.NoiseGen.Modulator.PMA = 1;       %PM调制的幅度
model.Parameters.NoiseGen.Modulator.PMF = 1e6;     %PM调制的频率
model.Parameters.NoiseGen.Modulator.PMPhi0 = 1e6;  %PM调制的初始相位
model.Parameters.NoiseGen.Modulator.PMK = 1000;    %PM调制的调相灵敏度
% 3-> FM
model.Parameters.NoiseGen.Modulator.FMA = 1;       %FM调制的幅度
model.Parameters.NoiseGen.Modulator.FMF = 1e6;     %FM调制的频率
model.Parameters.NoiseGen.Modulator.FMPhi0 = 1e6;  %FM调制的初始相位
model.Parameters.NoiseGen.Modulator.FMK = 1000;    %FM调制的调相灵敏度


% 四、干扰方式参数:干扰方式有：线性扫频，步进扫频
% 0->None
% 1->线性扫频
model.Parameters.NoiseGen.Jamming.LinearSweepFmin = 1e6;  %线性扫频的最小频率
model.Parameters.NoiseGen.Jamming.LinearSweepFmax = 2e6;  %线性扫频的最大频率
model.Parameters.NoiseGen.Jamming.LinearSweepT = 0.1;     %线性扫频的调频时间
model.Parameters.NoiseGen.Jamming.LinearSweepK = ...
(model.Parameters.NoiseGen.Jamming.LinearSweepFmax-model.Parameters.NoiseGen.Jamming.LinearSweepFmin)/model.Parameters.NoiseGen.Jamming.LinearSweepT;     %线性扫频的调频斜率
% 2->步进扫频
model.Parameters.NoiseGen.Jamming.StepSweepFmin = 1e6;     %步进扫频的最小频率
model.Parameters.NoiseGen.Jamming.StepSweepFmax = 2e6;     %步进扫频的最大频率
model.Parameters.NoiseGen.Jamming.StepSweepTDwell = 500e-9;%步进扫频的时间间隔
model.Parameters.NoiseGen.Jamming.StepSweepDeltaFstep = 1e5;%步进扫频的频率间隔
model.Parameters.NoiseGen.Jamming.StepSweepN = ...
    floor((model.Parameters.NoiseGen.Jamming.StepSweepFmax-model.Parameters.NoiseGen.Jamming.StepSweepFmin) / ...
    model.Parameters.NoiseGen.Jamming.StepSweepDeltaFstep) + 1;%步进扫频的一个周期内的频率个数
model.Parameters.NoiseGen.Jamming.StepSweepT = model.Parameters.NoiseGen.Jamming.StepSweepTDwell * ...
    model.Parameters.NoiseGen.Jamming.StepSweepN;              %步进扫频的一个周期的时间

% 五、多频干扰方式参数
% 0-> None
% 1-> 多频干扰
model.Parameters.NoiseGen.MultiFreq.MFA = [1,1];      %MF调制的幅度
model.Parameters.NoiseGen.MultiFreq.MFF = [0,3e6];        %MF调制的频率
model.Parameters.NoiseGen.MultiFreq.MFSequence = [0,1]; %MF调制的跳频序列
model.Parameters.NoiseGen.MultiFreq.MFNum =  32 ;       %MF调制的跳频个数
model.Parameters.NoiseGen.MultiFreq.MFDistance =  3e6 ; %MF调制的最小跳频间隔
model.Parameters.NoiseGen.MultiFreq.MFTime =  5e-4 ;    %MF调制的跳频驻留时间
% 2-> 多频随机干扰
model.Parameters.NoiseGen.MultiFreq.MFA_2 = [1,1,1];      %MF随机调制的幅度
model.Parameters.NoiseGen.MultiFreq.MFF_2 = [0,3e6,3e6];        %MF随机调制的频率
model.Parameters.NoiseGen.MultiFreq.MF_2 = 4; %MF随机调制的跳频范围
model.Parameters.NoiseGen.MultiFreq.MFNum_2 =  32 ;       %MF随机调制的跳频个数
model.Parameters.NoiseGen.MultiFreq.MFDistance_2 =  3e6 ; %MF随机调制的最小跳频间隔
model.Parameters.NoiseGen.MultiFreq.MFTime_2 =  5e-4 ;    %MF随机调制的跳频驻留时间

model.Parameters.jammer_power_controller = 0;

%==> TR模块的参数 <==
% ->TR模块是发射模块，用于生成发射到信道中的信号，其参数包括:
% model.Parameters.TR.Random_Integer_Generator.Random_Sample_Time = model.UserData.Random_Sample_Time;
% model.Parameters.TR.Random_Integer_Generator.Samples_per_frame = model.UserData.Samples_per_frame;
% model.Parameters.TR.Random_Integer_Generator.SetSize = model.UserData.SetSize;  %随机整数不能大于2^nextpow2(model.Parameters.TR.RS_Encoder.Codeword_Length)
% model.Parameters.TR.RS_Encoder.Codeword_Length = model.UserData.Codeword_Length;  %码字长度需小于基带调制的进制位数
% 
% model.Parameters.TR.Rectangular_QAM_Modulator_Baseband.M_Number = model.UserData.M_Number;  % QAM基带调制,一定要是2的整数次幂
% model.Parameters.TR.Raised_Cosine_Transmit_Filter.Rolloff_factor = model.UserData.Rolloff_factor; % 滚降滤波
% model.Parameters.TR.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols = model.UserData.Filter_span_in_symbols;
% model.Parameters.TR.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol = model.UserData.Output_samples_per_symbol;
% 
% model.Parameters.TR.M_FSK_Modulator_Baseband1.M_ary_number = model.UserData.M_ary_number;
% model.Parameters.TR.M_FSK_Modulator_Baseband1.Frequency_separation = model.UserData.Frequency_separation;
% model.Parameters.TR.PN_Sequence_Generator1.Generator_polynomial = model.UserData.Generator_polynomial;
% model.Parameters.TR.PN_Sequence_Generator1.Initial_states = model.UserData.Initial_states;
% model.Parameters.TR.Digital_Clock.fc_Ts = model.UserData.fc_Ts; % 需要对载波信号满足奈奎斯特频率
% model.Parameters.TR.Constant.fc = model.UserData.fc;
% % RS编码及基带调制
% model.Parameters.TR.RS_Encoder.Message_Length = model.Parameters.TR.Random_Integer_Generator.Samples_per_frame;
% model.Parameters.TR.Rectangular_QAM_Modulator_Baseband.Minimum_distance = 2;
% 
% % 跳频射频调制
% model.Parameters.TR.system_frame_speed = model.Parameters.TR.Random_Integer_Generator.Samples_per_frame*model.Parameters.TR.Random_Integer_Generator.Random_Sample_Time;
% model.Parameters.TR.rolloff_later_data_length = model.Parameters.TR.RS_Encoder.Codeword_Length*model.Parameters.TR.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;
% 
% model.Parameters.TR.M_FSK_Modulator_Baseband1.Samples_per_symbol = model.Parameters.TR.rolloff_later_data_length;
% model.Parameters.TR.PN_Sequence_Generator1.Samples_per_frame = nextpow2(model.Parameters.TR.M_FSK_Modulator_Baseband1.M_ary_number);
% model.Parameters.TR.PN_Sequence_Generator1.Sample_time = model.Parameters.TR.system_frame_speed/model.Parameters.TR.PN_Sequence_Generator1.Samples_per_frame;
% model.Parameters.TR.Bit_to_Integer_Converter.M = model.Parameters.TR.PN_Sequence_Generator1.Samples_per_frame;

% model.Parameters.Channel.Awgn.SNR = 15;
% model.Parameters.Channel.Awgn.input_power = 20;
% 
% model.Parameters.Channel.Fspl.DistanceU_J = 1; % 干扰源到无人机的距离，单位千米
% model.Parameters.Channel.Fspl.DistanceU_C = 1; % 控制器到无人机的距离，单位千米


%% UserData 
%
%


