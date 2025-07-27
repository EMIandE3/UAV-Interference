%% 模型5的参数初始化(基于模型3的更改)

%% 输入参数整理
model.Parameters.Noise_Sig_Matching_Flag = 0;
model.parameter.Repeating_Sequence_Stair.output_vector = model.user_defined.Repeating_Sequence_Stair.output_vector ;  % 帧信号编码单元
model.parameter.Repeating_Sequence_Stair.CodeTs = model.user_defined.Repeating_Sequence_Stair.CodeTs ; 


% 载波采样频率
model.parameter.Digital_Clock2.CarrierTs = model.user_defined.Digital_Clock2.CarrierTs ;

% 本地载波的自定义函数模块
        
model.parameter.Sine_Carrier_Num = model.user_defined.Sine_Carrier_Num ;
model.parameter.Sine_Carrier_Freq = model.user_defined.Sine_Carrier_Freq ;
model.parameter.Sine_Carrier_Ampl = model.user_defined.Sine_Carrier_Ampl ;

% 升余弦滚降滤波
model.parameter.Raised_Cosine_Transmit_Filter.Rolloff_factor = model.user_defined.Raised_Cosine_Transmit_Filter.Rolloff_factor ;  
model.parameter.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols = model.user_defined.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols ;
model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol = model.user_defined.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol ;

% 速率转换函数，作用是对帧信号发生器经过滤波器后的信号进行重采样，例如原本是10个点，经过插值变成100个点。信号的频率其实并没有改变
% 设置速率转换函数的重采样率
% 暂时不设置了，因为设置的报错暂时不知道怎么修改
% model.parameter.rate_factor = model.user_defined.rate_factor ;

model.parameter.Awgn.SNR = model.user_defined.Awgn.SNR ;           % 添加信道噪声
model.parameter.Awgn.input_power = model.user_defined.Awgn.input_power ;

%% 参数固定或参数间关系已知
% buffer12 长度设置
model.parameter.Buffer12.Output_buffer_size = 200 * model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;

% 射频调制模拟以及部分本地载波相加
model.parameter.Buffer1.Output_buffer_size = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;  % buffer1 长度设置
model.parameter.Buffer3.Output_buffer_size = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;  % buffer3 长度设置

% 接收端本地载波
model.Intermediate_variable.system_frame_speed_1 = model.parameter.Repeating_Sequence_Stair.CodeTs / model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol * model.parameter.Buffer12.Output_buffer_size;
model.Intermediate_variable.system_frame_speed_2 = model.Intermediate_variable.system_frame_speed_1 / (model.parameter.Buffer12.Output_buffer_size * 10) * model.parameter.Buffer1.Output_buffer_size;
model.Intermediate_variable.system_frame_speed_3 = model.Intermediate_variable.system_frame_speed_2 / model.parameter.Buffer1.Output_buffer_size;

% 功率估计
model.parameter.Buffer.Output_buffer_size = 1;
model.parameter.channel_estimate_fs = model.Intermediate_variable.system_frame_speed_2;

% 帧信号的基带解调
model.parameter.Buffer6.Output_buffer_size = model.parameter.Buffer12.Output_buffer_size*10 ; 
model.parameter.Buffer5.Output_buffer_size = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;

% 匹配滤波,与发送端完全对应
model.parameter.Raised_Cosine_Receive_Filter.Rolloff_factor           = model.parameter.Raised_Cosine_Transmit_Filter.Rolloff_factor;
model.parameter.Raised_Cosine_Receive_Filter.Filter_span_in_symbols   = model.parameter.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols;
model.parameter.Raised_Cosine_Receive_Filter.Input_samples_per_symbol = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;
model.parameter.Raised_Cosine_Receive_Filter.Decimation_factor        = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;

%% 噪声采样时间修改
if model.Parameters.NoiseGen.NoiseTs < model.parameter.channel_estimate_fs / model.parameter.Buffer1.Output_buffer_size
    model.Parameters.NoiseGen.NoiseTs = model.parameter.channel_estimate_fs / model.parameter.Buffer1.Output_buffer_size;
    message_imply = sprintf("噪声采样时间和信号采样时间不匹配，已将数值更改为:%d s，请重新生成干扰源，注意观察干扰源的频率参数是否符合奈奎斯特采样频率\n", model.Parameters.NoiseGen.NoiseTs);
    warndlg(message_imply,'警告'); 
    model.Parameters.Noise_Sig_Matching_Flag = 1;

    set_param('Simple_Model_Packaging_5','SimulationCommand','stop');
    set_param('Simple_Model_Packaging_5_1','SimulationCommand','stop');
%     close(fbar);
%     error('程序终止');
    quit('Parameter_Initialize_5.m');
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


