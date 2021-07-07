function [outputdata] = interpft2(inputdata,N)
%将interpft应用于两个维度以进行二维插值
%   此处显示详细说明
    height = size(inputdata,1);
    width = size(inputdata,2);
    outputdata = interpft(interpft(inputdata,height * N, 2), width * N, 1);
end

