%% Test logNormalShadowing Model
Pt_dBm = 0; %Input transmitted power in dBm
Gt_dBi = 1; %Gain of the Transmitted antenna in dBi 
Gr_dBi = 1; %Gain of the Receiver antenna in dBi 
freq = 2.4e9; % Transmitted siganl frequency in Hertz
d0 = 1; % assume reference distance = 1m
d = 100*(1:0.2:100); %Array of distances to simulate 
L = 1; %Other system Losses, No Loss case L=1;
sigma = 2; %standard deviation of log Normal ditribution (in dB)
n = 2; %path loss exponent

%Log normal shadowing (with shadowing effect)
[PL_Shadow,Pr_shadow] = Calcu_PathDelay(Pt_dBm,Gr_dBi,Gt_dBi,freq,d0,d,L,sigma,n);
figure
plot(d,Pr_shadow);

