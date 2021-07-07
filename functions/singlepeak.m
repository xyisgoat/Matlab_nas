function [fwhm,pkposition,contrast,SNR,sensitivity] = singlepeak(R,data,yft)
    h = 6.63e-34;   %Planc constant
    ge = 2.003;     %NV's g factor
    uB = 9.27e-24;  %Bohr magneton
    x1 = yft.x1;
    w1 = yft.w1;
    b = yft.b;
    fwhm = w1*2;
    pkposition = x1;
    contrast = w1/(3.1416*((x1-x1)^2+w1^2))/b;
    SNR = contrast/std(data(2,:));
    sensitivity = 4*h*1e6/(3*sqrt(3)*ge*uB*sqrt(R))*1e6*fwhm/contrast;
end

