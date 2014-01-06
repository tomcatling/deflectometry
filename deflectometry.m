clear all; close all; clc;
more off;

    imdir = 'images/new/100/'
    spacing = 3

    if(0)
        if size(argv()) != 2
            disp('Need to supply test directory and fringe spacing')
            quit()
        end


        if argv(){1}(end) != '/'
            disp('Expecting a directory ending in / for first argument')
            quit()
        end

        % directory of test optic images
        imdir = argv(){1}
        spacing = str2num(argv(){2})
    end
    

    %%%%%
    %%%%% CONSTANTS
    
    d = 2000;   % mirror -> fringe distance in mm
    p_tilt = spacing; % horizontal fringe spacing in mm
    p_yaw = spacing;  % vertical fringe spacing in mm
    
    %box = [530 275 430 215]; % thin
    box = [700,410,300,100]; % slide2
    %box = [700,405,300,100]; % slide

    
    scale = 0.23; % projected pixel size
    %imdir = './images/thin_flat/';
    imdir_ref = './images/reference/';

    % get response map for reference and test surface
    % maps how displayed intensities converted to detector readings
    disp('Generating reference response map');[response_ref, flat_ref] = response_map(imdir_ref,box);
    disp('Generating response map');[response, flat] = response_map(imdir_ref,box);


    %%%%%
    %%%%% VERTICAL FRINGES
        
            % load reference fringes
            disp('Loading vertical fringes');
            v00ref = load_rescale(strcat(imdir_ref,num2str(p_yaw),'v00.png'),box,response_ref,flat_ref);
            v90ref = load_rescale(strcat(imdir_ref,num2str(p_yaw),'v90.png'),box,response_ref,flat_ref);
            v180ref = load_rescale(strcat(imdir_ref,num2str(p_yaw),'v180.png'),box,response_ref,flat_ref);
            v270ref = load_rescale(strcat(imdir_ref,num2str(p_yaw),'v270.png'),box,response_ref,flat_ref);


            % load test fringes
            v00 = load_rescale(strcat(imdir,num2str(p_yaw),'v00.png'),box,response,flat);
            v90 = load_rescale(strcat(imdir,num2str(p_yaw),'v90.png'),box,response,flat);
            v180 = load_rescale(strcat(imdir,num2str(p_yaw),'v180.png'),box,response,flat);
            v270 = load_rescale(strcat(imdir,num2str(p_yaw),'v270.png'),box,response,flat);    
            
            % generate test and reference phasemaps using 4 step algorithm
            disp('Generating vertical phasemap');
            vphase_ref = unwrap(atan2((v270ref - v90ref),(v00ref - v180ref)));
            for i = 2:size(vphase_ref)(2)
                if ( abs(mean(vphase_ref(3:5,i),1) - mean(vphase_ref(3:5,i-1),1)) > pi)
                    vphase_ref(:,i) = vphase_ref(:,i)-2*pi*sign(vphase_ref(1,i) - vphase_ref(1,i-1));
                end
            end
            %vphase_ref = unwrap(atan2(v00ref,v90ref));
            vphase = unwrap(atan2(v270 - v90,v00 - v180));
            for i = 2:size(vphase)(2)
                if ( abs(mean(vphase(3:5,i),1) - mean(vphase(3:5,i-1),1)) > pi)
                    vphase(:,i) = vphase(:,i)-2*pi*sign(vphase(1,i) - vphase(1,i-1));
                end
            end
            %vphase = unwrap(atan2(v00,v90));
            

    %%%%%
    %%%%% HORIZONTAL FRINGES
            
            % repeat all of above
            disp('Loading horizontal fringes');
            h00ref = load_rescale(strcat(imdir_ref,num2str(p_tilt),'h00.png'),box,response_ref,flat_ref);
            h90ref = load_rescale(strcat(imdir_ref,num2str(p_tilt),'h90.png'),box,response_ref,flat_ref);
            h180ref = load_rescale(strcat(imdir_ref,num2str(p_tilt),'h180.png'),box,response_ref,flat_ref);
            h270ref = load_rescale(strcat(imdir_ref,num2str(p_tilt),'h270.png'),box,response_ref,flat_ref);    
            h00 = load_rescale(strcat(imdir,num2str(p_tilt),'h00.png'),box,response,flat);
            h90 = load_rescale(strcat(imdir,num2str(p_tilt),'h90.png'),box,response,flat);
            h180 = load_rescale(strcat(imdir,num2str(p_tilt),'h180.png'),box,response,flat);
            h270 = load_rescale(strcat(imdir,num2str(p_tilt),'h270.png'),box,response,flat);
            disp('Generating horizontal phasemap');
            hphase_ref = unwrap(atan2( (h270ref - h90ref),(h00ref - h180ref) ),[],2);
            for i = 2:size(hphase_ref)(1)
                if ( abs(mean(hphase_ref(i,3:5),2) - mean(hphase_ref(i-1,3:5),2)) > pi)
                    hphase_ref(i,:) = hphase_ref(i,:)-2*pi*sign(hphase_ref(i,1) - hphase_ref(i-1,1));
                end
            end
            %hphase_ref = unwrap(atan2(h00ref,h90ref),[],2); 
            hphase = unwrap(atan2( (h270 - h90),(h00 - h180)),[],2);
            for i = 2:size(hphase)(1)
                if ( abs(mean(hphase(i,3:5),2) - mean(hphase(i-1,3:5),2)) > pi)
                    hphase(i,:) = hphase(i,:)-2*pi*sign(hphase(i,1) - hphase(i-1,1));
                end
            end
            %hphase = unwrap(atan2(h00,h90),[],2);


    %%%%%
    %%%%% RECONSTRUCT SURFACE
    
           disp('Finding surface normals')
           % construct angle matrices based upon phase differences
           tiltmatrix = (hphase_ref - hphase)*p_tilt/(2*d*pi);
           yawmatrix  = (vphase_ref - vphase)*p_yaw/(2*d*pi);

           shape = size(tiltmatrix);ypix = [1:shape(2)]; xpix = [1:shape(1)];
           
           disp('Reconstructing surface... this may take a while');
           surfmatrix2 = surface_reconstruction(tiltmatrix,yawmatrix,scale);
           disp('...done!');
           
           imagesc(ypix*scale,xpix*scale,dither(surfmatrix2));
           set (gca, "dataaspectratio", [1 shape(1)/shape(2) 1]);
           c=colorbar; ylabel(c,'Height (um)'); 
           xlabel('y (mm)');ylabel('x (mm)');
           disp('Saving image');
           print('output.png');

       
