function clipped = dither(array)
  
    neighbours(:,:,1) = circshift(array,[0,1]);
    neighbours(:,:,2) = circshift(array,[0,-1]);
    neighbours(:,:,3) = circshift(array,[1,0]);
    neighbours(:,:,4) = circshift(array,[-1,0]);
    neighbours(:,:,5) = circshift(array,[-1,-1]);
    neighbours(:,:,6) = circshift(array,[-1,1]);
    neighbours(:,:,7) = circshift(array,[1,-1]);
    neighbours(:,:,8) = circshift(array,[1,1]);
    array = median(neighbours,3);
    
    clipped = array;
    
end
