function img = imcrop2(img,box)

img = double(img(box(2):box(2)+box(4)-1,box(1):box(1)+box(3)-1));

end
