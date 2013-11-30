clear all; close all; clc;

% CONSTANTS
d = 2000;   % mirror -> fringe distance in mm
p_tilt = 20; % horizontal fringe spacing in mm
p_yaw = 20;  % vertical fringe spacing in mm
box = [100 310 1100 550];
scale = 0.09; % projected pixel size
imdir = './images/thin_flat/';
imdir_ref = './images/reference/';
flip = 0;

disp('generating reference response map');[response_ref, flat_ref] = response_map(imdir_ref,box);
disp('generating response map');[response, flat] = response_map(imdir_ref,box);

disp('loading v00R');v00ref = load_rescale(strcat(imdir_ref,num2str(p_yaw),'v00R.png'),box,response_ref,flat_ref);
disp('loading v90R');v90ref = load_rescale(strcat(imdir_ref,num2str(p_yaw),'v90R.png'),box,response_ref,flat_ref);
disp('loading v00');v00 = load_rescale(strcat(imdir,num2str(p_yaw),'v00.png'),box,response,flat);
disp('loading v90');v90 = load_rescale(strcat(imdir,num2str(p_yaw),'v90.png'),box,response,flat);

disp('generating vertical phasemap');
vphase_ref = unwrap(atan2(v00ref,v90ref)); % unwrap adds 2pi and looks for pi disconts
                                               % so multiply by two then divide after unwrapping
vphase = unwrap(atan2(v00,v90));
if(flip)
vphase_ref = unwrap(atan2(fliplr(v00ref),fliplr(v90ref))); % flip lr
vphase = unwrap(atan2(fliplr(v00),fliplr(v90)));
end

disp('loading h00R');h00ref = load_rescale(strcat(imdir_ref,num2str(p_tilt),'h00R.png'),box,response_ref,flat_ref);
disp('loading h90R');h90ref = load_rescale(strcat(imdir_ref,num2str(p_tilt),'h90R.png'),box,response_ref,flat_ref);
disp('loading h00');h00 = load_rescale(strcat(imdir,num2str(p_tilt),'h00.png'),box,response,flat);
disp('loading h90');h90 = load_rescale(strcat(imdir,num2str(p_tilt),'h90.png'),box,response,flat);

disp('generating horizontal phasemap');


hphase_ref = unwrap(atan2(h00ref,h90ref),[],2); % unwrap adds 2pi and looks for pi disconts
                                               % so multiply by two then divide after unwrapping
hphase = unwrap(atan2(h00,h90),[],2);
if(flip)
hphase_ref = unwrap(atan2(fliplr(h00ref),fliplr(h90ref)),[],2); % flip lr
hphase = unwrap(atan2(fliplr(h00),fliplr(h90)),[],2);
end

disp('done!')


% RECONSTRUCT SURFACE
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
disp('reconstructing surface...')

   tiltmatrix = (hphase_ref - hphase)*p_tilt/(2*d*pi);
   yawmatrix = (vphase_ref - vphase)*p_yaw/(2*d*pi);
   if(flip)
   tiltmatrix = (hphase - hphase_ref)*p_tilt/(2*d*pi);
   yawmatrix = (vphase - vphase_ref)*p_yaw/(2*d*pi);   
   end
     
   shape = size(tiltmatrix); ypix = [1:shape(2)]; xpix = [1:shape(1)];


   surfmatrix=zeros(shape);

   
   for x = [2:shape(1)] %first row
       surfmatrix(x,1)=surfmatrix(x-1,1)+yawmatrix(x-1,1)*scale;
   end
   
   for x = xpix
       for y = [2:shape(2)] % all columns
           surfmatrix(x,y) = surfmatrix(x,y-1) + tiltmatrix(x,y-1)*scale;
       end
   end
   surfmatrix = surfmatrix*1000; % convert to um
   
   % remove yaw,tilt,piston leaving only curvature
   tilt = polyval(polyfit(ypix,mean(surfmatrix,1),1),ypix);
   yaw = polyval(polyfit(xpix,mean(surfmatrix,2)',1),xpix);
   
   for x = xpix
       surfmatrix(x,:) = surfmatrix(x,:) - tilt;
   end
   for y = ypix
       surfmatrix(:,y) = surfmatrix(:,y) - yaw';
   end
   surfmatrix = surfmatrix - mean(surfmatrix(:));
   
   if(flip)
       surfmatrix = fliplr(surfmatrix);
   end
   
   imagesc(ypix*scale,xpix*scale,dither(surfmatrix));
   %daspect([1,1,1]);
   set (gca, "dataaspectratio", [1 0.5 1]);
   c=colorbar; ylabel(c,'Height (um)'); 
   xlabel('y (mm)');ylabel('x (mm)');
   
