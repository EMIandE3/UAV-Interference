%% date:2023/12/15
%% purpose: ���ź���ȡ˲ʱ����
%% �ο�����: [1] 
%% function:���룺���յ���ĳһ�����ź�Sig_rec����Ԫ����Rb����Ƶfc
%%          ��������Ĺ�һ��˲ʱ���ȹ������ܶȵ����ֵGama_m
%%                ���Ĺ�һ��˲ʱ���Ⱦ���ֵ�ı�׼ƫ��Sigma_aa
%%                �����źŶ����Ļ�˲ʱ��λ�����Է�����׼ƫ��Sigma_dp
%%                �����źŶ����Ļ�˲ʱ��λ�����Է�������ֵ�ı�׼ƫ��Sigma_ap
%%                �����źŶ����Ĺ�һ��˲ʱƵ�ʾ���ֵ��׼ƫ��Sigma_af
%% debug:

%------------------------------------------------------------------
function [Gama_m,Sigma_aa,Sigma_dp,Sigma_ap,Sigma_af]...
    =Feature(Sig_rec,Rb,fc,fs)
%------------------------------------------------------------------
% fs = fix(8*fc/Rb)*Rb;             %����Ƶ��
N = length(Sig_rec);              %��������
unit = ones(1,N);                 %���쵥λ����
Sig_analytic = hilbert(Sig_rec);  %Sig_rec�źŵĽ�����ʽ,ֱ������һ�������ź�
%------------------------------------------------------------------
%˲ʱ���Ȳ�������ȡ�ͷ����źŶε�ȷ��
mag = abs(Sig_analytic);          %˲ʱ��ֵ
a_mean = sum(mag)/N;              %���ֵ
a_norm = mag/a_mean;              %�þ�ֵ��һ��
a_cnorm = a_norm-unit;            %���Ļ�
indices = find(a_norm>1);         %��ȡ�����źŶ�
C = length(indices);              %�����źŶεĳ���
%�������Ĺ�һ��˲ʱ���Ȳ���Gama_m��Sigma_aa
Gama_m = max(abs(fft(a_cnorm).^2))/N;
a_sq_mean = sum(a_cnorm.^2)/N;
a_mean_sq = (sum(abs(a_cnorm))/N).^2;
Sigma_aa = sqrt(a_sq_mean-a_mean_sq);
%------------------------------------------------------------------
%˲ʱ��λ��������ȡ
phi = angle(Sig_analytic);
phi_linear = [1:N]*2*pi*fc/fs;           %������λ����
%������λ��ȥ���
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
phi_uv=phi+phi_crr;                    %ȥ��������λ
phi_nl=phi_uv-phi_linear;              %��������λ����
for i=1:N
    while phi_nl(i)>pi
        phi_nl(i)=phi_nl(i)-2*pi;
    end
    while phi_nl(i)<-pi
        phi_nl(i)=phi_nl(i)+2*pi;
    end
end
%����˲ʱ��λ����Sigma_dp��Sigma_ap
phi_sq_mean=sum(phi_nl(indices).^2)/C;
phi_mean_sq=(sum(phi_nl(indices))/C).^2;
Sigma_dp=sqrt(phi_sq_mean-phi_mean_sq);
phi_mean_sq=(sum(abs(phi_nl(indices)))/C).^2;
Sigma_ap=sqrt(phi_sq_mean-phi_mean_sq);
%------------------------------------------------------------------
%˲ʱƵ�ʲ�������ȡ������λ�Ĳ�ּ���˲ʱƵ��
for i=1:N-1
    freq(i)=(phi_uv(i+1)-phi_uv(i))*fs/(2*pi);
end
%ȷ�������źŶε�˲ʱƵ��
freq_crr=freq(20:N-1);                     %�����ȶ���Ƶ����Ҫһ��ʱ
N2=length(freq_crr);                       %�䣬�ʽ���ʼ��20����ص�
indices1=find(20<indices<N);
C1=length(indices1);
unit1=ones(1,N2);
freq_mean=sum(freq_crr)/N2;                %���ֵ
freq_centralized=freq_crr-freq_mean*unit1; %���Ļ�
freq_norm=freq_centralized/Rb;             %��һ�� % freq_norm=freq_centralized/freq_mean;        %��һ�� 
%����˲ʱƵ�ʲ���Sigma_af
freq_sq_mean=sum(freq_norm(indices1).^2)/C1;
freq_mean_sq=(sum(abs(freq_norm(indices1)))/C1).^2;
Sigma_af=sqrt(freq_sq_mean-freq_mean_sq);
%------------------------------------------------------------------
%��ͼ�鿴����õ��źŵ�˲ʱ����
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