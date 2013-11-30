function [response, flat] = response_map(imdir,box)
% maps the response from several calibration frames using polyfit
% pixel values can be reclaimed using polyval, the rescaled from 0:255 to -1:1

      
            calib0 = double(imcrop2(imread(strcat(imdir,'c0.png')),box));
        c0 = median(calib0(:));
            calib25 = double(imcrop2(imread(strcat(imdir,'c25.png')),box));
        c25 = median(calib25(:));
            calib50 = double(imcrop2(imread(strcat(imdir,'c50.png')),box));
        c50 = median(calib50(:));
            calib75 = double(imcrop2(imread(strcat(imdir,'c75.png')),box));
        c75 = median(calib75(:));
            calib100 = double(imcrop2(imread(strcat(imdir,'c100.png')),box));
        c100 = median(calib100(:));
            calib125 = double(imcrop2(imread(strcat(imdir,'c125.png')),box));
        c125 = median(calib125(:));
            calib150 = double(imcrop2(imread(strcat(imdir,'c150.png')),box));
        c150 = median(calib150(:));
            calib175 = double(imcrop2(imread(strcat(imdir,'c175.png')),box));
        c175 = median(calib175(:));
            calib200 = double(imcrop2(imread(strcat(imdir,'c200.png')),box));
        c200 = median(calib200(:));
            calib225 = double(imcrop2(imread(strcat(imdir,'c225.png')),box));
        c225 = median(calib225(:));
            calib250 = double(imcrop2(imread(strcat(imdir,'c250.png')),box));
        c250 = median(calib250(:));
                
        
        flat = dither(calib100)/c100; % dither flatfield to remove hotpixels
        flat = flat./mean(flat(:)); % make sure it does not amplify image
    
        levels = [0,25,50,75,100,125,150,175,200,225,250];
        response_values = [c0,c25,c50,c75,c100,c125,c150,c175,c200,c225,c250];
        
        response = polyfit(response_values,levels,3); % fit digital levels as a function of response value

end
