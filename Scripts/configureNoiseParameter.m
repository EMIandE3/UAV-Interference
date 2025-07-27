function  [model] = configureNoiseParameter(app_noise)
    % Helper function to set common parameters
    run("Scripts/defaultmodelstruct.m") 

    switch app_noise.source.Value
        case "None"
            model.Parameters.NoiseGen.Type = "None";
            model.Parameters.NoiseGen.Control.Source = 0;
        case "随机二元码调制噪声"
            % 生成二进制随机噪声
            model.Parameters.NoiseGen.Type = "随机二元码调制噪声";
            model.Parameters.NoiseGen.Control.Source = 2;
            model.Parameters.NoiseGen.RandBFZero = app_noise.RandBFZero.Value; %二进制随机数的-1的概率
            model.Parameters.NoiseGen.RandBPFF = app_noise.RandBFF.Value;      %随机二元码调制噪声的频率
            model.Parameters.NoiseGen.PRCodeTs = app_noise.RandBCodeP.Value;

        case "单音正弦噪声"
            % 生成单音正弦噪声
            model.Parameters.NoiseGen.Type = "单音正弦噪声";
            model.Parameters.NoiseGen.Control.Source = 3;
            model.Parameters.NoiseGen.SineNoiseF = app_noise.SinF.Value;       %单音正弦噪声的频率

        case "PN码MSK噪声"
            % 生成PN码MSK噪声
            model.Parameters.NoiseGen.Type = "PN码MSK噪声";
            model.Parameters.NoiseGen.Control.Source = 4;
            model.Parameters.NoiseGen.PNMSKF = app_noise.PNMSKF.Value; %MSK的中心频率
            model.Parameters.NoiseGen.PNMSKM = app_noise.PNMSKM.Value; %MSK的进制数M

       case "脉冲噪声"
            model.Parameters.NoiseGen.Type = "脉冲噪声";
            model.Parameters.NoiseGen.Control.Source = 1;
            model.Parameters.NoiseGen.GaussPower = 10;       % 高斯白噪声的功率密度
    %         model.Parameters.NoiseGen.GaussPower = app.GaussPower.Value * model.Parameters.NoiseGen.NoiseTs;       % 高斯白噪声的功率密度
            model.Parameters.NoiseGen.GaussSeed = 67;      % 白噪声随机种子
    end

    switch app_noise.sequence.Value
        case "None"
            %干扰方式类型，默认是None
            model.Parameters.NoiseGen.Jamming.Type = "None"; 
            %噪声源的干扰方式控制位，默认为0. 0,干扰方式不工作
            model.Parameters.NoiseGen.Control.Jamming = 0;   
            
        case "步进调频"
            %干扰方式类型
            model.Parameters.NoiseGen.Jamming.Type = "步进调频"; 
            %干扰方式控制位,2代表采用步进调频
            model.Parameters.NoiseGen.Control.Jamming = 2;  
            model.Parameters.NoiseGen.Jamming.StepSweepFmin = app_noise.StepSweepFmin.Value; %步进扫频的最小频率
            model.Parameters.NoiseGen.Jamming.StepSweepFmax = app_noise.StepSweepFmax.Value; %步进扫频的最大频率
            model.Parameters.NoiseGen.Jamming.StepSweepT = app_noise.StepSweepT.Value; %步进扫频的周期
            model.Parameters.NoiseGen.Jamming.StepSweepN = app_noise.StepSweepN.Value; %步进扫频的跳频个数
            model.Parameters.NoiseGen.Jamming.StepSweepDeltaFstep = round(abs(model.Parameters.NoiseGen.Jamming.StepSweepFmax-model.Parameters.NoiseGen.Jamming.StepSweepFmin)/...
                (model.Parameters.NoiseGen.Jamming.StepSweepN-1)); %步进调频的频率间隔
            model.Parameters.NoiseGen.Jamming.StepSweepTDwell = model.Parameters.NoiseGen.Jamming.StepSweepT / model.Parameters.NoiseGen.Jamming.StepSweepN; %步进调频的时间间隔

            %多频干扰类型
            model.Parameters.NoiseGen.MultiFreq.Type = "多频干扰";
            model.Parameters.NoiseGen.Control.MultiFreq = 1; %噪声源的多频干扰控制位，1多频干扰工作
            model.Parameters.NoiseGen.MultiFreq.MFF = str2num(['[' app_noise.MultiFreqF.Value ']']); %MF调制的频率
            model.Parameters.NoiseGen.MultiFreq.MFSequence = str2num(['[' app_noise.MultiFreqSkipSequence.Value ']']);
            
            model.Parameters.NoiseGen.MultiFreq.MFNum =  64; %MF调制的跳频个数
            model.Parameters.NoiseGen.MultiFreq.MFDistance =  app_noise.MultiFreqSkipDistance.Value ; %MF调制的最小跳频间隔
            model.Parameters.NoiseGen.MultiFreq.MFTime =  app_noise.MultiFreqSkipTime.Value ; %MF调制的跳频驻留时间

            % model.Parameters.NoiseGen.MultiFreq.MFA = zeros(1,length(model.Parameters.NoiseGen.MultiFreq.MFF)); %MF调制的幅度
            % A = [2	17	30	10	16	7	20	30	30	2	32	10	20	38	4	3	30	8	2	25	20	21	10	30	14	20	11	2	12	10	6	35	33	27	37	1	28	19]-1;
            % A = round(A/38*19);
            % [unique_elements, ~, idx] = unique(A); % 获取唯一元素及索引
            % counts = histcounts(idx, 'BinMethod', 'integers'); % 统计出现次数
            % probabilities = counts / numel(A); % 计算概率
            % model.Parameters.NoiseGen.MultiFreq.MFA(unique_elements+1) = probabilities;

            model.Parameters.NoiseGen.MultiFreq.MFA = ones(1,length(model.Parameters.NoiseGen.MultiFreq.MFF)); %MF调制的幅度

        case "跳频干扰"
            % "步进调频"
            model.Parameters.NoiseGen.Jamming.Type = "None"; %干扰方式类型
            model.Parameters.NoiseGen.Control.Jamming = 0; %干扰方式控制位,2代表采用步进调频

            %多频干扰类型
            model.Parameters.NoiseGen.MultiFreq.Type = "多频干扰";
            model.Parameters.NoiseGen.Control.MultiFreq = 1; %噪声源的多频干扰控制位，1多频干扰工作
            model.Parameters.NoiseGen.MultiFreq.MFF = str2num(['[' app_noise.MultiFreqF.Value ']']); %MF调制的频率
            model.Parameters.NoiseGen.MultiFreq.MFSequence =  str2num(['[' app_noise.MultiFreqSkipSequence.Value ']']) ; %MF调制的跳频序列
            
            model.Parameters.NoiseGen.MultiFreq.MFNum =  64; %MF调制的跳频个数
            model.Parameters.NoiseGen.MultiFreq.MFDistance =  app_noise.MultiFreqSkipDistance.Value ; %MF调制的最小跳频间隔
            model.Parameters.NoiseGen.MultiFreq.MFTime =  app_noise.MultiFreqSkipTime.Value ; %MF调制的跳频驻留时间

            % model.Parameters.NoiseGen.MultiFreq.MFA = zeros(1,length(model.Parameters.NoiseGen.MultiFreq.MFF)); %MF调制的幅度
            % A = [2	17	30	10	16	7	20	30	30	2	32	10	20	38	4	3	30	8	2	25	20	21	10	30	14	20	11	2	12	10	6	35	33	27	37	1	28	19]-1;
            % A = round(A/38*19);
            % [unique_elements, ~, idx] = unique(A); % 获取唯一元素及索引
            % counts = histcounts(idx, 'BinMethod', 'integers'); % 统计出现次数
            % probabilities = counts / numel(A); % 计算概率
            % model.Parameters.NoiseGen.MultiFreq.MFA(unique_elements+1) = probabilities;
            
            model.Parameters.NoiseGen.MultiFreq.MFA = ones(1,length(model.Parameters.NoiseGen.MultiFreq.MFF)); %MF调制的幅度
    end


end
