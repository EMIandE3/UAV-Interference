%% 模型2的参数初始化
%% 目前已完成了初步参数化，尚未完成的部分是MIMO信道的多径部分，以及MIMO阵列的阵列选择问题，以及射频调制的单载波乘法部分，其余均已完成

%% 目前想到的解决办法是通过Multiport_Switch模块，或if模块来对各单元的仿真情况进行分类讨论，从而实现最终结果

% 各参数输入赋值
%% 测例一
% model.parameter.Random_Integer_Generator.Random_Sample_Time = 25e-6;
% model.parameter.Random_Integer_Generator.Samples_per_frame = 3;
% model.parameter.Random_Integer_Generator.SetSize = 15; 

%% 输入参数整理
model.Parameters.Noise_Sig_Matching_Flag = 0;
model.parameter.Random_Integer_Generator.Random_Sample_Time = model.user_defined.Random_Integer_Generator.Random_Sample_Time;
model.parameter.Random_Integer_Generator.Samples_per_frame = model.user_defined.Random_Integer_Generator.Samples_per_frame;
model.parameter.Random_Integer_Generator.SetSize = model.user_defined.Random_Integer_Generator.SetSize;  %随机整数不能大于2^nextpow2(model.parameter.RS_Encoder.Codeword_Length)，同样也不能太小，否则误码率比较部分会出错
model.parameter.Rectangular_QAM_Modulator_Baseband.M_Number = model.user_defined.Rectangular_QAM_Modulator_Baseband.M_Number;               % QAM基带调制,一定要是2的整数次幂

model.parameter.OFDM_Modulator.FFT_length = model.user_defined.OFDM_Modulator.FFT_length;
model.parameter.OFDM_Modulator.guard_bands_num = model.user_defined.OFDM_Modulator.guard_bands_num;
model.parameter.OFDM_Modulator.Cyclic_prefix_length = model.user_defined.OFDM_Modulator.Cyclic_prefix_length;

model.parameter.Raised_Cosine_Transmit_Filter1.Rolloff_factor = model.user_defined.Raised_Cosine_Transmit_Filter1.Rolloff_factor; 
model.parameter.Raised_Cosine_Transmit_Filter1.Filter_span_in_symbols = model.user_defined.Raised_Cosine_Transmit_Filter1.Filter_span_in_symbols;
model.parameter.Raised_Cosine_Transmit_Filter1.Output_samples_per_symbol = model.user_defined.Raised_Cosine_Transmit_Filter1.Output_samples_per_symbol;

model.parameter.M_FSK_Modulator_Baseband1.M_ary_number = model.user_defined.M_FSK_Modulator_Baseband1.M_ary_number;
model.parameter.M_FSK_Modulator_Baseband1.Frequency_separation = model.user_defined.M_FSK_Modulator_Baseband1.Frequency_separation;
model.parameter.PN_Sequence_Generator1.Generator_polynomial = model.user_defined.PN_Sequence_Generator1.Generator_polynomial;
model.parameter.PN_Sequence_Generator1.Initial_states = model.user_defined.PN_Sequence_Generator1.Initial_states;

model.parameter.Awgn.SNR = model.user_defined.Awgn.SNR;
model.parameter.Awgn.input_power = model.user_defined.Awgn.input_power;

model.parameter.MIMO_Fading_Channel.Average_path_gains = model.user_defined.MIMO_Fading_Channel.Average_path_gains;
model.parameter.MIMO_Fading_Channel.Maximum_Doppler_shift = model.user_defined.MIMO_Fading_Channel.Maximum_Doppler_shift;


% MIMO阵列的结构参数输入
model.parameter.OSTBC_Encoder.numTx = 2;
model.parameter.MIMO_Fading_Channel.TA_num = 2; % 目前MIMO结构也被定死了，意思是一个仿真电路结构对应一个实际的MIMO阵列结构，如果需要改换阵列结构，
                                                % 需要对链路中的数据维度处理结构进行更改,或者使用Multiport_Switch模块设计选择器，通过搭建多路信道，选择其中特定的通道输出来实现;
                                                % 或者也可以使用if模块做判断，来实现对多阵列的控制；
model.parameter.MIMO_Fading_Channel.RA_num = 4; 

%% 更改测例，测例二

% RS编码
model.parameter.RS_Encoder.Codeword_Length = model.parameter.Rectangular_QAM_Modulator_Baseband.M_Number - 1;  %码字长度需小于基带调制的进制位数,但也不能过小，否则会RS解码部分报错
model.parameter.RS_Encoder.Message_Length = model.parameter.Random_Integer_Generator.Samples_per_frame;

% 信道交织
if model.parameter.Rectangular_QAM_Modulator_Baseband.M_Number < 120
    model.parameter.Matrix_Interleaver.row_nums = 12;
    model.parameter.Matrix_Interleaver.col_nums = 10;
elseif (model.parameter.Rectangular_QAM_Modulator_Baseband.M_Number < 1200) && (model.parameter.Rectangular_QAM_Modulator_Baseband.M_Number >= 120)
    model.parameter.Matrix_Interleaver.row_nums = 120;
    model.parameter.Matrix_Interleaver.col_nums = 10;
elseif (model.parameter.Rectangular_QAM_Modulator_Baseband.M_Number < 12000) && (model.parameter.Rectangular_QAM_Modulator_Baseband.M_Number >= 1200)
    model.parameter.Matrix_Interleaver.row_nums = 120;
    model.parameter.Matrix_Interleaver.col_nums = 100;
else % 一般多阶调制的进制数不会大于120000，故暂时不考虑进制数大于120000的情况
    model.parameter.Matrix_Interleaver.row_nums = 1200;
    model.parameter.Matrix_Interleaver.col_nums = 100;
end

% 交织和解交织前后的buffer
model.parameter.Buffer3.Output_size = model.parameter.Matrix_Interleaver.row_nums *model.parameter.Matrix_Interleaver.col_nums;
if model.user_defined.TR.Baseband_Modulation_type <= 2
    model.parameter.Buffer4.Output_size = model.parameter.RS_Encoder.Codeword_Length;
    model.parameter.Buffer6.Output_buffer_size = model.parameter.RS_Encoder.Codeword_Length;
else
    model.parameter.Buffer4.Output_size = model.parameter.Random_Integer_Generator.Samples_per_frame;
    model.parameter.Buffer6.Output_buffer_size = model.parameter.Random_Integer_Generator.Samples_per_frame;
end

% 基带调制
model.parameter.Rectangular_QAM_Modulator_Baseband.Minimum_distance = 2;

% OFDM调制之前的延时
model.Intermediate_variable.system_frame_speed_1 = model.parameter.Random_Integer_Generator.Random_Sample_Time * model.parameter.Random_Integer_Generator.Samples_per_frame;
model.Intermediate_variable.Delay1_before_OFDM = model.parameter.Buffer3.Output_size * model.Intermediate_variable.system_frame_speed_1/model.parameter.RS_Encoder.Codeword_Length; % buffer3的延时

% OFDM调制
model.parameter.OFDM_Modulator.output_data_length = model.parameter.OFDM_Modulator.Cyclic_prefix_length + model.parameter.OFDM_Modulator.FFT_length;
model.parameter.OFDM_Modulator.transmit_antennas_num = 1;
model.parameter.OFDM_Modulator.OFDM_symbols_num = 1;

% buffer1参数
model.parameter.Buffer1.Output_size = model.parameter.OFDM_Modulator.FFT_length - (model.parameter.OFDM_Modulator.guard_bands_num(1)+model.parameter.OFDM_Modulator.guard_bands_num(2));

% OSTBC编码
load_system('Simple_Model_Packaging_2');
load_system('Simple_Model_Packaging_2_1');
set_param('Simple_Model_Packaging_2/OSTBC Encoder','numTx', num2str(model.parameter.OSTBC_Encoder.numTx))
set_param('Simple_Model_Packaging_2_1/OSTBC Encoder','numTx', num2str(model.parameter.OSTBC_Encoder.numTx))

% 选择器长度
model.parameter.Selector1.str_Selector_Indices = strcat('[1:',num2str(model.parameter.OFDM_Modulator.output_data_length),'],1');
set_param('Simple_Model_Packaging_2/Selector1','Indices',model.parameter.Selector1.str_Selector_Indices)
set_param('Simple_Model_Packaging_2_1/Selector1','Indices',model.parameter.Selector1.str_Selector_Indices)

model.parameter.Selector.str_Selector_Indices = strcat('[1:',num2str(model.parameter.OFDM_Modulator.output_data_length),'],2');
set_param('Simple_Model_Packaging_2/Selector','Indices',model.parameter.Selector.str_Selector_Indices)
set_param('Simple_Model_Packaging_2_1/Selector','Indices',model.parameter.Selector.str_Selector_Indices)

% 发射端滚降滤波器
model.parameter.Raised_Cosine_Transmit_Filter2.Rolloff_factor = model.parameter.Raised_Cosine_Transmit_Filter1.Rolloff_factor; 
model.parameter.Raised_Cosine_Transmit_Filter2.Filter_span_in_symbols = model.parameter.Raised_Cosine_Transmit_Filter1.Filter_span_in_symbols;
model.parameter.Raised_Cosine_Transmit_Filter2.Output_samples_per_symbol = model.parameter.Raised_Cosine_Transmit_Filter1.Output_samples_per_symbol;

% 跳频调制
model.Intermediate_variable.system_frame_length_2 = model.parameter.OFDM_Modulator.output_data_length * model.parameter.Raised_Cosine_Transmit_Filter2.Output_samples_per_symbol;
if model.user_defined.TR.Baseband_Modulation_type <= 3
    model.Intermediate_variable.system_frame_speed_2 = model.Intermediate_variable.system_frame_speed_1/model.parameter.Buffer4.Output_size*model.parameter.Buffer1.Output_size;
else
    model.Intermediate_variable.system_frame_speed_2 = model.Intermediate_variable.system_frame_speed_1/model.parameter.Buffer4.Output_size/2*model.parameter.Buffer1.Output_size;
end

model.parameter.M_FSK_Modulator_Baseband1.Samples_per_symbol = model.Intermediate_variable.system_frame_length_2;

model.parameter.PN_Sequence_Generator1.Samples_per_frame = nextpow2(model.parameter.M_FSK_Modulator_Baseband1.M_ary_number);
model.parameter.PN_Sequence_Generator1.Sample_time = model.Intermediate_variable.system_frame_speed_2 / model.parameter.PN_Sequence_Generator1.Samples_per_frame;
model.parameter.Bit_to_Integer_Converter.M = model.parameter.PN_Sequence_Generator1.Samples_per_frame;


% model.parameter.Digital_Clock.fc_Ts = model.user_defined.fc_Ts; % 需要对载波信号满足奈奎斯特频率
% model.parameter.Constant.fc = model.user_defined.fc;

% 串联维度
model.parameter.Matrix_Concatenate.Input_num = 2;
model.parameter.Matrix_Concatenate.Cascade_Dimension = 2;

% MIMO信道衰落
model.parameter.MIMO_Fading_Channel.Discrete_path_delays = [0]; 
% model.parameter.MIMO_Fading_Channel.Discrete_path_delays = model.Intermediate_variable.system_frame_speed_2;


% 解调选择器
model.parameter.Multiport_Selector.Indices_to_output = { 1, 2, 3, 4};

% 解调延时1 (目前只考虑单条路径的解调同步时延设置)
model.parameter.Delay2.Sample_num = round(model.parameter.MIMO_Fading_Channel.Discrete_path_delays / model.Intermediate_variable.system_frame_speed_2 *model.Intermediate_variable.system_frame_length_2);

% 匹配滤波,与发送端完全对应
model.parameter.Raised_Cosine_Receive_Filter1.Rolloff_factor           = model.parameter.Raised_Cosine_Transmit_Filter1.Rolloff_factor;
model.parameter.Raised_Cosine_Receive_Filter1.Filter_span_in_symbols   = model.parameter.Raised_Cosine_Transmit_Filter1.Filter_span_in_symbols;
model.parameter.Raised_Cosine_Receive_Filter1.Input_samples_per_symbol = model.parameter.Raised_Cosine_Transmit_Filter1.Output_samples_per_symbol;
model.parameter.Raised_Cosine_Receive_Filter1.Decimation_factor        = model.parameter.Raised_Cosine_Transmit_Filter1.Output_samples_per_symbol;

model.parameter.Raised_Cosine_Receive_Filter2.Rolloff_factor           = model.parameter.Raised_Cosine_Transmit_Filter2.Rolloff_factor;
model.parameter.Raised_Cosine_Receive_Filter2.Filter_span_in_symbols   = model.parameter.Raised_Cosine_Transmit_Filter2.Filter_span_in_symbols;
model.parameter.Raised_Cosine_Receive_Filter2.Input_samples_per_symbol = model.parameter.Raised_Cosine_Transmit_Filter2.Output_samples_per_symbol;
model.parameter.Raised_Cosine_Receive_Filter2.Decimation_factor        = model.parameter.Raised_Cosine_Transmit_Filter2.Output_samples_per_symbol;

% 解调串联数据维度
model.parameter.Matrix_Concatenate1.Input_num = 4;
model.parameter.Matrix_Concatenate1.Cascade_Dimension = 2;

% OSTBC解码
set_param('Simple_Model_Packaging_2/OSTBC Combiner','numTx','2');
set_param('Simple_Model_Packaging_2/OSTBC Combiner','numRx','4');

% OFDM调制与OFDM解调前Delay1之间的延时
model.parameter.Raised_Cosine_Transmit_Filter1.Ts = model.Intermediate_variable.system_frame_speed_2/(model.Intermediate_variable.system_frame_length_2);
model.Intermediate_variable.delay_time_part_1 = (model.parameter.Raised_Cosine_Transmit_Filter1.Output_samples_per_symbol * model.parameter.Raised_Cosine_Transmit_Filter1.Filter_span_in_symbols)*model.parameter.Raised_Cosine_Transmit_Filter1.Ts; %收发两个滚降滤波器
model.Intermediate_variable.delay_time_part_2 = model.parameter.MIMO_Fading_Channel.Discrete_path_delays;
model.Intermediate_variable.Delay2_before_OFDM_Demodulator = model.Intermediate_variable.delay_time_part_1 + model.Intermediate_variable.delay_time_part_2;

% 解调延时2的延时样本数计算
model.Intermediate_variable.delay_sample_num_2 = round(model.Intermediate_variable.Delay2_before_OFDM_Demodulator / model.Intermediate_variable.system_frame_speed_2 * (model.parameter.OFDM_Modulator.output_data_length));
model.parameter.Delay1.Sample_num = (model.parameter.OFDM_Modulator.output_data_length) - mod(model.Intermediate_variable.delay_sample_num_2, (model.parameter.OFDM_Modulator.output_data_length));

% OFDM解调
model.parameter.OFDM_Demodulator.FFT_length = model.parameter.OFDM_Modulator.FFT_length;
model.parameter.OFDM_Demodulator.Number_of_guard_bands = model.parameter.OFDM_Modulator.guard_bands_num;
model.parameter.OFDM_Demodulator.Cyclic_prefix_length = model.parameter.OFDM_Modulator.Cyclic_prefix_length;
model.parameter.OFDM_Demodulator.Number_of_OFDM_symbols = model.parameter.OFDM_Modulator.OFDM_symbols_num;
model.parameter.OFDM_Demodulator.Number_of_receive_antennas = model.parameter.OFDM_Modulator.transmit_antennas_num;

% 解调缓冲器
if model.user_defined.TR.Baseband_Modulation_type <= 3
    model.parameter.Buffer2.Output_buffer_size = model.parameter.Buffer4.Output_size;
else
    model.parameter.Buffer2.Output_buffer_size = model.parameter.Buffer4.Output_size * 2;
end

% QAM基带解调,与发送端完全对应
model.parameter.Rectangular_QAM_Demodulator_Baseband.M_Number = model.parameter.Rectangular_QAM_Modulator_Baseband.M_Number;
model.parameter.Rectangular_QAM_Demodulator_Baseband.Minimum_distance = 2;

% 解调缓冲器2
model.parameter.Buffer5.Output_buffer_size = model.parameter.Buffer3.Output_size;

%% 信道交织与信道解交织之间的延时
if model.user_defined.TR.Baseband_Modulation_type <= 2
    model.Intermediate_variable.system_frame_speed_3 = model.Intermediate_variable.system_frame_speed_1 / model.parameter.RS_Encoder.Codeword_Length * model.parameter.Buffer3.Output_size;
else
    model.Intermediate_variable.system_frame_speed_3 = model.Intermediate_variable.system_frame_speed_1 / model.parameter.Random_Integer_Generator.Samples_per_frame * model.parameter.Buffer3.Output_size;
end

if model.user_defined.TR.Baseband_Modulation_type <= 3
    model.Intermediate_variable.delay_time_part_4 = model.parameter.Buffer1.Output_size * model.Intermediate_variable.system_frame_speed_1 / model.parameter.Buffer4.Output_size; % buffer1处产生的延时计算
    model.Intermediate_variable.delay_time_part_3 = model.parameter.Buffer5.Output_buffer_size * model.Intermediate_variable.system_frame_speed_1 / model.parameter.Buffer2.Output_buffer_size; % buffer5处产生的延时计算
else
    model.Intermediate_variable.delay_time_part_4 = model.parameter.Buffer1.Output_size * model.Intermediate_variable.system_frame_speed_1 / model.parameter.Buffer4.Output_size / 2;
    model.Intermediate_variable.delay_time_part_3 = model.parameter.Buffer5.Output_buffer_size * model.Intermediate_variable.system_frame_speed_1 / model.parameter.Buffer2.Output_buffer_size * 2 + ...
        model.Intermediate_variable.system_frame_speed_1 / model.parameter.Integer_Output_RS_Decoder1.Message_Length;  %% OQPSK解调会额外多出一个单位信号周期延时,加入了OQPSK解调的延时计算
end

model.Intermediate_variable.delay_time_part_5 = model.Intermediate_variable.Delay2_before_OFDM_Demodulator; % OFDM调制与OFDM解调前Delay1之间的延时
model.Intermediate_variable.delay_time_part_6 = model.parameter.Delay1.Sample_num * model.Intermediate_variable.system_frame_speed_2 / model.parameter.OFDM_Modulator.output_data_length; % 延时器1的延时

if mod(model.parameter.Buffer1.Output_size, model.parameter.Buffer2.Output_buffer_size) ~= 0
    model.Intermediate_variable.delay_time_part_7 = model.parameter.Buffer2.Output_buffer_size * model.Intermediate_variable.system_frame_speed_2 / model.parameter.Buffer1.Output_size; % buffer2处产生的延时计算
else
    model.Intermediate_variable.delay_time_part_7 = 0;
end

if mod(model.parameter.Buffer3.Output_size, model.parameter.Buffer4.Output_size) ~= 0
    model.Intermediate_variable.delay_time_part_11 = model.parameter.Buffer4.Output_size * model.Intermediate_variable.system_frame_speed_3 / model.parameter.Buffer3.Output_size; % buffer4处产生的延时计算
else
    model.Intermediate_variable.delay_time_part_11 = 0;
end

model.Intermediate_variable.delay_time_2 = model.Intermediate_variable.delay_time_part_3 + model.Intermediate_variable.delay_time_part_4 + model.Intermediate_variable.delay_time_part_5 + ...
            model.Intermediate_variable.delay_time_part_6 + model.Intermediate_variable.delay_time_part_7 + model.Intermediate_variable.delay_time_part_11;

model.Intermediate_variable.delay_num_2 = model.Intermediate_variable.delay_time_2 / model.Intermediate_variable.system_frame_speed_3 * model.parameter.Buffer5.Output_buffer_size;

% 解调延时2，此处改为fix可短暂的修复bug，后续仍需进一步探寻此处和delay4的延时关系
model.parameter.Delay3.Sample_num = round(model.parameter.Buffer5.Output_buffer_size - mod(model.Intermediate_variable.delay_num_2, model.parameter.Buffer5.Output_buffer_size));
% model.parameter.Delay3.Sample_num = model.parameter.Buffer5.Output_buffer_size - mod(model.Intermediate_variable.delay_num_2, model.parameter.Buffer5.Output_buffer_size);

% 交织解码器参数
model.parameter.Matrix_Deinterleaver.row_num = model.parameter.Matrix_Interleaver.row_nums;
model.parameter.Matrix_Deinterleaver.col_num = model.parameter.Matrix_Interleaver.col_nums;

% 解调缓冲器3
% model.parameter.Buffer6.Output_buffer_size = model.parameter.RS_Encoder.Codeword_Length;


% 解码前的延时
model.Intermediate_variable.delay_time_part_8 = model.parameter.Delay3.Sample_num * model.Intermediate_variable.system_frame_speed_3 / model.parameter.Buffer5.Output_buffer_size; % 延时器3的延时计算
if model.user_defined.TR.Baseband_Modulation_type <= 2
    model.Intermediate_variable.delay_time_part_9 = model.parameter.Buffer3.Output_size * model.Intermediate_variable.system_frame_speed_1/model.parameter.RS_Encoder.Codeword_Length; % buffer3的延时计算
else
    model.Intermediate_variable.delay_time_part_9 = model.parameter.Buffer3.Output_size * model.Intermediate_variable.system_frame_speed_1/model.parameter.Random_Integer_Generator.Samples_per_frame; % buffer3的延时计算
end

if mod(model.parameter.Buffer5.Output_buffer_size, model.parameter.Buffer6.Output_buffer_size) ~= 0
    model.Intermediate_variable.delay_time_part_12 =  model.parameter.Buffer6.Output_buffer_size * model.Intermediate_variable.system_frame_speed_3 / model.parameter.Buffer5.Output_buffer_size; % buffer4处产生的延时计算
else
    model.Intermediate_variable.delay_time_part_12 = 0;
end

model.Intermediate_variable.delay_time_3 = model.Intermediate_variable.delay_time_2 + model.Intermediate_variable.delay_time_part_8 + model.Intermediate_variable.delay_time_part_9 + model.Intermediate_variable.delay_time_part_12;
model.Intermediate_variable.delay_num_3 = model.Intermediate_variable.delay_time_3 / model.Intermediate_variable.system_frame_speed_1 * model.parameter.RS_Encoder.Codeword_Length;
model.parameter.Delay4.delay_sample = round(model.parameter.RS_Encoder.Codeword_Length - mod(model.Intermediate_variable.delay_num_3, model.parameter.RS_Encoder.Codeword_Length));


% RS解码
model.parameter.Integer_Output_RS_Decoder1.Codeword_Length = model.parameter.RS_Encoder.Codeword_Length;
model.parameter.Integer_Output_RS_Decoder1.Message_Length = model.parameter.RS_Encoder.Message_Length;

% 计算误比特率之前的延时
model.Intermediate_variable.delay_time_part_10 = model.parameter.Delay4.delay_sample * model.Intermediate_variable.system_frame_speed_1 / model.parameter.Integer_Output_RS_Decoder1.Codeword_Length;

if model.user_defined.TR.Baseband_Modulation_type <= 2
    model.Intermediate_variable.delay_time_4 = model.Intermediate_variable.delay_time_3 + model.Intermediate_variable.delay_time_part_10;
    model.Intermediate_variable.delay_num_4 = model.Intermediate_variable.delay_time_4 * model.parameter.Integer_Output_RS_Decoder1.Message_Length / model.Intermediate_variable.system_frame_speed_1 ;
else
    model.Intermediate_variable.delay_time_4 = model.Intermediate_variable.delay_time_3;
    model.Intermediate_variable.delay_num_4 = model.Intermediate_variable.delay_time_4 * model.parameter.Integer_Output_RS_Decoder1.Message_Length / model.Intermediate_variable.system_frame_speed_1 ;
end

% 计算误比特率        
model.parameter.bit_num = model.parameter.Random_Integer_Generator.Samples_per_frame;
model.parameter.Integer_to_Bit_Converter.M = model.parameter.bit_num;
model.parameter.Integer_to_Bit_Converter1.M = model.parameter.bit_num;
model.parameter.Error_Rate_Calculation.Receive_delay = round(model.Intermediate_variable.delay_num_4 * model.parameter.bit_num);

% buffer2后的信号帧速率，基带调制与解调的帧信号速率
model.Intermediate_variable.system_frame_speed_4 = model.Intermediate_variable.system_frame_speed_2 / model.parameter.Buffer1.Output_size * model.parameter.Buffer2.Output_buffer_size ;

% 功率估计部分
model.parameter.Buffer.Output_buffer_size = 1;
model.parameter.channel_estimate_fs = model.Intermediate_variable.system_frame_speed_2;

% 信道状态参数速率转换部分
model.parameter.CSI.buffers_length = model.parameter.OFDM_Modulator.output_data_length;
model.parameter.CSI.selector_constant_value = 1:model.Intermediate_variable.system_frame_length_2;
model.parameter.CSI.reshape_dimension = [model.parameter.OFDM_Modulator.output_data_length,1,1];



% 后续画图
% a = strsplit(get_param('Simple_Model_Packaging_2/Selector1','Indices'),',');
% b = a{1,1};

%% 噪声参数修正
try
    if model.Parameters.NoiseGen.NoiseTs < model.Intermediate_variable.system_frame_speed_2 / model.parameter.M_FSK_Modulator_Baseband1.Samples_per_symbol
        model.Parameters.NoiseGen.NoiseTs = model.Intermediate_variable.system_frame_speed_2 / model.parameter.M_FSK_Modulator_Baseband1.Samples_per_symbol;
        message_imply = sprintf("噪声采样时间和信号采样时间不匹配，已将数值更改为:%d s，请重新生成干扰源，注意观察干扰源的频率参数是否符合奈奎斯特采样频率\n", model.Parameters.NoiseGen.NoiseTs);
        warndlg(message_imply,'警告'); 
        model.Parameters.Noise_Sig_Matching_Flag = 1;

        set_param('Simple_Model_Packaging_2','SimulationCommand','stop');
        set_param('Simple_Model_Packaging_2_1','SimulationCommand','stop');
        close(fbar);
        quit('Parameter_Initialize_2.m');

    elseif model.Parameters.NoiseGen.NoiseTs > model.Intermediate_variable.system_frame_speed_2 / model.parameter.M_FSK_Modulator_Baseband1.Samples_per_symbol
        model.Parameters.NoiseGen.NoiseTs = model.Intermediate_variable.system_frame_speed_2 / model.parameter.M_FSK_Modulator_Baseband1.Samples_per_symbol;
        message_imply = sprintf("噪声采样时间和信号采样时间不匹配，已将数值更改为:%d s，不需要重新生成干扰源,但需要点击进入干扰源界面更新采样率参数\n", model.Parameters.NoiseGen.NoiseTs);
        warndlg(message_imply,'警告'); 
        model.Parameters.Noise_Sig_Matching_Flag = 1;
    else
        if quick_simulation_flag == 0
            message_imply = sprintf("噪声采样时间和信号采样时间匹配，开始仿真\n");
            warndlg(message_imply,'警告');
        end
    end
end

