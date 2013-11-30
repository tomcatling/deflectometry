% we start in the 'bottom left' and 'top right' corners
% tilt and yaw are given in this frame of reference
% i.e. tilt is gradient in dim 1 and yaw in dim 2
function surfmatrix = surface_reconstruction(yaw,tilt,scale)

shape = size(tilt);ypix = [1:shape(2)]; xpix = [1:shape(1)];


%%% FIRST PASS
        height1 = zeros(shape);
        height1(1,1) = 1;

        % generate sides
        for i = 2:shape(1)
            height1(i,1) = height1(i-1,1) + tilt(i-1,1);
        end
        for j = 2:shape(2)
            height1(1,j) = height1(1,j-1) + yaw(1,j-1);
        end

        % vertical reconstruction
        for j = 1:shape(2)-1
            for i = 1:shape(1)-1
                height1(i+1,j+1) = 0.5*(height1(i,j+1) + height1(i+1,j)) + 0.25*( tilt(i,j+1) + tilt(i+1,j+1) + yaw(i+1,j) + yaw(i+1,j+1));
            end
        end

%%% SECOND PASS
        height2 = zeros(shape);
        height2(end,end) = 1;

        % generate sides
        for i = shape(1):-1:2
            height2(i-1,end) = height2(i,end) - tilt(i,end);
        end

        for j = shape(2):-1:2
            height2(end,j-1) = height2(end,j) - yaw(end,j);
        end
        
        % horizontal reconstruction
        for i = shape(1):-1:2
            for j = shape(2):-1:2
                height2(i-1,j-1) = 0.5*(height2(i-1,j) + height2(i,j-1)) - 0.25*(tilt(i-1,j) + tilt(i,j) + yaw(i,j-1) + yaw(i,j));
            end
        end
        
% now take the average
        surfmatrix = 1000*scale*0.5*(height1 + height2);
        
           % remove yaw,tilt and piston
           tilt = polyval(polyfit(ypix,mean(surfmatrix,1),1),ypix);
           yaw = polyval(polyfit(xpix,mean(surfmatrix,2)',1),xpix);
           
           for x = xpix
               surfmatrix(x,:) = surfmatrix(x,:) - tilt;
           end
           for y = ypix
               surfmatrix(:,y) = surfmatrix(:,y) - yaw';
           end
           surfmatrix = surfmatrix - mean(surfmatrix(:));
           
