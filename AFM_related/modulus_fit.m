% cd X:\徐扬\数据处理\2019.12.30~2020.01.05\NEW4-2-4-0006
% namelist = dir('D:\ZJU\课题组\AFM\数据处理\20191219\NEW01-0003\*.txt');
cd (folderdir)

input = [0.2266;0.2266]; %输入从散点图中读出的拟合起始点

rsum = [];
ysmsum = [];
k1sum = [];
process = [];
datapro = [];
fitted = [];
fitdata = {[] [] [] [] []};

for l = 1:length(tdf)    
    spot = input(l,:);
    flag = 0;
    for m = 1:length(tdf{l})
        if abs(tdf{l}(m,1) - spot(1)) < 0.0001||flag == 1
            flag = 1;
            fitdata{l} = [fitdata{l};tdf{l}(m,:)];
        end
        if flag == 1 && tdf{l}(m,2) - tdf{l}(m+1,2) > 0
            break;
        end
    end
    
    %以所选取为基准进行零点校准
    temp = fitdata{l}(1,:);
    for n = 1:length(fitdata{l})
        fitdata{l}(n,:) = fitdata{l}(n,:) - temp;
    end
    
    
    %自定义拟合函数f(t)=a*cos(k*t)*exp(w*t)
    syms d
    x=fitdata{l}(:,2);%列向量
    y=fitdata{l}(:,3);
    ft=fittype('k1*d+k2*d^3','independent','d','coefficients',{'k1','k2'});  %fittype是自定义拟合函数
    [fitresult, gof] = fit( x, y, ft );
    fitted = [fitted;fitresult.k1 fitresult.k2 fitresult.k2/q^3*a^2 gof.rsquare];
end
    csvwrite('fitresult.csv', fitted);





