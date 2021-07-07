clc
clear all
close all

cd X:\徐扬\数据处理\2020.01.06~2020.01.12\20200106Force_vs_diameters\data
namelist = dir('X:\徐扬\数据处理\2020.01.06~2020.01.12\20200106Force_vs_diameters\data\*.csv');
diameter = csvread('diameter.csv');
j = 1;
taf = {};
FvA = [];
angle = 12;
dianame = namelist(1).name;
sfva = {};

diameter = csvread('diameter.csv');
j = 1;
taf = {};
FvA = [];
    
    dianame = namelist(1).name;
    for i = 1:length(namelist)-1
        name = namelist(i).name;
        if name(1:19) == dianame(1:19)
            r = diameter(j)*0.5;
        else
            j = j + 1;
            r = diameter(j)*0.5;
            dianame = namelist(i).name;
        end
        temptaf = importdata(namelist(i).name);
        temptaf(:,2) = atan(temptaf(:,2)/r)/pi*180;
        taf{j,i} = temptaf;

    %     compare = max(max(temptaf()))
        if (temptaf(length(temptaf),2)-angle) > -1
    %         flag1 = temptaf;
            temptaf(:,2) = abs(temptaf(:,2) - angle);
    %         flag = temptaf;
            sorted = sortrows(temptaf,2);
    %         test = sorted;
            sorted(1,2) = angle;
            sorted(1,1) = diameter(j);
            FvA = [FvA;i sorted(1,:)];
        end
        temptaf = [];
    end

