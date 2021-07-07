function corr2result = corr2calc(pattern,tau,R,N,Image)
%用于计算A2的值
%参考文献：dx.doi.org/10.1021/nl402552m | Nano Lett. 2013, 13, 5832−5836
%A2 = Image_1 * Image_2 - 0.1 * R * Image_1 * Image_k  
    %%
    height = size(Image,2);
    width = size(Image,1);
    Image_1 = Image(1+pattern(1,1):end-pattern(1,2),1+pattern(2,1):end-pattern(2,2),:);
    Image_2 = Image(1+pattern(3,1):end-pattern(3,2),1+pattern(4,1):end-pattern(4,2),:);      
    %% 计算 Image_1 * Image_2
    ImgSize = size(Image_1);
    Image_k = zeros(ImgSize(1),ImgSize(2),ImgSize(3));
    if tau > 0
        Image_2 = Image_2(:,:,1 + tau:end);
        Image_2 = cat(3,zeros(ImgSize(1),ImgSize(2),abs(tau)),Image_2);           
    else
        Image_2 = Image_2(:,:,1:end + tau);
        Image_2 = cat(3,Image_2,zeros(ImgSize(1),ImgSize(2),abs(tau)));
    end
    aveIm1Im2 = gather(mean(gpuArray(Image_1),3).*mean(gpuArray(Image_2),3));
    Im1Im2 = gather(gpuArray(Image_1).*gpuArray(Image_2));    
    %% 计算Image_1 * Image_k
    for k = -5:1:5
        if k < 0
            tmpImage = cat(3,zeros(ImgSize(1),ImgSize(2),abs(k)),Image_2(:,:,1:end + k));
            Image_k = gather(gpuArray(Image_k)) + gather(gpuArray(tmpImage));
        end
        if k > 0
            tmpImage = cat(3,Image_2(:,:,1 + k:end),zeros(ImgSize(1),ImgSize(2),abs(k)));
            Image_k = gather(gpuArray(Image_k)) + gather(gpuArray(tmpImage));
        end
    end
    Im1Imk = gather(gpuArray(Image_1).*gpuArray(Image_k));
    %% 计算a2 signal
    corr2result.A2stacks = gather(gpuArray(Im1Im2) - gpuArray(0.1 * R * Im1Imk));
    corr2result.sumA2stacks = zeros(width,height);
    corr2result.sumA2stacks(1+pattern(1,1):end-pattern(1,2),1+pattern(2,1):end-pattern(2,2)) = sum(corr2result.A2stacks,3);
    corr2result.intersumA2stacks = interpft2(corr2result.sumA2stacks,N);
    %% 计算g2 signal
    corr2result.G2stacks = gather(gpuArray(Im1Im2)./gpuArray(aveIm1Im2));
    corr2result.sumG2stacks = zeros(width,height);
    corr2result.sumG2stacks(1+pattern(1,1):end-pattern(1,2),1+pattern(2,1):end-pattern(2,2)) = mean(corr2result.G2stacks,3);
    corr2result.intersumG2stacks = interpft2(corr2result.sumG2stacks,N);        
end

