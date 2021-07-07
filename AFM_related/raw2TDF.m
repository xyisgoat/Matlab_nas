clc
close all
clear all

folderdir = 'X:\徐扬\作图\indentation experiment\PMMA'
filedir = [folderdir '\*.txt'];

cd (folderdir)
namelist = dir(filedir);


tdf = {};
o = [];
for j = 1:length(namelist)
    %data:time (s)	dz (nm)	T-B (mV)	Scanner-Z (nm)
    data = importdata(namelist(j).name);
    force = 0;
    distance = 0;   %膜的形变距离
    time = 0;
    angle = 0;
    z0 = data.data(1,4);
    b0 = data.data(1,3);
    
    k = 30;   %探针的弹性系数，N/m
    q = 1.02;   %q = 1/(1.05-0.15v-0.16v^2),对于石墨烯是1.02，v为泊松比
    a = 200*0.5; %输入孔的半径,nm
    mVtonm = 2.87;
    
    process = [];

    for i = 2:length(data.data(:,1))         
        force = [force;(data.data(i,3)-b0) / mVtonm * k]; %以第一个数据为基准，从探针形变计算出探针的力
        distance = [distance;-(data.data(i,4)-z0)-(data.data(i,3)-b0)/mVtonm];    %以第一个点的位置为基准，从扫描器位移和探针形变算出膜的形变距离
        time = [time;data.data(i,1)];
        angle = atan(distance/a)/pi*180;
    end
    
    %将数据做成散点图
    scatter(time,force);
    hold on;
    
    maxf = max(angle);
    code = find(angle == maxf);
    o = [o;angle(code) force(code)];
    
    %将处理好的数据输出到文本文件
    process = [process time distance force];%合并处理好的时间、距离和力    
    tdf{j} = process;%将处理好的数据放入元胞数组以便在另一个程序中进行拟合
    
    for g = length(process)+1:200  %为使后续拼接矩阵时长度一致，将矩阵长度用0补成200
        process = [process;0 0 0];
    end
end
    csvwrite('processed.csv', process);