function error_flag = checkConstraints_filter(app_noise)
    
    error_flag = 0;
    global Constraint_condition_config;
     % 约束条件一、确保阻带至少有150kHz
     for i = 2:app_noise.polit_filter_num
         if app_noise.polit_centerFreq(i) - app_noise.polit_centerFreq(i-1) - app_noise.pass_bw - app_noise.transitionWidth*2  < Constraint_condition_config.Transition_zone_minimum_gap
             error_flag = 1;
             return
         end
     end
end



