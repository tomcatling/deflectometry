function clipped = sigma_clip(array)

  
    neighbours(:,:,1) = circshift(array,[0,1]);
    neighbours(:,:,2) = circshift(array,[0,-1]);
    neighbours(:,:,3) = circshift(array,[1,0]);
    neighbours(:,:,4) = circshift(array,[-1,0]);
    array = median(neighbours,3);
    

    if(0)

    length(bad)
    [i,j] = ind2sub(size(array),bad);
    array(i,j) = median(neighbours(i,j,:),3);
    
    avg = mean(array(:));
    dev = std(array(:)); 
    
    bad = find(abs(array - avg) > dev*3);
    [i,j] = ind2sub(size(array),bad);
    
    while length(bad) > 1
   
        array(i,j) = median(neighbours(i,j,:),3);
        bad = find(abs(array - avg) > dev*3);
    
    end    
    end
    
    clipped = array;
    
end