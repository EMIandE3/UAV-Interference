
%% 参数初始化
%% 


% 各参数输入赋值

model.Parameters.Noise_Sig_Matching_Flag = 0;
model.Parameters.TR.Random_Integer_Generator.Random_Sample_Time = model.UserData.Random_Sample_Time;%随机信号的采样时间
model.Parameters.TR.Random_Integer_Generator.Samples_per_frame = model.UserData.Samples_per_frame;%每帧采样个数
model.Parameters.TR.Random_Integer_Generator.SetSize = model.UserData.SetSize;  %随机整数不能大于2^nextpow2(model.Parameters.TR.RS_Encoder.Codeword_Length)
model.Parameters.TR.RS_Encoder.Codeword_Length = model.UserData.Codeword_Length;  %码字长度需小于基带调制的进制位数

model.Parameters.TR.Rectangular_QAM_Modulator_Baseband.M_Number = model.UserData.M_Number;  % QAM基带调制,一定要是2的整数次幂
model.Parameters.TR.Raised_Cosine_Transmit_Filter.Rolloff_factor = model.UserData.Rolloff_factor; % 滚降滤波
model.Parameters.TR.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols = model.UserData.Filter_span_in_symbols;% square滤波中符号跨度，越高滤波效果越好，但消耗资源数增加（这个实际为卷积操作中的N）
model.Parameters.TR.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol = model.UserData.Output_samples_per_symbol;% 每个符号的输出样本数，注意频谱仪的采样率需要与滤波信号的采样率匹配

model.Parameters.TR.M_FSK_Modulator_Baseband1.M_ary_number = model.UserData.M_ary_number;%跳频数，即M调频
model.Parameters.TR.M_FSK_Modulator_Baseband1.Frequency_separation = model.UserData.Frequency_separation;%频率间隔(Hz)调制信号中连续频率之间的距离。

% model.Parameters.TR.PN_Sequence_Generator1.Generator_polynomial = model.UserData.Generator_polynomial;%调频基带信号PN序列的生成多项式
% model.Parameters.TR.PN_Sequence_Generator1.Initial_states = model.UserData.Initial_states;%调频基带信号PN序列的初始状态

model.Parameters.TR.Digital_Clock.fc_Ts = model.UserData.fc_Ts; % 需要对载波信号满足奈奎斯特频率；这里定义的为对载波采样
model.Parameters.TR.Constant.fc = model.UserData.fc;%载波频率
model.Parameters.Channel.Awgn.SNR = model.UserData.SNR;%高斯信道信噪比
model.Parameters.Channel.Awgn.input_power = model.UserData.input_power;%信道输入采样信号的均方功率

model.Parameters.TR.Baseband_Modulation_type = model.UserData.Modulation_type; %指定调制方式，1和其它为QAM调制，2为PSK调制；并在值小于等于2、等于3、等于4影响每帧采样个数
model.Parameters.TR.communication_sig_power_controller_coeffience = model.UserData.communication_sig_power_controller_coeffience;%频谱搬移后的增益系数或者解调过程中信号的衰减倍数Gain

model.parameter.frame_of_hopping_output_vector = model.UserData.frame_of_hopping_output_vector ;  % 帧信号编码单元

% RS编码及基带调制
model.Parameters.TR.RS_Encoder.Message_Length = model.Parameters.TR.Random_Integer_Generator.Samples_per_frame;%每帧采样个数
model.Parameters.TR.Rectangular_QAM_Modulator_Baseband.Minimum_distance = 2;

% 跳频射频调制
model.Parameters.TR.system_frame_speed = model.Parameters.TR.Random_Integer_Generator.Samples_per_frame*model.Parameters.TR.Random_Integer_Generator.Random_Sample_Time;%每帧采样个数乘以随机信号的采样时间

if model.UserData.Modulation_type <= 2 %跳频和频谱搬移模块与TransmissionChannel模块中，根据指定方式，设置缓存到帧输出的样本数
    model.Parameters.TR.rolloff_later_data_length = model.Parameters.TR.RS_Encoder.Codeword_Length*model.Parameters.TR.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;%码字长度乘每符号输出样本数目
elseif model.UserData.Modulation_type == 3
    model.Parameters.TR.rolloff_later_data_length = model.Parameters.TR.Random_Integer_Generator.Samples_per_frame*model.Parameters.TR.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;%每帧采样个数乘以每符号输出样本数目
elseif model.UserData.Modulation_type == 4
    model.Parameters.TR.rolloff_later_data_length = model.Parameters.TR.Random_Integer_Generator.Samples_per_frame*2*model.Parameters.TR.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;%两倍每帧采样个数乘以每符号输出样本数目
end


if model.Parameters.NoiseGen.NoiseTs < model.Parameters.TR.Random_Integer_Generator.Random_Sample_Time * model.Parameters.TR.Random_Integer_Generator.Samples_per_frame / model.Parameters.TR.rolloff_later_data_length%判断干扰信号的采样时间是否小于（随机信号的采样时间乘以每帧采样个数除以缓存到帧输出的样本数）
    model.Parameters.NoiseGen.NoiseTs = model.Parameters.TR.Random_Integer_Generator.Random_Sample_Time * model.Parameters.TR.Random_Integer_Generator.Samples_per_frame / model.Parameters.TR.rolloff_later_data_length;
    message_imply = sprintf("噪声采样时间和信号采样时间不匹配，已将数值更改为:%d s，请重新生成干扰源，注意观察干扰源的频率参数是否符合奈奎斯特采样频率\n", model.Parameters.NoiseGen.NoiseTs);
    warndlg(message_imply,'警告'); 
    model.Parameters.Noise_Sig_Matching_Flag = 1;

    set_param('Simple_Model_Packaging','SimulationCommand','stop');
    set_param('Simple_Model_Packaging_1_1','SimulationCommand','stop');
    close(fbar);
%     error('程序终止');
    quit('Parameter_Initialize_1.m');

elseif model.Parameters.NoiseGen.NoiseTs > model.Parameters.TR.Random_Integer_Generator.Random_Sample_Time * model.Parameters.TR.Random_Integer_Generator.Samples_per_frame / model.Parameters.TR.rolloff_later_data_length
     model.Parameters.NoiseGen.NoiseTs = model.Parameters.TR.Random_Integer_Generator.Random_Sample_Time * model.Parameters.TR.Random_Integer_Generator.Samples_per_frame / model.Parameters.TR.rolloff_later_data_length;
    message_imply = sprintf("噪声采样时间和信号采样时间不匹配，已将数值更改为:%d s，不需要重新生成干扰源,但需要点击进入干扰源界面更新采样率参数\n", model.Parameters.NoiseGen.NoiseTs);
    warndlg(message_imply,'警告'); 
    model.Parameters.Noise_Sig_Matching_Flag = 1;
else
    if quick_simulation_flag == 0
        message_imply = sprintf("噪声采样时间和信号采样时间匹配，开始仿真\n");
        warndlg(message_imply,'警告');
    end
    
%     model.Parameters.Noise_Sig_Matching_Flag = 0;
end


model.Parameters.TR.M_FSK_Modulator_Baseband1.Samples_per_symbol = model.Parameters.TR.rolloff_later_data_length;%跳频模块M_FSK缓存到帧输出的样本数
model.Parameters.TR.PN_Sequence_Generator1.Samples_per_frame = nextpow2(model.Parameters.TR.M_FSK_Modulator_Baseband1.M_ary_number);%（跳频数，即M调频）的以2为底求对数并向上取整，如M=128时结果为7，为129时结果为8
model.Parameters.TR.PN_Sequence_Generator1.Sample_time = model.Parameters.TR.system_frame_speed/model.Parameters.TR.PN_Sequence_Generator1.Samples_per_frame;%（每帧采样个数乘以随机信号的采样时间）除以log2 M

% 跳频的帧信号采样时间
model.Parameters.frame_of_hopping_Sample_time = model.Parameters.TR.system_frame_speed;%每帧采样个数乘以随机信号的采样时间

model.Parameters.TR.Bit_to_Integer_Converter.M = model.Parameters.TR.PN_Sequence_Generator1.Samples_per_frame;%每个整数映射的位数log2 M

% 匹配滤波,与发送端完全对应
model.Parameters.RE.Raised_Cosine_Receive_Filter.Rolloff_factor = model.Parameters.TR.Raised_Cosine_Transmit_Filter.Rolloff_factor;
model.Parameters.RE.Raised_Cosine_Receive_Filter.Filter_span_in_symbols = model.Parameters.TR.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols;
model.Parameters.RE.Raised_Cosine_Receive_Filter.Input_samples_per_symbol = model.Parameters.TR.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;
model.Parameters.RE.Raised_Cosine_Receive_Filter.Decimation_factor = model.Parameters.TR.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;

% QAM基带解调,与发送端完全对应
model.Parameters.RE.Rectangular_QAM_Demodulator_Baseband.M_Number = model.Parameters.TR.Rectangular_QAM_Modulator_Baseband.M_Number;
model.Parameters.RE.Rectangular_QAM_Demodulator_Baseband.Minimum_distance = model.Parameters.TR.Rectangular_QAM_Modulator_Baseband.Minimum_distance;

% RS解码
% 解码部分延时计算
model.Parameters.RE.Raised_Cosine_Transmit_Filter.Ts = model.Parameters.TR.system_frame_speed/(model.Parameters.TR.rolloff_later_data_length);%（每帧采样个数乘以随机信号的采样时间）/（设置缓存到帧输出的样本数）
model.Parameters.RE.Raised_Cosine_Transmit_Filter.Delay_time = (model.Parameters.TR.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol * model.Parameters.TR.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols)*model.Parameters.RE.Raised_Cosine_Transmit_Filter.Ts; %收发两个滚降滤波器
model.Parameters.RE.Integer_Output_RS_Decoder1.Delay_bit_num = model.Parameters.RE.Raised_Cosine_Transmit_Filter.Delay_time/(model.Parameters.TR.system_frame_speed/model.Parameters.TR.RS_Encoder.Codeword_Length);

model.Parameters.RE.Delay.Sample_length = model.Parameters.TR.RS_Encoder.Codeword_Length - model.Parameters.RE.Integer_Output_RS_Decoder1.Delay_bit_num; %码字长度-延时
model.Parameters.RE.Integer_Output_RS_Decoder1.Codeword_Length = model.Parameters.TR.RS_Encoder.Codeword_Length;
model.Parameters.RE.Integer_Output_RS_Decoder1.Message_Length = model.Parameters.TR.RS_Encoder.Message_Length;

% 计算误比特率
model.Parameters.BER.bit_num = nextpow2(model.Parameters.TR.Random_Integer_Generator.SetSize);
model.Parameters.TR.Carrier_delay = model.Parameters.TR.system_frame_speed;
model.Parameters.Total_delay = model.Parameters.TR.Carrier_delay + model.Parameters.RE.Raised_Cosine_Transmit_Filter.Delay_time;

% bit_num = model.Parameters.TR.Random_Integer_Generator.Samples_per_frame;%每帧采样个数
if model.UserData.Modulation_type <= 2
    if model.Parameters.RE.Delay.Sample_length ~= 0
        if round(model.Parameters.RE.Raised_Cosine_Transmit_Filter.Delay_time/(model.Parameters.TR.system_frame_speed/model.Parameters.RE.Integer_Output_RS_Decoder1.Message_Length)) > model.Parameters.TR.Random_Integer_Generator.Samples_per_frame
            model.Parameters.receive_Delay_num = (fix(model.Parameters.RE.Raised_Cosine_Transmit_Filter.Delay_time/(model.Parameters.TR.system_frame_speed/model.Parameters.RE.Integer_Output_RS_Decoder1.Message_Length)) + 1) * model.Parameters.TR.Random_Integer_Generator.Samples_per_frame;
        else
            model.Parameters.receive_Delay_num = model.Parameters.TR.Random_Integer_Generator.Samples_per_frame;
        end
    else
        model.Parameters.receive_Delay_num = fix(model.Parameters.RE.Raised_Cosine_Transmit_Filter.Delay_time/(model.Parameters.TR.system_frame_speed/model.Parameters.RE.Integer_Output_RS_Decoder1.Message_Length));
    end

elseif model.UserData.Modulation_type == 3
    model.Parameters.receive_Delay_num = fix(model.Parameters.RE.Raised_Cosine_Transmit_Filter.Delay_time/(model.Parameters.TR.system_frame_speed/model.Parameters.RE.Integer_Output_RS_Decoder1.Message_Length));

elseif model.UserData.Modulation_type == 4 %% OQPSK解调会额外多出一个单位信号周期延时
    model.Parameters.receive_Delay_num = fix( (model.Parameters.RE.Raised_Cosine_Transmit_Filter.Delay_time + model.Parameters.TR.system_frame_speed/model.Parameters.TR.Random_Integer_Generator.Samples_per_frame) /(model.Parameters.TR.system_frame_speed/model.Parameters.RE.Integer_Output_RS_Decoder1.Message_Length));
end

model.Parameters.BER.Integer_to_Bit_Converter.M = model.Parameters.BER.bit_num;
model.Parameters.BER.Integer_to_Bit_Converter1.M = model.Parameters.BER.bit_num;
model.Parameters.BER.Error_Rate_Calculation.receive_Delay = model.Parameters.receive_Delay_num * model.Parameters.BER.bit_num;

% 后续画图



