clc
close all
clear all

folderdir = 'X:\����\��ͼ\indentation experiment\PMMA'
filedir = [folderdir '\*.txt'];

cd (folderdir)
namelist = dir(filedir);


tdf = {};
o = [];
for j = 1:length(namelist)
    %data:time (s)	dz (nm)	T-B (mV)	Scanner-Z (nm)
    data = importdata(namelist(j).name);
    force = 0;
    distance = 0;   %Ĥ���α����
    time = 0;
    angle = 0;
    z0 = data.data(1,4);
    b0 = data.data(1,3);
    
    k = 30;   %̽��ĵ���ϵ����N/m
    q = 1.02;   %q = 1/(1.05-0.15v-0.16v^2),����ʯīϩ��1.02��vΪ���ɱ�
    a = 200*0.5; %����׵İ뾶,nm
    mVtonm = 2.87;
    
    process = [];

    for i = 2:length(data.data(:,1))         
        force = [force;(data.data(i,3)-b0) / mVtonm * k]; %�Ե�һ������Ϊ��׼����̽���α�����̽�����
        distance = [distance;-(data.data(i,4)-z0)-(data.data(i,3)-b0)/mVtonm];    %�Ե�һ�����λ��Ϊ��׼����ɨ����λ�ƺ�̽���α����Ĥ���α����
        time = [time;data.data(i,1)];
        angle = atan(distance/a)/pi*180;
    end
    
    %����������ɢ��ͼ
    scatter(time,force);
    hold on;
    
    maxf = max(angle);
    code = find(angle == maxf);
    o = [o;angle(code) force(code)];
    
    %������õ�����������ı��ļ�
    process = [process time distance force];%�ϲ�����õ�ʱ�䡢�������    
    tdf{j} = process;%������õ����ݷ���Ԫ�������Ա�����һ�������н������
    
    for g = length(process)+1:200  %Ϊʹ����ƴ�Ӿ���ʱ����һ�£������󳤶���0����200
        process = [process;0 0 0];
    end
end
    csvwrite('processed.csv', process);