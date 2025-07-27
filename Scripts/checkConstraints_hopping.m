function error_flag = checkConstraints_hopping(app_noise, Interference_number)
    
    global Constraint_condition_config;
    error_flag = 0;
     % 约束条件一、在跳频间隔和每种频率干扰的真实周期数上取折中，使得真实信号的频率更为集中，旁瓣缩小
    if app_noise.MultiFreqSkipTime.Value < Constraint_condition_config.Sweep_freq_rate_upperLimit_factor * 1/app_noise.MultiFreqSkipDistance.Value
        error_flag = 1;
        return
    end

    % 约束条件二、当根数不为1根时，使得最高频率的跳频信号不要跳出信号频段太多，避免功率浪费
    if Interference_number~=1
        maxFrequency = max(str2num( ['[' app_noise.MultiFreqF.Value ']'] ));
        if maxFrequency + (app_noise.MultiFreqSkipDistance.Value * max(str2num(['[' app_noise.MultiFreqSkipSequence.Value ']']))   ) > Constraint_condition_config.Sweep_freq_Highest_freq
            error_flag = 1;
            return
        end    
    end
end