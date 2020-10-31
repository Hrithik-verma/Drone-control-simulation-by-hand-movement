clear all
sim=remApi('remoteApi');
sim.simxFinish(-1);
clientID=sim.simxStart('127.0.0.1',19999,true,true,5000,5);
vidObj = VideoReader('video1.mp4');
runloop = true;
area=100;
hf=figure('position',[0 0 eps eps],'menubar','none'); 
if (clientID>-1)
       disp('Connected to remote API server');
       [~,dum]= sim.simxGetObjectHandle(clientID,'Quadricopter_target',sim.simx_opmode_blocking);
       

    while(hasFrame(vidObj))
        x = readFrame(vidObj);
         x = flip(x ,2);           %# horizontal flip
        % Convert RGB image to chosen color space
        % Convert RGB image to chosen color space
    I = rgb2hsv(x);

    % Define thresholds for channel 1 based on histogram settings
    channel1Min = 0.002;
    channel1Max = 0.121;

    % Define thresholds for channel 2 based on histogram settings
    channel2Min = 0.395;
    channel2Max = 0.985;

    % Define thresholds for channel 3 based on histogram settings
    channel3Min = 0.399;
    channel3Max = 1.000;

    % Create mask based on chosen histogram thresholds
    sliderBW = (I(:,:,1) >= channel1Min ) & (I(:,:,1) <= channel1Max) & ...
        (I(:,:,2) >= channel2Min ) & (I(:,:,2) <= channel2Max) & ...
        (I(:,:,3) >= channel3Min ) & (I(:,:,3) <= channel3Max);
    BW = sliderBW;

        diskelem = strel('disk',5);
        Ibwopen = imopen(BW,diskelem);

        labeledImage = logical(Ibwopen);
        try
            measurements = regionprops(labeledImage, 'Centroid','Area');
            centroid = measurements.Centroid;
            cx=  ((centroid(1)-640)*0.001)*4;
            cy=  ((720-centroid(2))*0.001)*4;
            [returnCode]=sim.simxSetObjectPosition(clientID,dum,-1,[-cy cx 0.45],sim.simx_opmode_blocking);
            area = measurements.Area;
       
        catch Error
        
        end    
    
        if area>1500
            try
                ishape= insertShape(x,'FilledCircle',[centroid 5]);
                measurements = regionprops(labeledImage, 'BoundingBox');
                box = measurements.BoundingBox;
                ishape1= insertShape(ishape,'rectangle',box);
                p=[box(1) box(2)];
                RGB = insertText(ishape1,p,'Object','FontSize',18);
                J = imresize(RGB, 0.5);
                imshow(J)
            
            catch Error
        
            end
        else
            m = imresize(x, 0.5);
            imshow(m)
        
        end
        if strcmp(get(hf,'currentcharacter'),'q')
            
            close(hf)
        break
        end
    end
    clear cam1;
 sim.simxFinish(-1);
end 
sim.delete();