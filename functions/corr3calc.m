function corr3result = corr3calc(pattern,tau1,tau2,H,S,N,Image)
%用于计算A2的值
%参考文献：dx.doi.org/10.1021/nl402552m | Nano Lett. 2013, 13, 5832−5836
%A2 = Image_1 * Image_2 - 0.1 * R * Image_1 * Image_k  
    %%
    height = size(Image,2);
    width = size(Image,1);
    
    Image_1 = Image(1+pattern(1,1):end-pattern(1,2),1+pattern(2,1):end-pattern(2,2),:);
    Image_2 = Image(1+pattern(3,1):end-pattern(3,2),1+pattern(4,1):end-pattern(4,2),:);
    Image_3 = Image(1+pattern(5,1):end-pattern(5,2),1+pattern(6,1):end-pattern(6,2),:);  
    
    ImgSize = size(Image_1);
    Image_p = zeros(ImgSize(1),ImgSize(2),ImgSize(3));
    Image_q = zeros(ImgSize(1),ImgSize(2),ImgSize(3));
    Image_1k = zeros(ImgSize(1),ImgSize(2),ImgSize(3));   
    Image_2k = zeros(ImgSize(1),ImgSize(2),ImgSize(3));   
    Image_3k = zeros(ImgSize(1),ImgSize(2),ImgSize(3));       
    %% 计算 Image_1 * Image_2 * Image_3
    if tau1 > 0
        Image_2 = Image_2(:,:,1 + tau1:end);
        Image_2 = cat(3,zeros(ImgSize(1),ImgSize(2),abs(tau1)),Image_2);           
    else
        Image_2 = Image_2(:,:,1:end + tau1);
        Image_2 = cat(3,Image_2,zeros(ImgSize(1),ImgSize(2),abs(tau1)));
    end
    
    if tau2 > 0
        Image_3 = Image_3(:,:,1 + tau2:end);
        Image_3 = cat(3,zeros(ImgSize(1),ImgSize(2),abs(tau2)),Image_3);           
    else
        Image_3 = Image_3(:,:,1:end + tau2);
        Image_3 = cat(3,Image_3,zeros(ImgSize(1),ImgSize(2),abs(tau2)));
    end
    
    aveIm1 = mean(Image_1,3);
    aveIm2 = mean(Image_2,3);
    aveIm3 = mean(Image_3,3);
    Im1Im2Im3 =  Image_1.* Image_2.* Image_3;    
    %% 计算Image_1 * Image_p * Image_q
    for p = -2:1:2
        if p < 0
            Image_p(:,:,1 - p:end) = Image_2(:,:,1:end + p);
        end
        if p > 0
            Image_p(:,:,1:end - p) = Image_2(:,:,1 + p:end);
        end
        
        for q = -2:1:2
            if ((p - q) ~= 0)&&((abs(p) + abs(q)) < 4)
                if q < 0
                    Image_q(:,:,1 - q:end) = Image_3(:,:,1:end + q);
                end
                if q > 0
                    Image_q(:,:,1:end - q) = Image_3(:,:,1 + q:end);
                end
            end
        end       
    end
    
    Im1ImpImq =  Image_1.* Image_p.* Image_q;
        %% 计算Image_1k*Image_2*Image_3 + Image_1*Image_2k*Image_3 + Image_1*Image_2*Image_3k
    for k = -5:1:5
        if k < 0
            Image_1k(:,:,1 - k:end) = Image_1(:,:,1:end + k);
            Image_2k(:,:,1 - k:end) = Image_2(:,:,1:end + k);
            Image_3k(:,:,1 - k:end) = Image_3(:,:,1:end + k);           
        end
        if k > 0
            Image_1k(:,:,1:end - k) = Image_1(:,:,1 + k:end);
            Image_2k(:,:,1:end - k) = Image_2(:,:,1 + k:end);
            Image_3k(:,:,1:end - k) = Image_3(:,:,1 + k:end);
        end
    end
    
    Im1kIm2kIm3k = Image_1k.*Image_2.*Image_3 + Image_1.*Image_2k.*Image_3 + Image_1.*Image_2.*Image_3k;
    %% 计算a2 signal
    corr3result.A3stacks =  -(Im1Im2Im3 + 0.2 * H * Im1ImpImq - 0.1 * S * Im1kIm2kIm3k);
    corr3result.sumA3stacks = zeros(width,height);
    corr3result.sumA3stacks(1+pattern(1,1):end-pattern(1,2),1+pattern(2,1):end-pattern(2,2)) = sum(corr3result.A3stacks,3);
    corr3result.intersumA3stacks = interpft2(corr3result.sumA3stacks,N);
    %% 计算g2 signal
    corr3result.G3stacks =  Im1Im2Im3 + 2.*aveIm1.*aveIm2.*aveIm3 -...
        (Image_1.*Image_2.*aveIm3 + Image_2.*Image_3.*aveIm1 + ...
        Image_1.*Image_3.*aveIm2);
    corr3result.sumG3stacks = zeros(width,height);
    corr3result.sumG3stacks(1+pattern(1,1):end-pattern(1,2),1+pattern(2,1):end-pattern(2,2)) = mean(corr3result.G3stacks,3);
    corr3result.intersumG3stacks = interpft2(corr3result.sumG3stacks,N);        
end

