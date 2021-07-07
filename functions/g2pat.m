function [pattern] = g2pat(i)
%用于生成处理EMCCD的g2信号的
%   此处显示详细说明
    switch i
        case 1               
    %                 Image_1 = (Image(1:end-1,1:end-1,:));
    %                 Image_2 = (Image(2:end,1:end-1,:));
            pattern = [0,1;0,1;1,0;0,1];
        case 2               
    %                 Image_1 = (Image(1:end-1,1:end-1,:));
    %                 Image_2 = (Image(1:end-1,2:end,:));
            pattern = [0,1;0,1;0,1;1,0];
        case 3
    %                 Image_1 = (Image(1:end-1,1:end-1,:));
    %                 Image_2 = (Image(2:end,2:end,:));
            pattern = [0,1;0,1;1,0;1,0];
        case 4                
    %                 Image_1 = (Image(1:end-1,2:end,:));
    %                 Image_2 = (Image(2:end,1:end-1,:));
            pattern = [0,1;1,0;1,0;0,1];
    end
end

