%% 模型6的参数初始化(基于模型4的更改）

%% 输入参数整理
% 帧信号基带调制
model.Parameters.Noise_Sig_Matching_Flag = 0;
model.parameter.Repeating_Sequence_Stair.output_vector = model.user_defined.Repeating_Sequence_Stair.output_vector;
model.parameter.Repeating_Sequence_Stair.CodeTs        = model.user_defined.Repeating_Sequence_Stair.CodeTs       ;
% model.parameter.M_PAM_Modulator_Baseband.M_ary_number  = model.user_defined.M_PAM_Modulator_Baseband.M_ary_number ;

% 帧信号本地载波生成参数
model.parameter.Digital_Clock2.CarrierTs = model.user_defined.Digital_Clock2.CarrierTs ; % 载波采样频率
model.parameter.Sine_Carrier_Num = model.user_defined.Sine_Carrier_Num ;
model.parameter.Sine_Carrier_Freq = model.user_defined.Sine_Carrier_Freq ;
model.parameter.Sine_Carrier_Ampl = model.user_defined.Sine_Carrier_Ampl ;

% 升余弦滚降滤波
model.parameter.Raised_Cosine_Transmit_Filter.Rolloff_factor            = model.user_defined.Raised_Cosine_Transmit_Filter.Rolloff_factor           ;
model.parameter.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols    = model.user_defined.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols   ;
model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol = model.user_defined.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;

% % 帧信号射频调制
% model.parameter.Gain3.value = model.user_defined.Gain3.value;            
% model.parameter.Gain1.value = model.user_defined.Gain1.value;   

% 信源部分基带调制
% 随机整数生成器
model.parameter.Random_Integer_Generator.Set_size          = model.user_defined.Random_Integer_Generator.Set_size          ;  % 随机整数不能大于2^nextpow2(model.parameter.RS_Encoder.Codeword_Length)，同样也不能太小，否则误码率比较部分会出错
model.parameter.Random_Integer_Generator.Samples_per_frame = model.user_defined.Random_Integer_Generator.Samples_per_frame ;

% RS编码
model.parameter.RS_Encoder.Codeword_length = model.user_defined.RS_Encoder.Codeword_length;  %% 必须是10的整数被倍

% 基带调制进制数
model.parameter.Rectangular_QAM_Modulator_Baseband.M_ary_number = model.user_defined.Rectangular_QAM_Modulator_Baseband.M_Number;    % QAM基带调制,一定要是2的整数次幂

% 滚降滤波
model.parameter.Raised_Cosine_Transmit_Filter1.Rolloff_factor           = model.user_defined.Raised_Cosine_Transmit_Filter1.Rolloff_factor          ;
model.parameter.Raised_Cosine_Transmit_Filter1.Filter_span_in_symbols   = model.user_defined.Raised_Cosine_Transmit_Filter1.Filter_span_in_symbols  ;
model.parameter.Raised_Cosine_Transmit_Filter1.Input_samples_per_symbol = model.user_defined.Raised_Cosine_Transmit_Filter1.Input_samples_per_symbol;

% 跳频调制
model.parameter.M_FSK_Modulator_Baseband1.M_ary_number         = model.user_defined.M_FSK_Modulator_Baseband1.M_ary_number        ;
model.parameter.M_FSK_Modulator_Baseband1.Frequency_separation = model.user_defined.M_FSK_Modulator_Baseband1.Frequency_separation;
model.parameter.PN_Sequence_Generator1.Generator_polynomial    = model.user_defined.PN_Sequence_Generator1.Generator_polynomial   ;
model.parameter.PN_Sequence_Generator1.Initial_states          = model.user_defined.PN_Sequence_Generator1.Initial_states         ;

% 信道部分
model.parameter.Awgn.SNR         = model.user_defined.Awgn.SNR        ;
model.parameter.Awgn.input_power = model.user_defined.Awgn.input_power;

% 帧信号时序控制
model.parameter.Transmit_timing_control.Waveform_Period          = model.user_defined.Transmit_timing_control.Waveform_Period         ;       %% 波形周期
model.parameter.Transmit_timing_control.Frame_Period_Unit_Number = model.user_defined.Transmit_timing_control.Frame_Period_Unit_Number;       %% 帧头帧尾信号个数
model.parameter.Transmit_timing_control.Signal_Source_Duration   = model.user_defined.Transmit_timing_control.Signal_Source_Duration  ;       %% 信源持续时间长度

% 速率转换处的系数校准
model.parameter.Rate_Transition.Ts_Multiple = model.user_defined.Rate_Transition.Ts_Multiple;


%% 帧信号基带调制模块
% PAM调制
model.parameter.M_PAM_Modulator_Baseband.Minimum_distance = 2;

% buffer12长度设置
model.parameter.Buffer12.Output_buffer_size = 40 * model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;
model.Intermediate_variable.system_frame_speed_1 = model.parameter.Repeating_Sequence_Stair.CodeTs;
model.Intermediate_variable.system_frame_speed_2 = model.parameter.Buffer12.Output_buffer_size * model.Intermediate_variable.system_frame_speed_1 / model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;

model.parameter.Buffer1.Output_buffer_size = round(model.Intermediate_variable.system_frame_speed_1 / model.Intermediate_variable.system_frame_speed_2 * model.parameter.Buffer12.Output_buffer_size*10);  % 此处buffer的设计需要让插值后buffer的速率等于帧信号的编码速率
model.Intermediate_variable.system_frame_speed_3 = model.Intermediate_variable.system_frame_speed_1 / model.parameter.Buffer1.Output_buffer_size;

%% 帧信号射频调制
model.parameter.Buffer121.Output_buffer_size = round(model.parameter.Buffer1.Output_buffer_size);              
model.parameter.Buffer100.Output_buffer_size = 1;  

model.parameter.Digital_Clock2.CarrierTs = model.parameter.Repeating_Sequence_Stair.CodeTs / model.parameter.Buffer121.Output_buffer_size;

% 帧信号射频调制处的延时计算
model.Intermediate_variable.delay2_time_part_1 = model.Intermediate_variable.system_frame_speed_1/model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol * (model.parameter.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols*model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol/2); % 帧信号基带调制处的滚降滤波部分
model.Intermediate_variable.delay2_time_part_2 = model.parameter.Buffer12.Output_buffer_size * model.Intermediate_variable.system_frame_speed_1 / model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;  % 帧信号基带调制处的buffer12部分
model.Intermediate_variable.delay2_time_part_3 = model.parameter.Buffer121.Output_buffer_size * model.parameter.Digital_Clock2.CarrierTs;  % 帧信号基带调制处的buffer12部分

model.Intermediate_variable.delay2_time = model.Intermediate_variable.delay2_time_part_1 + model.Intermediate_variable.delay2_time_part_2 - model.Intermediate_variable.delay2_time_part_3;
model.parameter.Delay.delay_length = round(model.Intermediate_variable.delay2_time / model.Intermediate_variable.system_frame_speed_1 * model.parameter.Buffer121.Output_buffer_size);

%% 信源部分基带调制
% model.parameter.RS_Encoder.Codeword_length = model.parameter.Rectangular_QAM_Modulator_Baseband.M_ary_number - 1;
model.parameter.RS_Encoder.Message_length = model.parameter.Random_Integer_Generator.Samples_per_frame;

% 信道交织
model.parameter.Matrix_Interleaver.row_nums = 12;
model.parameter.Matrix_Interleaver.col_nums = 10;

model.parameter.Buffer30.Output_buffer_size = model.parameter.Matrix_Interleaver.row_nums * model.parameter.Matrix_Interleaver.col_nums; 
if model.user_defined.TR.Baseband_Modulation_type <= 2
    model.parameter.Buffer40.Output_buffer_size = model.parameter.RS_Encoder.Codeword_length;
    model.parameter.Buffer5.Output_buffer_size = model.parameter.RS_Encoder.Codeword_length;
else
    model.parameter.Buffer40.Output_buffer_size = model.parameter.Random_Integer_Generator.Samples_per_frame;
    model.parameter.Buffer5.Output_buffer_size = model.parameter.Random_Integer_Generator.Samples_per_frame;
end

% 基带调制
model.parameter.Rectangular_QAM_Modulator_Baseband.Minimum_distance = 2;


%% 跳频调制
% 伪随机序列生成器
model.parameter.PN_Sequence_Generator1.Samples_per_frame = nextpow2(model.parameter.M_FSK_Modulator_Baseband1.M_ary_number);
% model.parameter.PN_Sequence_Generator1.Sample_time = model.Intermediate_variable.system_frame_speed_2/model.parameter.PN_Sequence_Generator1.Samples_per_frame; % (381e-6)/127/4*25;

% 整数转换器
model.parameter.Bit_to_Integer_Converter.M = model.parameter.PN_Sequence_Generator1.Samples_per_frame;

% FSK调制频点数
if model.user_defined.TR.Baseband_Modulation_type <= 3
    model.parameter.M_FSK_Modulator_Baseband1.Samples_per_symbol = model.parameter.Raised_Cosine_Transmit_Filter1.Input_samples_per_symbol * model.parameter.Buffer40.Output_buffer_size;
else
   model.parameter.M_FSK_Modulator_Baseband1.Samples_per_symbol = model.parameter.Raised_Cosine_Transmit_Filter1.Input_samples_per_symbol * model.parameter.Buffer40.Output_buffer_size*2;
end

model.Intermediate_variable.system_frame_speed_4 = model.Intermediate_variable.system_frame_speed_3 * model.parameter.M_FSK_Modulator_Baseband1.Samples_per_symbol;

model.parameter.Random_Integer_Generator.SignalSourceTs = model.Intermediate_variable.system_frame_speed_4 / model.parameter.Random_Integer_Generator.Samples_per_frame;
model.parameter.PN_Sequence_Generator1.Sample_time = model.Intermediate_variable.system_frame_speed_4 / model.parameter.PN_Sequence_Generator1.Samples_per_frame;

model.parameter.Buffer2.Output_buffer_size = 1;     % buffer2 长度设置

%% 帧信号和信源信号混合（包含信道部分）
% 帧信号混合部分
model.parameter.Digital_Clock4.Ts = model.parameter.Digital_Clock2.CarrierTs;           % 模块处理数据的时钟
model.parameter.Transmit_timing_control.Ts = model.parameter.Digital_Clock2.CarrierTs;  % 模块处理数据的采样间隔

%% 帧信号延时同步解调
model.parameter.Buffer3.Output_buffer_size = 1000;     %% 此处的堆栈长度设置仍值得后续多多研究
model.parameter.Buffer4.Output_buffer_size = 1000;     %% 最好还是1000，保持接收端帧信号处理速率与发送端一致

%% 接收端本地载波
model.Intermediate_variable.delay1_time = model.Intermediate_variable.system_frame_speed_3 * model.parameter.Buffer3.Output_buffer_size;

model.parameter.Buffer9.Output_buffer_size = model.parameter.Buffer4.Output_buffer_size;
model.parameter.Delay5.samples_length = round(model.Intermediate_variable.delay1_time / model.Intermediate_variable.system_frame_speed_3);

% 帧信号的整体延时计算
model.Intermediate_variable.delay9_time_part_1 = model.Intermediate_variable.delay1_time;
model.Intermediate_variable.delay9_time_part_2 = model.Intermediate_variable.delay2_time_part_2;
model.Intermediate_variable.delay9_time_part_3 = model.Intermediate_variable.delay2_time_part_1;

model.Intermediate_variable.delay9_time = model.Intermediate_variable.delay9_time_part_1 + model.Intermediate_variable.delay9_time_part_2 + model.Intermediate_variable.delay9_time_part_3;

% 帧信号时序控制
model.parameter.Transmit_timing_control.Waveform_Offset = model.Intermediate_variable.delay9_time;                %% 发射机发送每跳信号的起始点控制
model.parameter.Transmit_timing_control.Frame_Period_Unit_Duration = length(model.parameter.Repeating_Sequence_Stair.output_vector) * ...
    model.parameter.Repeating_Sequence_Stair.CodeTs;                                                              %% 帧头信号持续时间的长度，该参数与帧信号的码元周期有关

%% 约束关系罗列
model.parameter.Transmit_timing_control.Frame_Back_StartPoint_Offset_Control = model.parameter.Transmit_timing_control.Waveform_Period - model.parameter.Transmit_timing_control.Signal_Source_Duration...
    - model.parameter.Transmit_timing_control.Frame_Period_Unit_Number * model.parameter.Transmit_timing_control.Frame_Period_Unit_Duration * 2; %% 帧周期的空隙间隔                         

%% 帧信号合并与去本地载波
% model.parameter.Gain2.value = 1/model.parameter.Gain1.value;
% model.parameter.Constant1.value = model.parameter.Gain3.value;
model.parameter.Buffer6.Output_buffer_size = 1;

%% 帧信号基带解调
model.parameter.Buffer7.Output_buffer_size = 10 * model.parameter.Buffer12.Output_buffer_size;
model.parameter.Buffer11.Output_buffer_size = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;

% 帧信号匹配滤波
model.parameter.Raised_Cosine_Receive_Filter.Rolloff_factor = model.parameter.Raised_Cosine_Transmit_Filter.Rolloff_factor;
model.parameter.Raised_Cosine_Receive_Filter.Filter_span_in_symbols = model.parameter.Raised_Cosine_Transmit_Filter.Filter_span_in_symbols;
model.parameter.Raised_Cosine_Receive_Filter.Input_samples_per_symbol = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;
model.parameter.Raised_Cosine_Receive_Filter.Decimation_factor = model.parameter.Raised_Cosine_Transmit_Filter.Output_samples_per_symbol;

% PAM解调
% model.parameter.M_PAM_Demodulator_Baseband.M_ary_number = model.parameter.M_PAM_Modulator_Baseband.M_ary_number;
% model.parameter.M_PAM_Demodulator_Baseband.Minimum_distance = model.parameter.M_PAM_Modulator_Baseband.Minimum_distance;

% 基带解调处延时的计算
model.Intermediate_variable.delay2_time_2 = model.Intermediate_variable.delay2_time_part_1 + model.Intermediate_variable.delay2_time_part_2;   
model.Intermediate_variable.delay3_time_part_1 = model.parameter.Buffer7.Output_buffer_size * model.Intermediate_variable.system_frame_speed_3;  % 基带解调处buffer7的时延计算
model.Intermediate_variable.delay3_time_part_2 = model.Intermediate_variable.delay2_time_part_1;  % 接收端滚降滤波的时延计算
model.Intermediate_variable.delay3_time = model.Intermediate_variable.delay3_time_part_1 + model.Intermediate_variable.delay3_time_part_2 + model.Intermediate_variable.delay1_time;


%% 帧信号控制模块，此处对帧时序有隐含的约束关系！！！   前一帧的帧尾和下一帧的帧头之间要大于4.1个帧持续时间
model.parameter.Frame_control_func.Ts = model.Intermediate_variable.system_frame_speed_1;

%% 接收端信源的时序控制(帧头对帧尾的控制作用)
model.parameter.Beffer5.Output_buffer_size = model.parameter.M_FSK_Modulator_Baseband1.Samples_per_symbol;

model.parameter.Delay7.samples_length = round(model.Intermediate_variable.delay3_time / model.Intermediate_variable.system_frame_speed_3);

%% 信源相干解调
% 信源信号处延时的计算
model.Intermediate_variable.delay4_time = model.parameter.Beffer5.Output_buffer_size * model.Intermediate_variable.system_frame_speed_3; % 接收端信源时序控制处buffer5的延时
model.parameter.Delay3.samples_length = round(model.parameter.Delay7.samples_length + model.Intermediate_variable.delay4_time/model.Intermediate_variable.system_frame_speed_3);

%% 信源基带解调
% 信源匹配滤波
model.parameter.Raised_Cosine_Receive_Filter1.Rolloff_factor = model.parameter.Raised_Cosine_Transmit_Filter1.Rolloff_factor;
model.parameter.Raised_Cosine_Receive_Filter1.Filter_span_in_symbols = model.parameter.Raised_Cosine_Transmit_Filter1.Filter_span_in_symbols;
model.parameter.Raised_Cosine_Receive_Filter1.Input_samples_per_symbol = model.parameter.Raised_Cosine_Transmit_Filter1.Input_samples_per_symbol;
model.parameter.Raised_Cosine_Receive_Filter1.Decimation_fatocr = model.parameter.Raised_Cosine_Transmit_Filter1.Input_samples_per_symbol;

% 信源基带解调
model.parameter.Rectangular_QAM_Demodulator_Baseband.M_ary_number = model.parameter.Rectangular_QAM_Modulator_Baseband.M_ary_number;
model.parameter.Rectangular_QAM_Demodulator_Baseband.Minimum_distance = model.parameter.Rectangular_QAM_Modulator_Baseband.Minimum_distance;

%% 信源RS解码
model.parameter.Buffer8.Output_buffer_size = model.parameter.Buffer30.Output_buffer_size;

% 信道解交织
model.parameter.Matrix_Deinterleaver.row_nums = model.parameter.Matrix_Interleaver.row_nums;
model.parameter.Matrix_Deinterleaver.col_nums = model.parameter.Matrix_Interleaver.col_nums;

% 信道解交织前的延时计算
model.Intermediate_variable.delay5_time_part_1 = model.Intermediate_variable.system_frame_speed_4/model.parameter.Beffer5.Output_buffer_size * (model.parameter.Raised_Cosine_Receive_Filter1.Filter_span_in_symbols * ...
    model.parameter.Raised_Cosine_Receive_Filter1.Input_samples_per_symbol/2);  % 接收端信源的基带解调 匹配滤波延时

model.Intermediate_variable.delay5_time_part_3 = model.parameter.Delay3.samples_length * model.Intermediate_variable.system_frame_speed_3; % 接收端信源时序控制 Delay7处和buffer5处的延时之和
model.Intermediate_variable.delay5_time_part_4 = model.Intermediate_variable.delay5_time_part_1;  % 发送端信源的基带解调 滚降滤波延时

if model.user_defined.TR.Baseband_Modulation_type <= 2
    model.Intermediate_variable.system_frame_speed_5 = model.Intermediate_variable.system_frame_speed_4 / model.parameter.RS_Encoder.Codeword_length * model.parameter.Buffer8.Output_buffer_size;
    model.Intermediate_variable.delay5_time_part_2 = model.parameter.Buffer8.Output_buffer_size * model.Intermediate_variable.system_frame_speed_4 / model.parameter.RS_Encoder.Codeword_length; % 接收端信源的RS解码 buffer8延时

elseif model.user_defined.TR.Baseband_Modulation_type == 3
    model.Intermediate_variable.system_frame_speed_5 = model.Intermediate_variable.system_frame_speed_4 / model.parameter.Random_Integer_Generator.Samples_per_frame * model.parameter.Buffer8.Output_buffer_size;
    model.Intermediate_variable.delay5_time_part_2 = model.parameter.Buffer8.Output_buffer_size * model.Intermediate_variable.system_frame_speed_4 / model.parameter.Random_Integer_Generator.Samples_per_frame; % 接收端信源的RS解码 buffer8延时
else
    model.Intermediate_variable.system_frame_speed_5 = model.Intermediate_variable.system_frame_speed_4 / model.parameter.Random_Integer_Generator.Samples_per_frame * model.parameter.Buffer8.Output_buffer_size;
    model.Intermediate_variable.delay5_time_part_2 = model.parameter.Buffer8.Output_buffer_size * model.Intermediate_variable.system_frame_speed_4 / ...
        model.parameter.Random_Integer_Generator.Samples_per_frame + model.Intermediate_variable.system_frame_speed_4/model.parameter.Random_Integer_Generator.Samples_per_frame; % 接收端信源的RS解码 buffer8延时 + OQPSK解调延时
end

model.Intermediate_variable.delay5_time = model.Intermediate_variable.delay5_time_part_1 + model.Intermediate_variable.delay5_time_part_2 + model.Intermediate_variable.delay5_time_part_3 +...
    model.Intermediate_variable.delay5_time_part_4;
model.Intermediate_variable.delay5_time_delay_length = model.Intermediate_variable.delay5_time / model.Intermediate_variable.system_frame_speed_5 * model.parameter.Buffer8.Output_buffer_size;

% model.parameter.Delay4.samples_length = 120;
model.parameter.Delay4.samples_length = round(model.parameter.Matrix_Deinterleaver.row_nums * model.parameter.Matrix_Deinterleaver.col_nums - mod(model.Intermediate_variable.delay5_time_delay_length, model.parameter.Matrix_Deinterleaver.row_nums * model.parameter.Matrix_Deinterleaver.col_nums));

% RS解码
model.parameter.Integer_Output_RS_Decoder1.Codeword_length = model.parameter.RS_Encoder.Codeword_length;
model.parameter.Integer_Output_RS_Decoder1.Message_length = model.parameter.RS_Encoder.Message_length;

% RS解码前的延时计算
model.Intermediate_variable.delay6_time_part_1 = model.parameter.Delay4.samples_length * model.Intermediate_variable.system_frame_speed_5/model.parameter.Buffer8.Output_buffer_size; % 解码前交织处 Delay4的延时计算

if model.user_defined.TR.Baseband_Modulation_type <= 2
    model.Intermediate_variable.delay6_time_part_2 = model.parameter.Buffer30.Output_buffer_size * model.Intermediate_variable.system_frame_speed_4 / model.parameter.RS_Encoder.Codeword_length; % 基带调制buffer30处的延时计算
else
    model.Intermediate_variable.delay6_time_part_2 = model.parameter.Buffer30.Output_buffer_size * model.Intermediate_variable.system_frame_speed_4 / model.parameter.Random_Integer_Generator.Samples_per_frame;
end

model.Intermediate_variable.delay6_time = model.Intermediate_variable.delay5_time + model.Intermediate_variable.delay6_time_part_1 + model.Intermediate_variable.delay6_time_part_2;
model.Intermediate_variable.delay6_time_delay_length = model.Intermediate_variable.delay6_time / model.Intermediate_variable.system_frame_speed_4 * model.parameter.RS_Encoder.Codeword_length;

% 延时单元
if model.user_defined.TR.Baseband_Modulation_type <= 2
    model.parameter.Delay10.samples_length = round(model.parameter.Integer_Output_RS_Decoder1.Codeword_length - mod(model.Intermediate_variable.delay6_time_delay_length, model.parameter.Integer_Output_RS_Decoder1.Codeword_length));
else
    model.parameter.Delay10.samples_length = 0;
end

% 信源随机码进入帧信号混合相加前的延时同步
model.Intermediate_variable.delay7_time_part_1 = model.Intermediate_variable.delay6_time_part_2;  % 基带调制buffer30处的延时计算
model.Intermediate_variable.delay7_time_part_2 = model.Intermediate_variable.delay5_time_part_4;  % 发送端信源的基带解调 滚降滤波延时
model.Intermediate_variable.delay7_time = model.Intermediate_variable.delay7_time_part_1 + model.Intermediate_variable.delay7_time_part_2;

model.Intermediate_variable.delay7_time_delay_length = model.Intermediate_variable.delay7_time / model.Intermediate_variable.system_frame_speed_4 * model.parameter.Random_Integer_Generator.Samples_per_frame;
model.parameter.Delay11.samples_length = round(model.Intermediate_variable.delay7_time_delay_length); % 该变量需要着重注意
model.parameter.Buffer14.Output_buffer_size = 1;

% 对发送端信号和RS解码后的信号进行时序控制
% Rate_Transition模块的参数还须加以严格限制！！！！！！！！！！ 此处的延时与信源的进制数、帧信号的采样时间也有关系！！！！！！
model.parameter.Delay2.Output_buffer_size = round(model.parameter.Delay7.samples_length); % 进行信源相干解调前同样的延时

model.parameter.Buffer10.Output_buffer_size = model.parameter.Random_Integer_Generator.Samples_per_frame;
model.parameter.Rate_Transition.Ts = model.Intermediate_variable.system_frame_speed_4 / model.parameter.Buffer10.Output_buffer_size;

% 发送端信号时序控制的Delay6的延时计算
model.Intermediate_variable.delay7_time_part_1 = model.Intermediate_variable.delay4_time; % buffer5处的延时
model.Intermediate_variable.delay7_time_part_2 = model.parameter.Delay3.samples_length *  ...
    model.Intermediate_variable.system_frame_speed_4 / model.parameter.Beffer5.Output_buffer_size; % Delay3处的延时，这个感觉不需要
model.Intermediate_variable.delay7_time_part_3 = model.Intermediate_variable.delay5_time_part_1; % 接收端信源的基带解调 匹配滤波延时
model.Intermediate_variable.delay7_time_part_4 = model.Intermediate_variable.delay5_time_part_2 + model.Intermediate_variable.delay6_time_part_1; % 信源RS解码 buffer8和delay4处的延时之和

if model.user_defined.TR.Baseband_Modulation_type <= 2
    model.Intermediate_variable.delay7_time_part_5 = model.parameter.Delay10.samples_length * model.Intermediate_variable.system_frame_speed_4 / model.parameter.Buffer5.Output_buffer_size; % Delay10处的延时
else
    model.Intermediate_variable.delay7_time_part_5 = 0;
end

model.Intermediate_variable.delay7_time_part_6 = model.parameter.Buffer10.Output_buffer_size * model.parameter.Rate_Transition.Ts; % 发送端时序控制buffer10处产生的延时

% 此处为什么乘2仍需进一步研究！！！
% 可能是delay6处四舍五入时，有时会造成多延时一部分，此时就需要Rate_Transition模块少延时来逼近真实的延时情况，计划通过设置判断条件来进行解决

model.Intermediate_variable.delay7_time_part_7 = model.parameter.Rate_Transition.Ts * model.parameter.Rate_Transition.Ts_Multiple;  %% 信源帧大小为3、4时系数为1，帧大小为5时系数为2，当采样速率为15e-5时，此处系数也变为2
% model.Intermediate_variable.delay7_time_part_7 = model.parameter.Rate_Transition.Ts; % 使用Rate Transition2 和 Rate Transition时，慢速变快速时会有单位延时

model.Intermediate_variable.delay7_time = model.Intermediate_variable.delay7_time_part_1 + ...
    + model.Intermediate_variable.delay7_time_part_3 + model.Intermediate_variable.delay7_time_part_4 + model.Intermediate_variable.delay7_time_part_5 - ...
    model.Intermediate_variable.delay7_time_part_6 - model.Intermediate_variable.delay7_time_part_7;  % 总延时应没有Delay3处的延时

model.Intermediate_variable.delay7_time_delay_length = model.Intermediate_variable.delay7_time / model.Intermediate_variable.system_frame_speed_4 * model.parameter.Buffer10.Output_buffer_size;

% 注意，此时model.Intermediate_variable.delay7_time_delay_length为真正需要延时的长度，model.parameter.Delay6.Output_buffer_size为由于离散化实际所延时间，需要进一步补足实际时延
model.parameter.Delay6.Output_buffer_size = round(model.Intermediate_variable.delay7_time_delay_length); 


%% 对RS解码后的信号进行时序控制，还须研究，究竟何种时序最佳
model.parameter.Delay14.Output_buffer_size = round(model.parameter.Delay7.samples_length);
model.parameter.Buffer13.Output_buffer_size = model.parameter.Random_Integer_Generator.Samples_per_frame;
model.parameter.Rate_Transition1.Ts = model.Intermediate_variable.system_frame_speed_4 / model.parameter.Buffer10.Output_buffer_size;

if model.user_defined.TR.Baseband_Modulation_type <= 2
    model.parameter.Delay8.Output_buffer_size = model.parameter.Delay6.Output_buffer_size; % Delay8决定了时序终点，与delay6的差值是时序终点的提前分量,一个model.parameter.Buffer10.Output_buffer_size相当于一个system_frame_speed_4
    model.Intermediate_variable.delay8_time = model.Intermediate_variable.system_frame_speed_4 + model.Intermediate_variable.system_frame_speed_5 ; % 基带帧速率（RS编码的最大延迟） + 交织帧速率（交织的最大延迟）
    model.parameter.Delay9.Output_buffer_size = ceil(model.Intermediate_variable.delay8_time / model.Intermediate_variable.system_frame_speed_4 *...
        model.parameter.Random_Integer_Generator.Samples_per_frame); % Delay9决定了时序起点，其值就是对经时序终点提前后的时序起点，在做相应值的偏移得到时序起点
else
    model.parameter.Delay8.Output_buffer_size = model.parameter.Delay6.Output_buffer_size - model.parameter.Buffer8.Output_buffer_size; % Delay8决定了时序终点

    model.Intermediate_variable.delay8_time = model.Intermediate_variable.system_frame_speed_5 ; % 交织帧速率（交织的最大延迟）
    model.parameter.Delay9.Output_buffer_size = ceil(model.Intermediate_variable.delay8_time / model.Intermediate_variable.system_frame_speed_4 *...
        model.parameter.Random_Integer_Generator.Samples_per_frame) + model.parameter.Buffer8.Output_buffer_size;  % Delay9决定了时序起点，交织的最大延迟 + 时序终点带来的时序起点提前量
end


%% 误码率比较模块
% 计算误比特率之前的延时
% model.Intermediate_variable.delay_time_part_10 = model.parameter.Delay4.delay_sample * model.Intermediate_variable.system_frame_speed_1 / model.parameter.Integer_Output_RS_Decoder1.Codeword_Length;
% 
% model.Intermediate_variable.delay_time_4 = model.Intermediate_variable.delay_time_3 + model.Intermediate_variable.delay_time_part_10;
% model.Intermediate_variable.delay_num_4 = model.Intermediate_variable.delay_time_4 * model.parameter.Integer_Output_RS_Decoder1.Message_Length / model.Intermediate_variable.system_frame_speed_1 ;

% 计算误比特率
% model.parameter.bit_num = nextpow2(model.parameter.Random_Integer_Generator.Set_size);  % model.parameter.Random_Integer_Generator.Samples_per_frame
model.parameter.bit_num = model.parameter.Random_Integer_Generator.Samples_per_frame;
model.parameter.Integer_to_Bit_Converter.M = model.parameter.bit_num; 
model.parameter.Integer_to_Bit_Converter1.M = model.parameter.bit_num;
model.parameter.Error_Rate_Calculation.Receive_delay = 0*4;

model.Intermediate_variable.system_frame_speed_6 = model.Intermediate_variable.system_frame_speed_4 / model.parameter.M_FSK_Modulator_Baseband1.Samples_per_symbol;
model.Intermediate_variable.Ratio_Multiply_1 = model.Intermediate_variable.system_frame_speed_6 / model.Intermediate_variable.system_frame_speed_3;

% 后续画图
% a = strsplit(get_param('Simple_Model_Packaging_2/Selector1','Indices'),',');
% b = a{1,1};

%% 噪声采样时间修正
try
    if model.Parameters.NoiseGen.NoiseTs < model.parameter.Digital_Clock2.CarrierTs
        model.Parameters.NoiseGen.NoiseTs = model.parameter.Digital_Clock2.CarrierTs;
        message_imply = sprintf("噪声采样时间和信号采样时间不匹配，已将数值更改为:%d s，请重新生成干扰源，注意观察干扰源的频率参数是否符合奈奎斯特采样频率\n", model.Parameters.NoiseGen.NoiseTs);
        warndlg(message_imply,'警告');
        model.Parameters.Noise_Sig_Matching_Flag = 1;

        set_param('Simple_Model_Packaging_4','SimulationCommand','stop');
        set_param('Simple_Model_Packaging_4_1','SimulationCommand','stop');
        close(fbar);
        %     error('程序终止');
        quit('Parameter_Initialize_4.m');
    elseif model.Parameters.NoiseGen.NoiseTs > model.parameter.Digital_Clock2.CarrierTs
        model.Parameters.NoiseGen.NoiseTs = model.parameter.Digital_Clock2.CarrierTs;
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
