%% date:2023/12/15
%% purpose: 对信号提取瞬时特征
%% 参考文献: [1] 
%% function:输入：接收到的某一调制信号Sig_rec，码元速率Rb，载频fc
%%          输出：中心归一化瞬时幅度功率谱密度的最大值Gama_m
%%                中心归一化瞬时幅度绝对值的标准偏差Sigma_aa
%%                非弱信号段中心化瞬时相位非线性分量标准偏差Sigma_dp
%%                非弱信号段中心化瞬时相位非线性分量绝对值的标准偏差Sigma_ap
%%                非弱信号段中心归一化瞬时频率绝对值标准偏差Sigma_af
%% debug:

%------------------------------------------------------------------
function [Gama_m,Sigma_aa,Sigma_dp,Sigma_ap,Sigma_af]...
    =Feature(Sig_rec,Rb,fc,fs)
%------------------------------------------------------------------
% fs = fix(8*fc/Rb)*Rb;             %采样频率
N = length(Sig_rec);              %采样点数
unit = ones(1,N);                 %构造单位矩阵
Sig_analytic = hilbert(Sig_rec);  %Sig_rec信号的解析形式,直接生成一个解析信号
%------------------------------------------------------------------
%瞬时幅度参数的提取和非弱信号段的确定
mag = abs(Sig_analytic);          %瞬时幅值
a_mean = sum(mag)/N;              %求均值
a_norm = mag/a_mean;              %用均值归一化
a_cnorm = a_norm-unit;            %中心化
indices = find(a_norm>1);         %提取非弱信号段
C = length(indices);              %非弱信号段的长度
%计算中心归一化瞬时幅度参数Gama_m和Sigma_aa
Gama_m = max(abs(fft(a_cnorm).^2))/N;
a_sq_mean = sum(a_cnorm.^2)/N;
a_mean_sq = (sum(abs(a_cnorm))/N).^2;
Sigma_aa = sqrt(a_sq_mean-a_mean_sq);
%------------------------------------------------------------------
%瞬时相位参数的提取
phi = angle(Sig_analytic);
phi_linear = [1:N]*2*pi*fc/fs;           %线性相位部分
%修正相位，去卷叠
phi_crr(1) = 0;
for i = 2:N
    if phi(i)-phi(i-1)>pi
        phi_crr(i)=phi_crr(i-1)-2*pi;
    elseif phi(i-1)-phi(i)>pi
        phi_crr(i)=phi_crr(i-1)+2*pi;
    else
        phi_crr(i)=phi_crr(i-1);
    end
end
phi_uv=phi+phi_crr;                    %去卷叠后的相位
phi_nl=phi_uv-phi_linear;              %非线性相位部分
for i=1:N
    while phi_nl(i)>pi
        phi_nl(i)=phi_nl(i)-2*pi;
    end
    while phi_nl(i)<-pi
        phi_nl(i)=phi_nl(i)+2*pi;
    end
end
%计算瞬时相位参数Sigma_dp和Sigma_ap
phi_sq_mean=sum(phi_nl(indices).^2)/C;
phi_mean_sq=(sum(phi_nl(indices))/C).^2;
Sigma_dp=sqrt(phi_sq_mean-phi_mean_sq);
phi_mean_sq=(sum(abs(phi_nl(indices)))/C).^2;
Sigma_ap=sqrt(phi_sq_mean-phi_mean_sq);
%------------------------------------------------------------------
%瞬时频率参数的提取，由相位的差分计算瞬时频率
for i=1:N-1
    freq(i)=(phi_uv(i+1)-phi_uv(i))*fs/(2*pi);
end
%确定非弱信号段的瞬时频率
freq_crr=freq(20:N-1);                     %建立稳定的频率需要一段时
N2=length(freq_crr);                       %间，故将开始的20个点截掉
indices1=find(20<indices<N);
C1=length(indices1);
unit1=ones(1,N2);
freq_mean=sum(freq_crr)/N2;                %求均值
freq_centralized=freq_crr-freq_mean*unit1; %中心化
freq_norm=freq_centralized/Rb;             %归一化 % freq_norm=freq_centralized/freq_mean;        %归一化 
%计算瞬时频率参数Sigma_af
freq_sq_mean=sum(freq_norm(indices1).^2)/C1;
freq_mean_sq=(sum(abs(freq_norm(indices1)))/C1).^2;
Sigma_af=sqrt(freq_sq_mean-freq_mean_sq);
%------------------------------------------------------------------
%作图查看所获得的信号的瞬时特征
%figure;
%subplot(4,1,1);
%plot(Sig_rec);
%ylabel('signal with noise');
%subplot(4,1,2);
%plot(mag);
%ylabel('inst_mag');
%subplot(4,1,3);
%plot(phi_nl);
%ylabel('inst_phase');
%subplot(4,1,4);
%plot(freq);
%ylabel('inst_freq');
end