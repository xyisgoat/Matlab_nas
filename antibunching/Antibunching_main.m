clc,clear,close all
%% 设置路径
mainpath =  'W:\Yang Xu\Projects\Antibunching\';
dirdata = [mainpath,'Data'];
dirresult = [mainpath,'Results\']
cd(dirdata)
%% 输入文件信息
prefix = 'STACKS_1-1';
suffix = '.tif';
filename = [prefix, suffix];
%% 输入设置参数
PhotonThreshold = 500;
EMgain = 500;
ADunit = 5.02;
PixelSize = 106.7; %nm
QE = 0.9;
ExposureTime = 10;  %ms
R = 2;
H = 0.5;
S = 0.5;
tau = 0;
N = 5; %插值倍率
subcol = 3;
subrow = 4;
%% 主程序
if isfile(filename)
    %% 读入数据并转换成光子数
    fprintf('data file found\n');      
    Image = imstacksread(filename);
    Image.photon = int2photon(Image.intensity,EMgain,ADunit,QE);
    sumImage.intensity = sum(Image.intensity,3);
    sumImage.photon = sum(Image.photon,3);  
    %% 计算a2,g2并赋值至对应的像素
    n = 0;
    for R = 0
        n = n + 1;
        A2stacks = {[],[],[],[]};
        sumImage.a2 = zeros(Image.width,Image.height,4);
        interImage.a2 = zeros(Image.width * N, Image.height * N,4);
        for i = 1:4
            fprintf('Processing  g2,a2, loop %.d ... ', i)
            t1 = clock; 

            pattern = g2pat(i);
            corr2result = corr2calc(pattern, tau, R, N, Image.photon);
            %a2 signal        
            sumImage.a2(:,:,i) = corr2result.sumA2stacks;
            interImage.a2(:,:,i) = corr2result.intersumA2stacks;
            %g2 signal
            sumImage.g2(:,:,i) = corr2result.sumG2stacks;
            interImage.g2(:,:,i) = corr2result.intersumG2stacks;

            t2 = clock;
            fprintf('Process Time = %.5f Seconds\n',etime(t2,t1));                
        end

        sumImage.a2 = sum(sumImage.a2,3);
        interImage.suma2 = sum(interImage.a2,3);

        sumImage.g2 = mean(sumImage.g2,3);
        interImage.sumg2 = mean(interImage.g2,3);

    %     subplot(2,3,n + 2)
    %     surface([1:Image.width],[1:Image.height], intersumA2,'EdgeColor','none');
    %     xlim([1,Image.width]);ylim([1,Image.width]);colorbar;
    %     title('sum antibunching')   
    end
    %% 计算g3并赋值至对应的像素
    n = 0;
    for R = 0
        n = n + 1;
        A3stacks = {[],[],[],[]};
        sumImage.a3 = zeros(Image.width,Image.height,4);
        interImage.a3 = zeros(Image.width * N, Image.height * N,4);
        for i = 1:4
            fprintf('Processing g3,a3, loop %.d ... ', i)
            t1 = clock; 

            pattern = g3pat(i);
            corr3result = corr3calc(pattern,tau,tau,H,S,N,Image.photon);
            %a2 signal        
            sumImage.a3(:,:,i) = corr3result.sumA3stacks;
            interImage.a3(:,:,i) = corr3result.intersumA3stacks;
            %g2 signal
            sumImage.g3(:,:,i) = corr3result.sumG3stacks;
            interImage.g3(:,:,i) = corr3result.intersumG3stacks;

            t2 = clock;
            fprintf('Process Time = %.5f Seconds\n',etime(t2,t1));                
        end

        sumImage.a3 = sum(sumImage.a3,3);
        interImage.suma3 = sum(interImage.a3,3);

        sumImage.g3 = mean(sumImage.g3,3);
        interImage.sumg3 = mean(interImage.g3,3);

    %     subplot(2,3,n + 2)
    %     surface([1:Image.width],[1:Image.height], intersumA2,'EdgeColor','none');
    %     xlim([1,Image.width]);ylim([1,Image.width]);colorbar;
    %     title('sum antibunching')   
    end
    %% 傅里叶插值
    interImage.intensity = interpft2(sumImage.intensity,N);
    interImage.photon = interpft2(sumImage.photon,N);
    %% 输出结果
    outputdir = [dirresult,prefix,'_',date,'-',...
        num2str(hour(datetime('now'))),'-',num2str(minute(datetime('now'))),'\'];
    mkdir(outputdir);
    cd (outputdir);
    imstackswrite(sumImage.intensity,'sumImage_intensity.raw');
    imstackswrite(sumImage.photon,'sumImage_photon.raw');
    imstackswrite(sumImage.a2,'sumImage_a2.raw');        
    imstackswrite(sumImage.g2,'sumImage_g2.raw');    
    imstackswrite(sumImage.a3,'sumImage_a3.raw');  
    imstackswrite(sumImage.g3,'sumImage_g3.raw');
    imstackswrite(interImage.intensity,'interImage_intensity.raw'); 
    imstackswrite(interImage.photon,'interImage_photon.raw');     
    imstackswrite(interImage.suma2,'interImage_suma2.raw'); 
    imstackswrite(interImage.suma3,'interImage_suma3.raw');
    imstackswrite(interImage.sumg2,'interImage_sumg2.raw');
    imstackswrite(interImage.sumg3,'interImage_sumg3.raw');

    %% a2结果
    h1 = figure;
    set(h1,'unit','pixels','position',[280,30,799,696],'color',[1,1,1]);      

    subplot(subrow,subcol,1)
    surface([1:Image.width],[1:Image.height],sumImage.intensity,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum intensity')
       
    subplot(subrow,subcol,2)
    surface([1:Image.width],[1:Image.height],sumImage.photon,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum photoncounts')    

    subplot(subrow,subcol,3)
    surface([1:Image.width],[1:Image.height],sumImage.a2,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum a2') 
    
    subplot(subrow,subcol,4)
    surface([1:Image.width * N],[1:Image.height * N],interImage.intensity,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum intensity')    
    
    subplot(subrow,subcol,5)
    surface([1:Image.width * N],[1:Image.height * N],interImage.photon,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum photons')    
    
    subplot(subrow,subcol,6)
    surface([1:Image.width * N],[1:Image.height * N],interImage.suma2,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a2')       
    
    subplot(subrow,subcol,7)
    surface([1:Image.width * N],[1:Image.height * N],interImage.a2(:,:,1),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a2 Pattern 1')    
    
    subplot(subrow,subcol,8)
    surface([1:Image.width * N],[1:Image.height * N],interImage.a2(:,:,2),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a2 Pattern 2')  
    
    subplot(subrow,subcol,9)
    surface([1:Image.width * N],[1:Image.height * N],interImage.a2(:,:,3),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a2 Pattern 3') 
    
    subplot(subrow,subcol,10)
    surface([1:Image.width * N],[1:Image.height * N],interImage.a2(:,:,4),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a2 Pattern 4') 
    
    %% g2结果
    h2 = figure
    set(h2,'unit','pixels','position',[280,30,799,696],'color',[1,1,1]);      

    subplot(subcol,subcol,1)
    surface([1:Image.width],[1:Image.height],sumImage.intensity,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum intensity')
       
    subplot(subcol,subcol,2)
    surface([1:Image.width],[1:Image.height],sumImage.photon,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum photoncounts')    

    subplot(subrow,subcol,3)
    surface([1:Image.width],[1:Image.height],sumImage.g2,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum g2') 
    
    subplot(subrow,subcol,4)
    surface([1:Image.width * N],[1:Image.height * N],interImage.intensity,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum intensity')    
    
    subplot(subrow,subcol,5)
    surface([1:Image.width * N],[1:Image.height * N],interImage.photon,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum photons')    
    
    subplot(subrow,subcol,6)
    surface([1:Image.width * N],[1:Image.height * N],interImage.sumg2,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum g2')       
    
    subplot(subrow,subcol,7)
    surface([1:Image.width * N],[1:Image.height * N],interImage.g2(:,:,1),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum g2 Pattern 1')    
    
    subplot(subrow,subcol,8)
    surface([1:Image.width * N],[1:Image.height * N],interImage.g2(:,:,2),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a2 Pattern 2')  
    
    subplot(subrow,subcol,9)
    surface([1:Image.width * N],[1:Image.height * N],interImage.g2(:,:,3),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum g2 Pattern 3') 
    
    subplot(subrow,subcol,10)
    surface([1:Image.width * N],[1:Image.height * N],interImage.g2(:,:,4),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum g2 Pattern 4') 
    
     %% a3结果
    h3 = figure;
    set(h3,'unit','pixels','position',[280,30,799,696],'color',[1,1,1]);      

    subplot(subrow,subcol,1)
    surface([1:Image.width],[1:Image.height],sumImage.intensity,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum intensity')
       
    subplot(subrow,subcol,2)
    surface([1:Image.width],[1:Image.height],sumImage.photon,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum photoncounts')    

    subplot(subrow,subcol,3)
    surface([1:Image.width],[1:Image.height],sumImage.a3,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum a3') 
    
    subplot(subrow,subcol,4)
    surface([1:Image.width * N],[1:Image.height * N],interImage.intensity,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum intensity')    
    
    subplot(subrow,subcol,5)
    surface([1:Image.width * N],[1:Image.height * N],interImage.photon,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum photons')    
    
    subplot(subrow,subcol,6)
    surface([1:Image.width * N],[1:Image.height * N],interImage.suma3,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a3')       
    
    subplot(subrow,subcol,7)
    surface([1:Image.width * N],[1:Image.height * N],interImage.a3(:,:,1),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a3 Pattern 1')    
    
    subplot(subrow,subcol,8)
    surface([1:Image.width * N],[1:Image.height * N],interImage.a3(:,:,2),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a3 Pattern 2')  
    
    subplot(subrow,subcol,9)
    surface([1:Image.width * N],[1:Image.height * N],interImage.a3(:,:,3),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a3 Pattern 3') 
    
    subplot(subrow,subcol,10)
    surface([1:Image.width * N],[1:Image.height * N],interImage.a3(:,:,4),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a3 Pattern 4') 
    
    %%  g3结果
    h4 = figure
    set(h4,'unit','pixels','position',[280,30,799,696],'color',[1,1,1]);      

    subplot(subcol,subcol,1)
    surface([1:Image.width],[1:Image.height],sumImage.intensity,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum intensity')
       
    subplot(subcol,subcol,2)
    surface([1:Image.width],[1:Image.height],sumImage.photon,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum photoncounts')    

    subplot(subrow,subcol,3)
    surface([1:Image.width],[1:Image.height],sumImage.g3,'EdgeColor','none');
    xlim([1,Image.width]);ylim([1,Image.height]);colorbar;
    title('sum g3') 
    
    subplot(subrow,subcol,4)
    surface([1:Image.width * N],[1:Image.height * N],interImage.intensity,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum intensity')    
    
    subplot(subrow,subcol,5)
    surface([1:Image.width * N],[1:Image.height * N],interImage.photon,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum photons')    
    
    subplot(subrow,subcol,6)
    surface([1:Image.width * N],[1:Image.height * N],interImage.sumg3,'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum g3')       
    
    subplot(subrow,subcol,7)
    surface([1:Image.width * N],[1:Image.height * N],interImage.g3(:,:,1),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum g3 Pattern 1')    
    
    subplot(subrow,subcol,8)
    surface([1:Image.width * N],[1:Image.height * N],interImage.g3(:,:,2),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum a3 Pattern 2')  
    
    subplot(subrow,subcol,9)
    surface([1:Image.width * N],[1:Image.height * N],interImage.g3(:,:,3),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum g3 Pattern 3') 
    
    subplot(subrow,subcol,10)
    surface([1:Image.width * N],[1:Image.height * N],interImage.g3(:,:,4),'EdgeColor','none');
    xlim([1,Image.width * N]);ylim([1,Image.height * N]);colorbar;
    title('interplot sum g3 Pattern 4') 
    
else
    fprintf('Failed to found file\n')
end