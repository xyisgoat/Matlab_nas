clc, clear, close all
% % clc,clear all
%% 输入文件名
prefix = ['20210707_41'];           %输入文件名
suffix = '.tif';
filename = [prefix,suffix];
%% 输入相机参数
ADunit = 5.02;
EMgain = 50;
QE = 0.9;
offset = 400;
T_exposure = 0.005;   %exposure time, s
T_readout = 0.01;
loopnum = 200;
L_roi = 20;
%% 输入数据处理参数
frame_min = 0;   %starting frame
frame_max = 0;  %end frame
stepsize = 1;  %step size, MHz
freq_min = 2855;   %starting frequency, MHz
freq_max = 2875;
pks = 2;    %拟合的峰个数
dT = 0.077;  %MHz/K
ref = 'on';

f = [freq_min/stepsize:freq_max/stepsize]*stepsize;
cycframe = (freq_max-freq_min)/stepsize + 1;

%% 读取图像数据
%导入csv
if isfile([prefix,'.csv'])
    fprintf([prefix,'.csv ', 'found\n']);
    data = readmatrix([prefix,'.csv']);
    %% Parameters for sensitivity calculation
    pixelnum = (2*(L_roi + 1))^2;  
    Sumint = (mean(data(2,:))) * pixelnum;    %Total intensity of ROI
    N_photon = Sumint * ADunit / (QE * EMgain * T_exposure);
    %% 
    data = data(frame_min+1:length(data)-frame_max,:)';
    data = reshape(data(2,:),2,[]);
    data_copy = data;
    
    if strcmp(ref,'on')
        data = data(1,:)./data(2,:);
    end

    data_reshape = reshape(data,loopnum,[]);
    
    for i = 1:length(data_reshape(1,:))
        data_rms(i) = rms(data_reshape(:,i));
%         data_rms(i) = fitdist(data_reshape(:,i),'normal').mu;
    end
           
    cycnum = idivide(int64(length(reshape(data_rms,1,[]))),int64(cycframe));
    t = double([1:cycnum]) * (T_exposure + T_readout)*loopnum*cycframe;  %横坐标,时间, s
    data_rms = reshape(data_rms,cycframe,[]);
    %%
        h1 = figure;
        set(h1,'unit','pixels','position',[0 0 1200 900],'color',[1,1,1]);  
    for i = 1:cycnum
        tempdata = data_rms((i-1)*cycframe + 1:i * cycframe);
        avetemp = tempdata;
        fitdata = ODMRsmooth(cycnum,avetemp,'off');
        fitf = f;
        
        [C(i,:),W(i,:),FWHM(i),D(i,:),B(i),R(i),yft,gof,formula, Dconfint(i)] ...
            = ODMRFit(pks,fitf,fitdata);   
        T(i) = mean(D(i,:))/dT;
        T_sens(i) = FWHM(i)/(dT*mean(C(i,:))*sqrt(N_photon));
        
        plot(fitf',fitdata','LineWidth',2,'Marker','.','MarkerSize',20,...
            'LineStyle','none');
        hold on
        p = plot(yft);
        p.LineWidth = 2;
        hold on
        xlim([min(fitf),max(fitf)])
        FigureFormat('Time (min)','Temp. (K)',['GLASS-20210524-3B',', loop = ', num2str(loopnum)])
    end
        FigureFormat('Freq. (MHz)','Contrast (a. u. )',[sprintf('D = %.3f ± %.3f  MHz ',D,Dconfint)])
        hold off
    
    
%         h1 = figure;
%         set(h1,'unit','pixels','position',[0 0 1200 900],'color',[1,1,1]);        
%         D(D<2850) = rms(D);
%         T = T-rms(T);
%          T(T<-30) = 0;
%         T_smooth = smooth(T,length(T)/2,'loess')';
% 
%         plot(t/60,T,'LineWidth',2,'Marker','.','MarkerSize',30)
%         hold on
%         plot(t/60,T_smooth,'LineWidth',2,'LineStyle','--')
% 
%         FigureFormat('Time (min)','Temp. (K)',['GLASS-20210524-3B',', loop = ', num2str(loopnum)])
%         hold off
        
%         fprintf(sprintf('STD_dT = %.3f\n',std(T-T_smooth)))
        
%         h1 = figure;
%         set(h1,'unit','pixels','position',[0 0 1200 900],'color',[1,1,1]);  
%         hf = histfit(D);
%         mu = fitdist(D,'normal').mu;
%         sigma = fitdist(D,'normal').sigma;
%         fprintf(sprintf('Dave = %.6f\n',mu));
%         FigureFormat('Freq. (MHz)','Counts',[sprintf('D = %.3f ± %.3f  MHz ',mu,2*sigma)])

else
    fprintf('File not found\n');
end               






