function [PL,Pr_dBm] = Calcu_PathDelay(Pt_dBm,Gt_dBi,Gr_dBi,freq,d0,d,L,sigma,n)
%CALCU_PATHDELAY in MiMO Fading Channel 
%   Using Lognormal shadow fading model, the formula are as follows
%   PL(d)[dB] = PL_F(d0) + 10nlog10(d/d0) + X
%   Input Parameters:
%       --Pt_dBm = Transmitted power in dBm
%       --Gt_dBi = Gain of the Transmitted antenna in dBi
%       --Gr_dBi = Gain of the Receiver antenna in dBi
%       --freq = frequency of transmitted signal in Hertz
%       --d0 = reference distance of receiver from the transmitter in meters
%       --L = Other System Losses, for no Loss case L=1
%       --sigma = Standard deviation of log Normal distribution in dB
%       --n = path loss exponent
%   OutPut Parameters:
%       --PL = path loss due to log normal shadowing
%       --Pr_dBm = received power in dBm
    lamda = physconst('lightspeed') / freq; % Wavelength in meters
    K = 20*log10(lamda/(4*pi)) - 10*n*log10(d0) - 10*log10(L); %path-loss factor
    X = sigma * randn(size(d));  % 均值为0，方差为detla的高斯随机变量
    PL = Gt_dBi + Gr_dBi + K - 10*n*log10(d/d0) -X; %PL(d) including antennas gains
    Pr_dBm = Pt_dBm + PL;
end

