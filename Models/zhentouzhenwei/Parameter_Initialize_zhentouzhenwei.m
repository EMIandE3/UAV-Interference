%% 模型5的参数初始化(基于模型3的更改)

%% 输入参数整理
% model.parameter.Random_Integer_Generator.Random_Sample_Time = model.user_defined.Random_Integer_Generator.Random_Sample_Time;
% model.parameter.Random_Integer_Generator.Samples_per_frame = model.user_defined.Random_Integer_Generator.Samples_per_frame;
% model.parameter.Random_Integer_Generator.SetSize = model.user_defined.Random_Integer_Generator.SetSize;  %随机整数不能大于2^nextpow2(model.parameter.RS_Encoder.Codeword_Length)，同样也不能太小，否则误码率比较部分会出错
% model.parameter.Rectangular_QAM_Modulator_Baseband.M_Number = model.user_defined.Rectangular_QAM_Modulator_Baseband.M_Number;               % QAM基带调制,一定要是2的整数次幂


%% 输入参数整理
model.Parameters.Noise_Sig_Matching_Flag = 0;

model.parameter.Raised_Cosine_Transmit_Filter.Rolloff_factor = model.user_defined.Raised_Cosine_Transmit_Filter.Rolloff_factor ;  % 升余弦滚降滤波
model.parameter.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols = model.user_defined.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols ;
model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol = model.user_defined.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol ;


model.parameter.Digital_Clock2.CarrierTs = model.user_defined.Digital_Clock2.CarrierTs ; % 载波采样频率
model.parameter.Sinc_Freq = model.user_defined.Sinc_Freq ;
model.parameter.Sine_Carrier_Num = model.user_defined.Sine_Carrier_Num ;
model.parameter.Sine_Carrier_Freq = model.user_defined.Sine_Carrier_Freq ;
model.parameter.Sine_Carrier_Ampl = model.user_defined.Sine_Carrier_Ampl ;


model.parameter.Awgn.SNR = model.user_defined.Awgn.SNR ;           % 添加信道噪声
model.parameter.Awgn.input_power = model.user_defined.Awgn.input_power ;

%% 参数固定或参数间关系已知
% 4PAM基带调制
model.parameter.M_PAM_Modulator_Baseband.Minimum_distance = 2;

% buffer12 长度设置
model.parameter.Buffer12.Output_buffer_size = 40 * model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;

% 射频调制模拟以及部分本地载波相加
model.parameter.Buffer1.Output_buffer_size = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;  % buffer1 长度设置
model.parameter.Buffer3.Output_buffer_size = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;  % buffer3 长度设置

model.parameter.Buffer2.Output_buffer_size = 1;     % buffer2 长度设置
model.parameter.Buffer4.Output_buffer_size = model.parameter.Buffer3.Output_buffer_size;

% 接收端本地载波
model.Intermediate_variable.system_frame_speed_1 = 0.00005 / model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol * model.parameter.Buffer12.Output_buffer_size;
model.Intermediate_variable.system_frame_speed_2 = model.Intermediate_variable.system_frame_speed_1 / (model.parameter.Buffer12.Output_buffer_size * 10) * model.parameter.Buffer1.Output_buffer_size;
model.Intermediate_variable.system_frame_speed_3 = model.Intermediate_variable.system_frame_speed_2 / model.parameter.Buffer1.Output_buffer_size;
model.Intermediate_variable.delay_time_1 = model.Intermediate_variable.system_frame_speed_3 / model.parameter.Buffer2.Output_buffer_size * model.parameter.Buffer4.Output_buffer_size;

model.parameter.delay1.delay_length = round(model.Intermediate_variable.delay_time_1 / model.Intermediate_variable.system_frame_speed_2 * model.parameter.Buffer1.Output_buffer_size); 

% 功率估计
model.parameter.Buffer.Output_buffer_size = 1;
model.parameter.channel_estimate_fs = model.Intermediate_variable.system_frame_speed_2;

% 帧信号合并与去本地载波
model.parameter.Buffer6.Output_buffer_size = 1;  % buffer6 长度设置

% 帧信号的基带解调
model.parameter.Buffer8.Output_buffer_size = (model.parameter.Buffer12.Output_buffer_size * 10);
model.parameter.Buffer5.Output_buffer_size = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;

% 匹配滤波,与发送端完全对应
model.parameter.Raised_Cosine_Receive_Filter.Rolloff_factor           = model.parameter.Raised_Cosine_Transmit_Filter.Rolloff_factor;
model.parameter.Raised_Cosine_Receive_Filter.Filter_span_in_symbols   = model.parameter.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols;
model.parameter.Raised_Cosine_Receive_Filter.Input_samples_per_symbol = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;
model.parameter.Raised_Cosine_Receive_Filter.Decimation_factor        = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;


% 后续画图
% a = strsplit(get_param('Simple_Model_Packaging_2/Selector1','Indices'),',');
% b = a{1,1};
%% 帧头的开始时间和结束时间
model.parameter.t1_start = model.user_defined.t1_start;
model.parameter.t1_end = model.user_defined.t1_end;
model.parameter.t2_start = model.user_defined.t2_start;
model.parameter.t2_end = model.user_defined.t2_end;
%% 噪声采样时间修改
if model.Parameters.NoiseGen.NoiseTs < model.parameter.channel_estimate_fs / model.parameter.Buffer1.Output_buffer_size
    model.Parameters.NoiseGen.NoiseTs = model.parameter.channel_estimate_fs / model.parameter.Buffer1.Output_buffer_size;
    message_imply = sprintf("噪声采样时间和信号采样时间不匹配，已将数值更改为:%d s，请重新生成干扰源，注意观察干扰源的频率参数是否符合奈奎斯特采样频率\n", model.Parameters.NoiseGen.NoiseTs);
    warndlg(message_imply,'警告'); 
    model.Parameters.Noise_Sig_Matching_Flag = 1;

    set_param('Simple_Model_Packaging_3','SimulationCommand','stop');
    set_param('Simple_Model_Packaging_3_1','SimulationCommand','stop');
%     close(fbar);
%     error('程序终止');
    quit('Parameter_Initialize_3.m');
elseif model.Parameters.NoiseGen.NoiseTs > model.parameter.channel_estimate_fs / model.parameter.Buffer1.Output_buffer_size
    model.Parameters.NoiseGen.NoiseTs = model.parameter.channel_estimate_fs / model.parameter.Buffer1.Output_buffer_size;
    message_imply = sprintf("噪声采样时间和信号采样时间不匹配，已将数值更改为:%d s，不需要重新生成干扰源,但需要点击进入干扰源界面更新采样率参数\n", model.Parameters.NoiseGen.NoiseTs);
    warndlg(message_imply,'警告'); 
    model.Parameters.Noise_Sig_Matching_Flag = 1;
else
    if quick_simulation_flag == 0
        message_imply = sprintf("噪声采样时间和信号采样时间匹配，开始仿真\n");
        warndlg(message_imply,'警告');
    end
end


