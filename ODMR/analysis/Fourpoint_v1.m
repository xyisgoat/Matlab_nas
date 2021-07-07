clc,clear,close all
%% 输入文件名
prefix = '20210414_4';           %输入文件名
suffix = '.tif';
filename = [prefix,suffix];

%% 输入处理参数
points = 100;
freq = [2848, 2853, 2878, 2883];
t_exp = 50;         %exposure time, ms
dDdT = 0.077        %MHz/k
%% 输入相机参数
ADunit = 5.02;
EMgain = 50;
QE = 0.9;
offset = 400;

xrow = 2;
yrow = 2;
%% 读取图像数据
%若路径下已有该tif文件的csv数据文件，则直接导入csv
if isfile([prefix,'.csv'])
    fprintf('data file found\n');
    data = readmatrix([prefix,'.csv']);
    bg = data(1,1);
    data(1,:) = [];
else
%% 获取图像信息，建立空矩阵
    t1 = clock;
    
    Info=imfinfo(filename);                                        %%获取图片信息并判断是否为tif
    Slice = size(Info,1);                                                   %%获取图片z向帧数
    Width = Info.Width;
    Height = Info.Height;
    Image = zeros(Height,Width,Slice);
    
    t2 = clock;
    
    fprintf('Import Time = %.5f Seconds\n',etime(t2,t1));
    Point = zeros(xrow*2+1,yrow*2+1,Slice);

%% 将图像信息读入矩阵
    xymax = zeros(Slice,2);
    intmax = zeros(Slice,1);
    intmean = zeros(Slice,1);
    data = zeros(Slice,2);

    t1 = clock;
    for i = 1:Slice
        Image(:,:,i) = imread(filename,i);                        %%一层一层的读入图像
        fprintf('Reading Slice %d\n',i);
    end
    t2 = clock;
    
    fprintf('Read Time = %.5f Seconds\n',etime(t2,t1));
%% 找到最大值并计算每一帧中最大值所在区域的平均强度
    t1 = clock; 
    for j = 1:Slice
        tempim = Image(:,:,j);
        [tempx, tempy] = find(tempim == max(max(tempim)));
        xymax(j,:) = [tempx(1), tempy(1)];
        intmax(j) = tempim(tempx(1),tempy(1));
        Point(:,:,j) = Image(tempx-xrow:tempx+xrow,tempy-yrow:tempy+yrow,j);
        intmean(j) = mean(mean(Point(:,:,j)));
        data(j,:) = [j,mean(mean(Point(:,:,j)))];
    end
    t2 = clock;
    fprintf('Processing Time = %.5f Seconds\n', etime(t2,t1));
    
    %calculate background
    pixelreshape = reshape(Image,1,[]);
    dist = histogram(pixelreshape,1000);
    counts = dist.Values;
    edges = dist.BinEdges;
    bg = edges(find(counts == max(counts)));

    %将数据导出
    outsuffix = '.csv';
    outname = [prefix,outsuffix];
    writematrix([bg 0;data], outname);
end

%%
rawsig = data(2,:);
refsig = reshape(rawsig,2,[]);
resig = reshape(refsig(1,:)./refsig(2,:),points,[]);
avesig = sum(resig)/length(resig(:,1));
fitsig = reshape(avesig,length(freq),[]);

for i  = 1:length(fitsig)
    p1 = polyfit(freq(1:2),fitsig(i,1:2),1);k1 = p1(1);b1 = p1(2);
    p2 = polyfit(freq(3:4),fitsig(i,3:4),1);k2 = p2(1);b2 = p2(2);
    D(i) = (b2-b1)/(k1-k2);
end

t = [0:length(avesig)-1] * points * t_exp / 1e3;        %s
D = D - D(1);
T = D/dDdT;
%%
h1 = figure;
set(h1,'unit','pixels','position',[0 0 1200 900],'color',[1,1,1]);

plot(t,T,'LineWidth',1,'Marker','.','MarkerSize',20,'LineStyle','none');

set(gca,'linewidth',1,'fontsize',20,'fontname','Arial');
set(gca,'Position',[0.13,0.3,0.6,0.6]);
set(gca,'Box','On','LineWidth',1,'Color','none');
xlabel('Time (s)','Fontname','Arial','FontSize',20);
ylabel('\DeltaT (K)','Fontname','Arial','FontSize',20);
legend('off')






