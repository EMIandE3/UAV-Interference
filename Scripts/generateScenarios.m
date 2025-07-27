function scenarios = generateScenarios(varargin)
% GENERATESCENARIOS 生成干扰场景参数结构体数组
% 输入参数（可选名称-值对）:
%   'SourceTypes'      - 信号源类型数量（默认4）
%   'InterferenceTypes'- 干扰方法类型数量（默认2）
%   'InterferenceNums' - 干扰数量级数（默认4）
%   'BandwidthOptions' - 带宽可变选项数（默认2）
%   'SequenceNum'     - 干扰序列数量（默认4）
% 输出:
%   scenarios - 包含所有参数配置的结构体数组

% 参数解析（带默认值）
p = inputParser;
addParameter(p, 'SourceTypes', 4, @isnumeric);
addParameter(p, 'InterferenceTypes', 2, @isnumeric); 
addParameter(p, 'InterferenceNums', 4, @isnumeric);
addParameter(p, 'BandwidthOptions', 2, @isnumeric);
addParameter(p, 'SequenceNum', 4, @isnumeric);
parse(p, varargin{:});

% 解包参数
st_num = p.Results.SourceTypes;
im_num = p.Results.InterferenceTypes;
in_num = p.Results.InterferenceNums;
bw_num = p.Results.BandwidthOptions;
seq_num = p.Results.SequenceNum;

% 初始化结构体模板（网页6结构体操作参考）
baseScenario = struct(...
    'Source_type', '',...
    'Interference_method', '',...
    'Interference_number', 0,...
    'Interference_sequence_number', seq_num,... % 使用动态参数
    'Bw_is_variable', 'False',...
    'lb', [],...
    'ub', [],...
    'x0', [],...
    'ExtraParams', '');

% 预分配结构体数组（网页6优化建议）
total_scenarios = st_num * im_num * in_num * bw_num;
scenarios = repmat(baseScenario, 1, total_scenarios);

% 配置枚举列表（网页1代码规范）
global Interference_source_config;
source_list = Interference_source_config.source_list;
method_list = Interference_source_config.method_list;
bw_list = Interference_source_config.bw_list;

% 四维参数空间遍历
counter = 1;
for bw_idx = 1:bw_num
    for src_idx = 1:st_num
        for method_idx = 1:im_num
            for intf_idx = 1:in_num
                % 动态生成参数（网页5函数封装思想）
                [lb, ub, x0, extra] = generateParams(...
                    source_list(src_idx),...
                    method_list(method_idx),...
                    intf_idx,...
                    seq_num,...
                    bw_list(bw_idx));
                
                % 填充结构体字段（网页6结构体操作）
                scenarios(counter).Source_type = char(source_list(src_idx));
                scenarios(counter).Interference_method = char(method_list(method_idx));
                scenarios(counter).Interference_number = intf_idx;
                scenarios(counter).Bw_is_variable = char(bw_list(bw_idx));
                scenarios(counter).lb = lb;
                scenarios(counter).ub = ub;
                scenarios(counter).x0 = x0;
                scenarios(counter).ExtraParams = extra;
                
                counter = counter + 1;
            end
        end
    end
end

% 嵌套参数生成函数（网页1函数封装规范）
    function [lb, ub, x0, extraStr] = generateParams(sourceType, method, intfNum, seqNum, bwFlag)
        % 基础参数模板
        if strcmp(bwFlag, 'True')
            bw_lb = [10e3, 10e3];
            bw_ub = [2.4e6, 1.2e6];
        else
            bw_lb = [];
            bw_ub = [];
        end

        % 源类型参数（网页4参数优化）
        switch sourceType
            case '单音正弦噪声'
                src_lb = Interference_source_config.SinNoise_lb;
                src_ub = Interference_source_config.SinNoise_ub;
            case '随机二元码调制噪声'
                src_lb = Interference_source_config.RandomBNoise_lb;
                src_ub = Interference_source_config.RandomBNoise_ub;
            case 'PN码MSK噪声'
                src_lb = Interference_source_config.PNMSKNoise_lb;
                src_ub = Interference_source_config.PNMSKNoise_ub;
            case '脉冲噪声'
                src_lb = Interference_source_config.PulseNoise_lb;
                src_ub = Interference_source_config.PulseNoise_ub;
        end

        % 干扰方法参数（网页5动态生成实践）
        switch method
            case '步进调频'
                method_lb = Interference_source_config.StepSweep_lb;
                method_ub = Interference_source_config.StepSweep_ub;

                seqNum_lb = [];
                seqNum_ub = [];

                extraStr = generateExtraParams(intfNum, length([bw_lb, src_lb, method_lb, seqNum_lb]));
                
            case '跳频干扰'
                method_lb = Interference_source_config.HopSweep_lb;
                method_ub = Interference_source_config.HopSweep_ub;

                seqNum_lb = zeros(1, seqNum);
                seqNum_ub = seqNum * ones(1, seqNum) - 1;

                seq_params = generateSequenceParams(seqNum, length([bw_lb, src_lb, method_lb]));
                extraStr = [seq_params, generateExtraParams(intfNum, length([bw_lb, src_lb, method_lb]) + seqNum )];
        end

        Interference_freq_start_point = Interference_source_config.Interference_freq_start_point;
        Interference_freq_end_point = Interference_source_config.Interference_freq_end_point;
        Sweep_freq_offset = Interference_source_config.Sweep_freq_offset;
        Freq_section_gap = (Interference_freq_end_point - Interference_freq_start_point) / (intfNum-1);

        if intfNum == 1
            intfNum_lb = [];
            intfNum_ub = [];
        else
            intfNum_lb = Interference_freq_start_point:Freq_section_gap:Interference_freq_end_point;
            intfNum_ub = intfNum_lb + Sweep_freq_offset;
        end

        % 合成最终参数
        lb = [bw_lb, src_lb, method_lb, seqNum_lb, intfNum_lb];
        ub = [bw_ub, src_ub, method_ub, seqNum_ub, intfNum_ub];
        x0 = (lb + ub)/2;
        
        % 子函数：生成额外参数（网页5字符串处理）
        function str = generateExtraParams(numParams, offset)
            if numParams == 1
                str = [];
            else
                params = arrayfun(@(k) sprintf('''MultiFreqFValue%d'',round(x(%d))',...
                    k, k+offset), 1:numParams, 'UniformOutput', false);
                str = [', ' strjoin(params, ', ')];
            end
        end
        
        function str = generateSequenceParams(numSeq, offset)
            params = arrayfun(@(k) sprintf('''MultiFreqSkipSequenceValue%d'',round(x(%d))',...
                k, k+offset), 1:numSeq, 'UniformOutput', false);
            str = [', ' strjoin(params, ', ')];
        end
    end
end