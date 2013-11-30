function image = load_rescale(filename,box,response,flatfield)

image = double(imcrop2(imread(filename),box)); % load and crop
image = image./flatfield; % mult by flatfield (mostly amp noise)
image = (polyval(response,image) - 127)/127; % attempt return to digital (0-255) values and recentre on 0
disp('    dithering image');
image = dither(image); % dither image to remove hotpixels and some noise
image = image - mean(image(:)); % brute force recentre on 0, assuming range is roughly right by now

%image = image(2:end-1,2:end-1);

%image(find(image>1)) = 1;
%image(find(image<-1)) = -1;

end
