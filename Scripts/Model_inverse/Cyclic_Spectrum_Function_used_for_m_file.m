%% date:2023/12/07
%% purpose: 循环谱代码梳理：该代码包括四种算法比较，包括时域直接计算法、频域直接计算法、频域计算改进法（补零加抽取）、FAM（FFT累加算法）
%% 参考文献: [1] 李创, 基于循环谱的调制识别和参数估计, 2021, 重庆大学.
%%           [2] 魏阳杰，基于循环谱的调制样式识别与参数估计，2015，电子科技大学
%%           [3] 马国宁，高效循环谱估计算法的研究及其应用，2006，电子科技大学
%% function:输入：
%%          输出：
%% debug:
%% 

%% Part1：待分析信号定义 
%% step1：程序初始运行时清除各变量
% clear;
% clc;
% close all;

function [CS1, CS_0, CS_Carrier] = Cyclic_Spectrum_Function(CSF_Method, fs, ad, MapN)

%% Part2：基于时域方法计算循环谱，该方法需要知道时域数据ad和采样频率fs
if CSF_Method == "TimeDomainCalculate"
    %% step1：从循环谱定义出发，计算f±alpha/2处信号的复解调
    tic
%     MapN = 501;  %1231 该值需为奇数
    X = zeros(MapN,MapN);
    Y = X;
    [f,alpha]=meshgrid(-fs/2:fs/(MapN-1):fs/2,-fs/2:fs/(MapN-1):fs/2);

    for n=1:length(ad)              %计算ad(n)时间长度为[1:length(ad)]的频谱及其频谱共轭
        B = exp(-j*2*pi*(f+alpha/2)*n/fs);
        C = exp(j*2*pi*(f-alpha/2)*n/fs);
        X1=ad(n)*B;
        Y1=conj(ad(n))*C;
        X=X1+X;
        Y=Y+Y1;
    end

    %% step2：计算X和Y处对应的谱相关
    P=X.*Y/length(ad);

    %% step3：对得到的谱相关函数进行谱平滑
    M = 8;  %谱平滑的点数
    m = -M/2:M/2;
    for k = 1:MapN
        for i = 1:MapN
            if i<(1+M/2)||i>(MapN-(M/2))
                CS1(k,i) = 0;
            else
                CS1(k,i) = sum(sum(P(k,i+m)))/(M+1);
            end
        end
    end
    toc

    %% step4：作图，做出循环谱的三维图，f截面图，alpha截面图
    figure(1);
    [f1,alpha1]=meshgrid(-fs/2:fs/(MapN-1):fs/2,-fs/2:fs/(MapN-1):fs/2);
    mesh(f1,alpha1,abs(CS1)./max(max(abs(CS1))));
    title('被测信号的循环谱')
    xlabel('Frequency/Hz')
    ylabel('alpha ')
    zlabel('magutide')
    Q=abs(CS1)./max(max(abs(CS1)));

    figure(2);
    alpha1=-fs/2:fs/(MapN-1):fs/2;
    CS_0 = Q(:,(MapN-1)/2);
    plot(alpha1,CS_0);
    title('被测信号的α段谱')
    xlabel('循环频率')
    ylabel('magutide')

    figure(3);
    plot(alpha1,Q((MapN-1)/2,:));
    title('被测信号的f段谱')
    xlabel('频率/Hz')
    ylabel('magutide')

    %% Part2：频域直接计算法（频域算法,不对信号做FFT补零操作以及不对频谱2抽取操作）
elseif CSF_Method == "FreqDomainCalculateDirectly"
    %% step1：运用算法
    tic
%     MapN = 500;
%     L = 2;
    [f,alpha,CS1] = Copy_of_CycSpecFft_Revised(ad,2*MapN,fs,8);
    toc
    CS1 = abs(CS1)/max(abs(CS1),[],"all");

    CS_0 = CS1(:,end-1);
    [~,b] = max(abs(CS_0));
    CS_Carrier = CS1(:,round(MapN-1-(MapN/2-b)/2*2));

    %% step2：作图，做出循环谱的三维图，f截面图，alpha截面图，载频f0处的循环截面图
    figure(6);
    mesh(f,alpha,abs(CS1))
    xlabel('f/Hz')
    ylabel('\alpha/Hz')
    title("三维循环谱估计结果图");

%     figure(7);
%     f_line = -fs/2:fs/2/MapN:0;
%     z = CS1(MapN/2+1,:);
%     plot(f_line,abs(z))
%     xlabel('f Hz')
%     grid on

    figure(8);
    alpha_line = -fs/2:fs/MapN:0;
    z = CS1(:,end-1);
    plot(alpha_line,abs(z));
    xlabel('\alpha Hz')
    grid on
    title("三维循环谱估计结果图");

    [~,b] = max(abs(z));
    figure(9);
    z = CS1(:,round(MapN-1-(MapN/2-b)/2*2));
    plot(alpha_line,abs(z));
    xlabel('\alpha Hz')
    grid on

    %% Part3：频域计算改进法（频域算法,对信号做FFT补零操作以及对频谱2抽取操作）
elseif CSF_Method == "FreqDomainCalculateImprove"
    %% step1：运用算法
    tic
%     MapN = 500;
    [f,alpha,CS1] = CycSpecFft(ad,MapN,fs,6);
    toc
    CS1 = abs(CS1)/max(abs(CS1),[],"all");

    %% step2：作图，做出循环谱的三维图，f截面图，alpha截面图，载频f0处的循环截面图
    figure
    mesh(f,alpha,abs(CS1))
    xlabel('f/Hz')
    ylabel('\alpha/Hz')

    figure
    f_line=-fs/2:fs/MapN:fs/2;
    CS_0 = CS1(MapN/2+1,:);
    plot(f_line,abs(CS_0))
    xlabel('f Hz')
    grid on

    figure
    CS_0 = CS1(:,MapN/2+1);
    alpha_line=-fs/2:fs/MapN:fs/2;
    plot(alpha_line,abs(CS_0));
    xlabel('\alpha Hz')
    grid on

    [~,b] = max(CS_0);
%     CarrierEstimate = (b-MapN/2-1)*fs/MapN/2;
    figure
    CS_0 = CS1(:,round(b/2+(MapN/2-1)/2));
    alpha_line=-fs/2:fs/MapN:fs/2;
    plot(alpha_line,abs(CS_0));
    xlabel('\alpha Hz')
    grid on


    %% Part4：FAM（FFT累加算法）
elseif CSF_Method == "FAM"
    %% step1：运用算法
    tic
    x = ad;
    df = 15;
    dalpha = 1;

    [CS1,alphao,fo] = autofam(x,fs,df,dalpha);
    toc
    CS1 = abs(CS1)/max(abs(CS1));

    [row,col] = size(CS1);
    [f,alpha]=meshgrid(alphao, fo);

    %% step2：作图，做出循环谱的三维图，f截面图，alpha截面图
    figure
    mesh(f,alpha,abs(CS1))
    xlabel('\alpha/Hz')
    ylabel('f/Hz')

    figure
    f_line=fo;
    CS_0 = CS1(:,(col-1)/2+1);
    plot(f_line,abs(CS_0))
    xlabel('f Hz')
    grid on

    figure
    alpha_line=alphao;
    CS_0 = CS1((row-1)/2+1,:);
    plot(alpha_line,abs(CS_0));
    xlabel('\alpha Hz')
    grid on
end
end



