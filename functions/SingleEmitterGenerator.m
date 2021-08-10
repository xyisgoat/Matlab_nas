function [x1,x2,y1,y2,omega_x,omega_y,Image] = SingleEmitterGenerator(distance)
% author : Yang Xu
% 本代码用于根据半峰宽等参数计算两点的PSF，并根据PSF为分布概率，计算每一帧
% 光子的位置
%% 输入参数
pixel=106;   %像素尺寸 nm
lambda=620;  %激光波长 nm
NA=1.49;    %数值孔径
diffraction=lambda/2/NA/pixel;   %衍射极限
bg=400;   %背景
FWHM = diffraction;    %单分子半峰宽
omega_x=ceil(FWHM/1.1774);
omega_y=ceil(FWHM/1.1774);
Image.height = 20;  %探测器靶面列
Image.width = 20;  %探测器靶面行
rows=1:Image.height;
cols=1:Image.width;
[X,Y]=meshgrid(rows,cols);
x1=floor(0.4 * Image.width);
y1=floor(0.5 * Image.height);
x2=x1+distance/pixel;
y2=y1;
Nacc = 1;
frame=50000;
SE = 0.5;        %SystemEfficiency
QE = 0.95;
EMgain=500;
ADunit=5.02;
std=18.5;

photonrange = 0:5;
photondist = poisspdf(photonrange,0.4);
photondist(end) = photondist(end) + (1-sum(photondist));
randphoton1 = randsrc(frame,1,[photonrange;photondist]);
randphoton2 = randsrc(frame,1,[photonrange;photondist]);

fprintf('generating simulation data\n');
fprintf('-------------------------------\n') 
%% 主程序
% 计算两个分子高斯分布
I1=exp(-2*(X-x1).^2/omega_x^2-2*(Y-y1).^2/omega_y^2);
I2=exp(-2*(X-x2).^2/omega_x^2-2*(Y-y2).^2/omega_y^2);

% 根据高斯分布计算每帧光子分布
I1 = I1/sum(sum(I1));
I2 = I2/sum(sum(I2));

% 根据概率计算光子数分布
prob1 = reshape(I1,1,[]);
prob2 = reshape(I2,1,[]);
alphabet1 = [1:length(prob1)];
alphabet2 = [1:length(prob2)];
PhotonXY1 = randsrc(frame,1,[alphabet1;prob1]);
PhotonXY2 = randsrc(frame,1,[alphabet2;prob2]);

PhotonX1 = ceil(PhotonXY1/Image.width);
PhotonY1 = rem(PhotonXY1,Image.width);
PhotonX2 = ceil(PhotonXY2/Image.width);
PhotonY2 = rem(PhotonXY2,Image.width);

%将计算得到的光子数分布对应至帧和像素
tempI1 = zeros(Image.height,Image.width,frame);
tempI2 = zeros(Image.height,Image.width,frame);

for i = 1:frame
    tempI1(PhotonX1(i),PhotonY1(i),i) = randphoton1(i);
    tempI2(PhotonX2(i),PhotonY2(i),i) = randphoton2(i);
end

% 将计算得到的光子数转化为EMCCD强度
simuImage.photon = reshape(tempI1 + tempI2,Image.height,Image.width,frame/Nacc,Nacc);
simuImage.photon = sum(simuImage.photon,4);
simuImage.intensity = simuImage.photon * SE*QE * EMgain / ADunit + bg;


% 在EMCCD强度数据中假如噪声得到最终结果
I_noise=round(normrnd(0,std,[Image.height,Image.width,frame/Nacc]))+simuImage.intensity; %高斯噪声
Image.intensity=permute(I_noise,[2,1,3]);
% Image.intensity=flip(Image.intensity,2);  %每一页中的行翻转
fprintf('done\n');
fprintf('-------------------------------\n') 
end

