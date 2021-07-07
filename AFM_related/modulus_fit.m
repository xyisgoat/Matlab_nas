% cd X:\����\���ݴ���\2019.12.30~2020.01.05\NEW4-2-4-0006
% namelist = dir('D:\ZJU\������\AFM\���ݴ���\20191219\NEW01-0003\*.txt');
cd (folderdir)

input = [0.2266;0.2266]; %�����ɢ��ͼ�ж����������ʼ��

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
    
    %����ѡȡΪ��׼�������У׼
    temp = fitdata{l}(1,:);
    for n = 1:length(fitdata{l})
        fitdata{l}(n,:) = fitdata{l}(n,:) - temp;
    end
    
    
    %�Զ�����Ϻ���f(t)=a*cos(k*t)*exp(w*t)
    syms d
    x=fitdata{l}(:,2);%������
    y=fitdata{l}(:,3);
    ft=fittype('k1*d+k2*d^3','independent','d','coefficients',{'k1','k2'});  %fittype���Զ�����Ϻ���
    [fitresult, gof] = fit( x, y, ft );
    fitted = [fitted;fitresult.k1 fitresult.k2 fitresult.k2/q^3*a^2 gof.rsquare];
end
    csvwrite('fitresult.csv', fitted);





