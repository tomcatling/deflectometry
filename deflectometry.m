%clear all; close all; clc;
more off;

<<<<<<< HEAD
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
    
=======
>>>>>>> 2d54b00f43316af0098a9123a015c5a96eb6d5e9

    %%%%%
    %%%%% PARAMETERS
    
    
    imdir = 'images/thin/'
    spacing = 20
    
    d = 2000;   % mirror -> fringe distance in mm
    p_tilt = spacing; % horizontal fringe spacing in mm
    p_yaw = spacing;  % vertical fringe spacing in mm
    
    %box = [530 275 430 215]; % thin
    box = [700,410,300,100]; % slide2
    %box = [700,405,300,100]; % slide

    
    scale = 0.23; % projected pixel size

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
            % phase maps must be unwrapped in both directions after generation
            vphase_ref = unwrap(unwrap(atan2((v270ref - v90ref),(v00ref - v180ref))),[],2);
            vphase = unwrap(unwrap(atan2(v270 - v90,v00 - v180)),[],2);

            

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
            hphase_ref = unwrap(unwrap(atan2( (h270ref - h90ref),(h00ref - h180ref) ),[],2)); 
            hphase = unwrap(unwrap(atan2( (h270 - h90),(h00 - h180)),[],2));


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

       
