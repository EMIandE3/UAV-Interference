 function [Sx,alphao,fo] = autofam(x,fs,df,dalpha)
%************************************************
% x为输入信号向量
% fs为采样率
% df为频率分辨率
% dalpha为循环频率分辨率
% 注意：需满足df>>dalpha才能得到较高的效果，fs/dalpha为进行采样计算功率谱的码元个数
%%fam算法比ssca(autossca)算法快,但效果一样.都是求循环平稳与谱
%************************************************
% if nargin > 4 | nargin < 4
%     error('Wrong number of arguments.');
% end   
% fs=1280;
% fc=160;
% N=8192;
% PW=N/fs;
% signal_type=5;
% switch signal_type
%     case 1; input_signal = sin(2*pi*(fc)*((0:(N-1))/fs));
%     case 2; input_signal = bpsk_generator(fs*10^6,fc*10^6,PW*10^3);
%     case 3; input_signal = qpsk_generator(fs*10^6,fc*10^6,PW*10^3);
%     case 4; input_signal = lfm_generator(fs) ;
%     case 5; input_signal = nlfm_generator(fs) ;
%     otherwise;
% end
% x = awgn(input_signal,10);
% M=128;
% dalpha=fs/N;
% df=dalpha*M;
%-----------Definition of Parameters-----------%
Np = pow2(nextpow2(fs/df));     %输入信道数
L = Np/4;                       %抽取因子，同一行连续列的相邻点的偏移，L表示每次滑动的数据点数
P = pow2(nextpow2(fs/dalpha/L));%信道矩阵的列数,P表示滑动次数
N = P*L;                        %输入数据的点数
%----------Input Channelization----------------%
if length(x) < N
    x(N) = 0;
elseif length(x) > N
    x = x(1:N);
end
NN = (P-1)*L+Np;
xx = x;
xx(NN) = 0;
xx = xx(:);
X = zeros(Np,P);
for k = 0:P-1
    X(:,k+1) = xx(k*L+1:k*L+Np);  
    %输入数据xx的1到Np存入X第一列，L+1到L+Np存入第二列，2L+1到2L+Np存入第三列，以此类推。即L为偏移，Np为每段长度。L是滑动窗的尺寸
end
%------------------Windowing------------------%
% a = hamming(Np);
a=kaiser(Np);
XW = diag(a)*X;   %每段加窗,减少频率泄露
% XW = X;         %不加窗，可与加窗的效果作比较
%---------------第一次傅里叶变换--------------------%
XF1 = fft(XW);  
% clear XW;   
XF1 = fftshift(XF1);   
XF1 = [XF1(:,P/2+1:P) XF1(:,1:P/2)];  %这两行的功能是把傅里叶变换的结果上半块和下半块交换,左半块和右半块互换
 
%-------------下变频------------------%
E = zeros(Np,P);
 
for k = -Np/2:Np/2-1
    for m = 0:P-1
        E(k+Np/2+1,m+1) = exp(-i*2*pi*k*m*L/Np);
    end
end
XD = XF1.*E;   
% clear XF1; 
XD = conj(XD');                      %XD转置的复共轭
% clear ('XF1', 'E', 'XW', 'X', 'x'); 
%-----------乘积运算--------------------%
XM = zeros(P,Np^2);
for k = 1:Np
    for l = 1:Np
        XM(:,(k-1)*Np+l) = (XD(:,k).*conj(XD(:,l)));
    end
end
% clear XD;
%-----------第二次傅里叶变换-----------------------%
XF2 = fft(XM);  
XF222 = XF2;
% clear XM;
XF2 = fftshift(XF2);
XF2 = [XF2(:,Np^2/2+1:Np^2) XF2(:,1:Np^2/2)];
% length(XF2);
XF2 = XF2(P/4:3*P/4,:);
% M = abs(XF2);
 M = XF2;
% clear XF2;  %Absolute value and complex magnitude
%%%%%%%%%%%%%%%%频率分辨率和循环频率分辨率%%%%%%%%%%
alphao = (-1:1/N:1)*fs;     %about the variable N!!!
fo = (-0.5:1/Np:0.5)*fs;
Sx = zeros(Np+1,2*N+1);     %about the variable N!!!
for k1 = 1:P/2+1
    for k2 = 1:Np^2
        if rem(k2,Np) == 0
            l = Np/2-1;    
        else
            l = rem(k2,Np)-Np/2-1; 
        end
        k = ceil(k2/Np)-Np/2-1; 
        p = k1-P/4-1;
        alpha = (k-l)/Np+(p-1)/L/P;
        f = (k+l)/2/Np;
        if alpha < -1 || alpha > 1
            k2 = k2+1;
        elseif f < -0.5 || f > 0.5
            k2 = k2+1;
%         elseif rem(k+l,2)==0 && rem(1+N*(alpha+1),1)==0
        else
            kk = 1+Np*(f+0.5);
            ll = 1+N*(alpha + 1);
            Sx(round(kk), round(ll)) = M(k1,k2); 
        end
    end
end
Sx = Sx./max(max(Sx)); % Normalizes the magnitudes of the values in output matrix (maximum = 1)