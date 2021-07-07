function [fwhm1,fwhm2,pkposition1,pkposition2,contrast1,contrast2,...
    SNR1,SNR2,sensitivity1,sensitivity2,sensed_B] = doublepeak(R,data,yft)
    h = 6.63e-34;   %Planc constant
    ge = 2.003;     %NV's g factor
    uB = 9.27e-24;  %Bohr magneton
    gamma = 2*pi*28;    %GHz/T
    x1 = yft.x1;
    w1 = yft.w1;
    x2 = yft.x2;
    w2 = yft.w2;
    b = yft.b;
    fwhm1 = w1*2;
    fwhm2 = w2*2;
    pkposition1 = x1;
    pkposition2 = x2;
    contrast1 = (w1/(3.1415926*((x1-x1)^2+w1^2))+w2/(3.1415926*((x2-x1)^2+w2^2)))/b;
    contrast2 = (w2/(3.1415926*((x2-x2)^2+w2^2))+w1/(3.1415926*((x1-x2)^2+w1^2)))/b;
    SNR1 = contrast1/std(data(2,:));
    SNR2 = contrast2/std(data(2,:));
    sensitivity1 = 4*h*1e6/(3*sqrt(3)*ge*uB*sqrt(R))*1e6*fwhm1/contrast1;
    sensitivity2 = 4*h*1e6/(3*sqrt(3)*ge*uB*sqrt(R))*1e6*fwhm2/contrast2;
    sensed_B = (x2-x1)*1e-3/gamma*1e7
end
