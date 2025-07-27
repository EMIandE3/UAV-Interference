function error_flag = checkConstraints_stepSweep(app_noise, Interference_number)
    
    error_flag = 0;
    global Constraint_condition_config;
    % 约束条件一、在扫频速率和每种频率干扰的真实周期数上取折中，使得真实信号的频率更为集中，旁瓣缩小
    if Constraint_condition_config.Sweep_freq_rate_upperLimit_factor * app_noise.StepSweepN.Value^2 > app_noise.StepSweepT.Value * abs(app_noise.StepSweepFmax.Value - app_noise.StepSweepFmin.Value)
        error_flag = 1;
        return
    end
    
    % 约束条件二、扫频的最大值和最小值相等时需排除掉，这样模型求解会出现奇异点
    if abs(app_noise.StepSweepFmax.Value - app_noise.StepSweepFmin.Value) == 0
        error_flag = 1;
        return
    end
    
    % 约束条件三、当根数不为1根时，使得最高频率的扫频信号不要扫出信号频段太多，避免功率浪费
    if Interference_number ~= 1
        maxFrequency = max(str2num( ['[' app_noise.MultiFreqF.Value ']'] ));
        if maxFrequency + (app_noise.StepSweepFmax.Value - app_noise.StepSweepFmin.Value) > Constraint_condition_config.Sweep_freq_Highest_freq
            error_flag = 1;
            return
        end
        
    end
end