function imstackswrite(img,fileName)
% This function can write image matrix into .RAW file.
% Written by Yang Xu, Jul. 2021
f = fopen(fileName,'wb');
fwrite(f,img,'float64');
fclose('all');
end

