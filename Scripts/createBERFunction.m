%% 可以构造匿名函数的文本表示来解决：eval，根据额外参数的数量调整适应度函数
function fun_str = createBERFunction(scenario) 
    % 初始化函数字符串
    fun_part_1 = '';
    fun_part_2 = '';
    
    % 根据配置构建函数字符串
    if strcmp(scenario.Interference_method, '步进调频') && strcmp(scenario.Source_type, '单音正弦噪声') && strcmp(scenario.Bw_is_variable, 'True')
        fun_part_1 = '@(x) -getBER(app, struct(''Passband_bw'', round(x(1)), ''Transition_bw'', round(x(2)), ''SinF'', round(x(3)), ''StepSweepFmax'', round(x(4)), ''StepSweepFmin'', round(x(5)), ''StepSweepT'', x(6), ''StepSweepN'', round(x(7))';
        fun_part_2 = '), "单音正弦噪声", "步进调频", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
        
    elseif strcmp(scenario.Interference_method, '跳频干扰') && strcmp(scenario.Source_type, '单音正弦噪声') && strcmp(scenario.Bw_is_variable, 'True')
        fun_part_1 = '@(x) -getBER(app, struct(''Passband_bw'', round(x(1)), ''Transition_bw'', round(x(2)), ''SinF'', round(x(3)), ''MultiFreqSkipDistance'', round(x(4)), ''MultiFreqSkipTime'', x(5)';
        fun_part_2 = '), "单音正弦噪声", "跳频干扰", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '步进调频') && strcmp(scenario.Source_type, '随机二元码调制噪声') && strcmp(scenario.Bw_is_variable, 'True')
        fun_part_1 = '@(x) -getBER(app, struct(''Passband_bw'', round(x(1)), ''Transition_bw'', round(x(2)), ''RandBFF'', round(x(3)), ''RandBFZero'', x(4), ''RandBCodeP'', x(5), ''StepSweepFmax'', round(x(6)), ''StepSweepFmin'', round(x(7)), ''StepSweepT'', x(8), ''StepSweepN'', round(x(9))';
        fun_part_2 = '), "随机二元码调制噪声", "步进调频", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '跳频干扰') && strcmp(scenario.Source_type, '随机二元码调制噪声') && strcmp(scenario.Bw_is_variable, 'True')
        fun_part_1 = '@(x) -getBER(app, struct(''Passband_bw'', round(x(1)), ''Transition_bw'', round(x(2)), ''RandBFF'', round(x(3)), ''RandBFZero'', x(4), ''RandBCodeP'', x(5), ''MultiFreqSkipDistance'', round(x(6)), ''MultiFreqSkipTime'', x(7)';
        fun_part_2 = '), "随机二元码调制噪声", "跳频干扰", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '步进调频') && strcmp(scenario.Source_type, 'PN码MSK噪声') && strcmp(scenario.Bw_is_variable, 'True')
        fun_part_1 = '@(x) -getBER(app, struct(''Passband_bw'', round(x(1)), ''Transition_bw'', round(x(2)), ''PNMSKF'', round(x(3)), ''PNMSKM'', round(x(4)), ''StepSweepFmax'', round(x(5)), ''StepSweepFmin'', round(x(6)), ''StepSweepT'', x(7), ''StepSweepN'', round(x(8))';
        fun_part_2 = '), "PN码MSK噪声", "步进调频", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '跳频干扰') && strcmp(scenario.Source_type, 'PN码MSK噪声') && strcmp(scenario.Bw_is_variable, 'True')
        fun_part_1 = '@(x) -getBER(app, struct(''Passband_bw'', round(x(1)), ''Transition_bw'', round(x(2)), ''PNMSKF'', round(x(3)), ''PNMSKM'', round(x(4)), ''MultiFreqSkipDistance'', round(x(5)), ''MultiFreqSkipTime'', x(6)';
        fun_part_2 = '), "PN码MSK噪声", "跳频干扰", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '步进调频') && strcmp(scenario.Source_type, '脉冲噪声') && strcmp(scenario.Bw_is_variable, 'True')
        fun_part_1 = '@(x) -getBER(app, struct(''Passband_bw'', round(x(1)), ''Transition_bw'',  round(x(2)), ''pulseNoise_centerFreq'', round(x(3)), ''pulseNoise_pass_bw'', round(x(4)), ''StepSweepFmax'', round(x(5)), ''StepSweepFmin'', round(x(6)), ''StepSweepT'', x(7), ''StepSweepN'', round(x(8))';
        fun_part_2 = '), "脉冲噪声", "步进调频", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '跳频干扰') && strcmp(scenario.Source_type, '脉冲噪声') && strcmp(scenario.Bw_is_variable, 'True')
        fun_part_1 = '@(x) -getBER(app, struct(''Passband_bw'', round(x(1)), ''Transition_bw'', round(x(2)), ''pulseNoise_centerFreq'', round(x(3)), ''pulseNoise_pass_bw'', round(x(4)), ''MultiFreqSkipDistance'', round(x(5)), ''MultiFreqSkipTime'', x(6)';
        fun_part_2 = '), "脉冲噪声", "跳频干扰", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
        % 不将带宽设为变量
    elseif strcmp(scenario.Interference_method, '步进调频') && strcmp(scenario.Source_type, '单音正弦噪声') && strcmp(scenario.Bw_is_variable, 'False')
        fun_part_1 = '@(x) -getBER(app, struct(''SinF'', round(x(1)), ''StepSweepFmax'', round(x(2)), ''StepSweepFmin'', round(x(3)), ''StepSweepT'', x(4), ''StepSweepN'', round(x(5))';
        fun_part_2 = '), "单音正弦噪声", "步进调频", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '跳频干扰') && strcmp(scenario.Source_type, '单音正弦噪声') && strcmp(scenario.Bw_is_variable, 'False')
        fun_part_1 = '@(x) -getBER(app, struct(''SinF'', round(x(1)), ''MultiFreqSkipDistance'', round(x(2)), ''MultiFreqSkipTime'', x(3)';
        fun_part_2 = '), "单音正弦噪声", "跳频干扰", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '步进调频') && strcmp(scenario.Source_type, '随机二元码调制噪声') && strcmp(scenario.Bw_is_variable, 'False')
        fun_part_1 = '@(x) -getBER(app, struct( ''RandBFF'', round(x(1)), ''RandBFZero'', x(2), ''RandBCodeP'', x(3), ''StepSweepFmax'', round(x(4)), ''StepSweepFmin'', round(x(5)), ''StepSweepT'', x(6), ''StepSweepN'', round(x(7))';
        fun_part_2 = '), "随机二元码调制噪声", "步进调频", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '跳频干扰') && strcmp(scenario.Source_type, '随机二元码调制噪声') && strcmp(scenario.Bw_is_variable, 'False')
        fun_part_1 = '@(x) -getBER(app, struct(''RandBFF'', round(x(1)), ''RandBFZero'', x(2), ''RandBCodeP'', x(3), ''MultiFreqSkipDistance'', round(x(4)), ''MultiFreqSkipTime'', x(5)';
        fun_part_2 = '), "随机二元码调制噪声", "跳频干扰", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '步进调频') && strcmp(scenario.Source_type, 'PN码MSK噪声') && strcmp(scenario.Bw_is_variable, 'False')
        fun_part_1 = '@(x) -getBER(app, struct(''PNMSKF'', round(x(1)), ''PNMSKM'', round(x(2)), ''StepSweepFmax'', round(x(3)), ''StepSweepFmin'', round(x(4)), ''StepSweepT'', x(5), ''StepSweepN'', round(x(6))';
        fun_part_2 = '), "PN码MSK噪声", "步进调频", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '跳频干扰') && strcmp(scenario.Source_type, 'PN码MSK噪声') && strcmp(scenario.Bw_is_variable, 'False')
        fun_part_1 = '@(x) -getBER(app, struct(''PNMSKF'', round(x(1)), ''PNMSKM'', round(x(2)), ''MultiFreqSkipDistance'', round(x(3)), ''MultiFreqSkipTime'', x(4)';
        fun_part_2 = '), "PN码MSK噪声", "跳频干扰", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '步进调频') && strcmp(scenario.Source_type, '脉冲噪声') && strcmp(scenario.Bw_is_variable, 'False')
        fun_part_1 = '@(x) -getBER(app, struct(''pulseNoise_centerFreq'', round(x(1)), ''pulseNoise_pass_bw'', round(x(2)), ''StepSweepFmax'', round(x(3)), ''StepSweepFmin'', round(x(4)), ''StepSweepT'', x(5), ''StepSweepN'', round(x(6))';
        fun_part_2 = '), "脉冲噪声", "步进调频", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    
    elseif strcmp(scenario.Interference_method, '跳频干扰') && strcmp(scenario.Source_type, '脉冲噪声') && strcmp(scenario.Bw_is_variable, 'False')
        fun_part_1 = '@(x) -getBER(app, struct(''pulseNoise_centerFreq'', round(x(1)), ''pulseNoise_pass_bw'', round(x(2)), ''MultiFreqSkipDistance'', round(x(3)), ''MultiFreqSkipTime'', x(4)';
        fun_part_2 = '), "脉冲噪声", "跳频干扰", scenario.Interference_number, scenario.Interference_sequence_number, Optimized_interference_sources_config.Passband_centerFreq)';
    end
    
    % 合并两部分并返回
    fun_str = [fun_part_1, scenario.ExtraParams, fun_part_2];
end
