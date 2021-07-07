function Image = imstacksread(filename)
%用于读取图像序列
%   此处显示详细说明
    t1 = clock;
    %% 获取图像信息，建立空矩阵
    Info=imfinfo(filename);                                        %%获取图片信息并判断是否为tif
    totSlice = size(Info,1);                                                   %%获取图片z向帧数
    totWidth = Info.Width;
    totHeight = Info.Height;
    data = zeros(totHeight,totWidth,totSlice);
    %% 将图像信息读入矩阵    
    for i = 1:totSlice
    data(:,:,i) = imread(filename,i);                        %%一层一层的读入图像
    fprintf('Reading Slice %d\n',i);
    end
    %% 传递数据
    Image.slice = totSlice;
    Image.width = totWidth;
    Image.height = totHeight;
    Image.intensity = data;
    %%
    t2 = clock;
    fprintf('Read Time = %.5f Seconds\n',etime(t2,t1));
end

