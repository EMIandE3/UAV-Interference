function b = designMutiBandpassFilter(polit_filter_num, polit_centerFreq_arr, pass_bw, transitionWidth, fs)
            % 初始化滤波器频率结构体
            filter_freq = struct;
            
            % 使用循环为结构体创建属性
            for i = 1:polit_filter_num*2
                propName = sprintf('f%d', i);
                propValue = 0;
                filter_freq.(propName) = propValue;
            end
            
            % 设计滤波器的中心频率
            DC_0_flag = true;
            for freq_num = 1:polit_filter_num
                polit_centerFreq = polit_centerFreq_arr(freq_num);
                if polit_centerFreq <= 1.5e6
                    propName = sprintf('f%d', 2 * freq_num);
                    filter_freq.(propName) = polit_centerFreq;
                    filter_freq = rmfield(filter_freq, 'f1');
                    DC_0_flag = false;
                else
                    propName = sprintf('f%d', 2*freq_num-1);
                    filter_freq.(propName) = polit_centerFreq - pass_bw/2;
            
                    propName = sprintf('f%d', 2*freq_num);
                    filter_freq.(propName) = polit_centerFreq + pass_bw/2;
                end
            end
            
            % 设计滤波器的各通带、阻带的边界频率
            freq_group = [];
            filter_freq_name = fieldnames(filter_freq);
            for i = 1:round(length(filter_freq_name)/2)
                if isfield(filter_freq, 'f1')
                    freq_group = [freq_group filter_freq.(filter_freq_name{2*i-1})-transitionWidth filter_freq.(filter_freq_name{2*i-1}) ...
                        filter_freq.(filter_freq_name{2*i}) filter_freq.(filter_freq_name{2*i})+transitionWidth];
                else
                    if filter_freq.(filter_freq_name{2*i-1}) <= 1.5e6
                        freq_group = [freq_group filter_freq.(filter_freq_name{2*i-1}) filter_freq.(filter_freq_name{2*i-1})+transitionWidth];
                    else
                        freq_group = [freq_group filter_freq.(filter_freq_name{2*i-2})-transitionWidth filter_freq.(filter_freq_name{2*i-2}) ...
                            filter_freq.(filter_freq_name{2*i-1}) filter_freq.(filter_freq_name{2*i-1})+transitionWidth];
                    end
                end
            end
            
            % 设置滤波器的各带通幅度，和各通阻带的波动系数
            Band_amplitude = zeros(1, round((length(freq_group)+2)/2));
            deviation = ones(1, round((length(freq_group)+2)/2)) * 80;
            
            if ~DC_0_flag
                Band_amplitude(1:2:length(Band_amplitude)) = 1;
                deviation(1:2:length(Band_amplitude)) = 0.05;
            else
                Band_amplitude(2:2:length(Band_amplitude)) = 1;
                deviation(2:2:length(Band_amplitude)) = 0.05;
            end
            
            if ~all(diff(freq_group) > 0)
                str_disp = sprintf('频带设计不合理，目前的阻带和通带截止频率情况为：%s',num2str(freq_group));
                disp(str_disp);
%                 error(str_disp);
            
            end
            
            
            % 采用窗函数法设计fir滤波器，使用kaiser窗
            [n,Wn,beta,ftype] = kaiserord(freq_group, Band_amplitude, deviation, fs); % 计算阶数和归一化截止频率
            
            % 使用 fir1 函数设计滤波器
            b = fir1(n, Wn, ftype, kaiser(n+1,beta), 'noscale');
        end