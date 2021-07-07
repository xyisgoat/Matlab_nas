function [] = ODMRplot1(Uplim,Lowlim,StepSize,C,W,X0,B)
%UNTITLED4 此处显示有关此函数的摘要
%   此处显示详细说明
x = [Uplim:StepSize:Lowlim];
y = -2*C*W./(4.*((x-X0).^2+W^2))+B';

plot(x,y,'LineWidth',2);

FigureRegular('Frequency (MHz)','Contrast (a. u. )',[])
end

