function [] = result_output(sumImage,interImage,Image,scale,R,S,H)
%用于将计算结果保存至指定文件
%   此处显示详细说明
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
    f = fopen('README.txt','wb');
    info = [sprintf('sumimage: %d * %d\n', Image.height,Image.width),...
        sprintf('intersumimage: %d * %d\n', Image.height * scale,Image.width * scale),...
        sprintf('R = %.2f, S = %.2f,H = %.2f', R,S,H)];
    fwrite(f,info,'char');
    fclose('all');
end

