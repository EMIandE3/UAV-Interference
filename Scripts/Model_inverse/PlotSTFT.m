function PlotSTFT(T,F,S)
    % Plots STFT
    plotOpts = struct();
    plotOpts.isFsnormalized = false;
    plotOpts.cblbl = getString(message('signal:dspdata:dspdata:MagnitudedB'));
    plotOpts.title = 'Short-time Fourier Transform';
    plotOpts.threshold = max(20*log10(abs(S(:))+eps))-20; %-60
    signalwavelet.internal.convenienceplot.plotTFR(T,F,20*log10(abs(S)+eps),plotOpts);
end
