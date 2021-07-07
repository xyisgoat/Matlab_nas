function [] = ODMRplot2(Uplim,Lowlim,StepSize,C1,C2,W1,W2,X1,X2,B)
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
x = [Uplim:StepSize:Lowlim];
y = -2*C1*W1./(4.*((x-X1).^2+W1^2))-2*C2*W2./(4.*((x-X2).^2+W2^2))+B;

plot(x,y,'LineWidth',2);

FigureRegular('Frequency (MHz)','Contrast (a. u. )',[])
end



