clc,clear,close all
%% 导入数据
% prefix = '';
% suffix = '';
% filename = [prefix, suffix];
% rawdata  = importdata(filename);
% rawdata = rawdata * 1000;
%% 输入参数
Fs = 2000;
N = length(rawdata);
t = (0:N-1)/Fs;
%% 设计滤波器
Fpass = 400;
Fstop = 402;
Ap = 1;
Ast = 60;
window = 'hamming';
filtertype = '';

% %FIR filter
% dfilter = designfilt('lowpassfir','PassbandFrequency',Fpass,...
%   'StopbandFrequency',Fstop,'PassbandRipple',Ap,...
%   'StopbandAttenuation',Ast,'SampleRate',Fs);

%IIR filter
%DesignMethod = {'butter','cheby1','cheby2','ellip'}
dfilter = designfilt('lowpassiir','PassbandFrequency',Fpass,...
  'StopbandFrequency',Fstop,'PassbandRipple',Ap,...
  'StopbandAttenuation',Ast,'SampleRate',Fs,'DesignMethod','butter');

D = grpdelay(dfilter, 2048, Fs);    %plot group delay
hfvt = fvtool(dfilter)
%% 用滤波器滤波
% if length(unique(D)) == 1
%     delay = mean(D);
%     filterdata = filter(dfilter,[rawdata ;zeros(delay,1)]);
%     filterdata = filterdata(D+1:end);
% else
%     y = filtfilt(dfilter, rawdata);
% end
%% 功率谱密度分析
[praw,f] = pburg(rawdata,order,f,Fs);
[pfiltered,f] = pburg(filterdata,order,f,Fs);
%% 作图
h1 = figure(1);
set(h1,'unit','pixels','position',[0 0 1200 900],'Color',[1,1,1]);

subplot(2,2,1)
plot(t,rawdata,'LineWidth',2);
xlabel('Time(s)');
ylabel('Voltage(V)')
set(gca,'linewidth',1,'fontname','Arial');
set(gca,'Box','On','LineWidth',1);
title('RawSig vs. T');

subplot(2,2,3)
plot(t,filterdata,'LineWidth',2);
xlabel('Time(s)');
ylabel('Voltage(V)')
set(gca,'linewidth',1,'fontname','Arial');
set(gca,'Box','On','LineWidth',1);
title('FiteredSig vs. T');

subplot(2,2,2)
plot(f,praw,'LineWidth',2);
xlabel('Frequency(Hz)');
ylabel('mV^2/Hz')
set(gca,'linewidth',1,'fontname','Arial','Box','On','LineWidth',1,...
    'Xscale','log','YScale','log');
title('RawSig PDS');

subplot(2,2,4)
plot(f,pfiltered,'LineWidth',2);
xlabel('Frequency(Hz)');
ylabel('mV^2/Hz')
set(gca,'linewidth',1,'fontname','Arial','Box','On','LineWidth',1,...
    'Xscale','log','YScale','log');
title('FilterSig PSD');



