function [data,Offset] = int2photon(Image,EMgain,ADunit,QE)
%用于将图像强度转换成光子个数
%   此处显示详细说明
    pixelreshape = reshape(Image,1,[]);
    dist = histogram(pixelreshape,1000);
    counts = dist.Values;
    edges = dist.BinEdges;
    Offset = edges(counts == max(counts));    
    data = round((Image-Offset) * ADunit / (QE * EMgain));
    data(data < 0 ) = 0;
end

