clc;
clear all;
close all;
inputvideo=vision.VideoFileReader('traffic.avi');
inputvideo1=VideoReader("traffic.avi");
nframes = inputvideo1.NumberOfFrames;
vid1=vision.VideoPlayer;
while~isDone(inputvideo)
 frame1=step(inputvideo);
 step(vid1,frame1);
 pause(0.1);
end
position =  [1 50];
 



ii = 1;
imwrite(frame1,'C:\Users\Onam\Desktop\final project\referenceimage.jpg','jpg');
release(inputvideo);
release(vid1);
referenceimage=imread('C:\Users\Onam\Desktop\final project\referenceimage.jpg');
vid2=vision.VideoFileReader('traffic.avi');
for i=2:nframes
clc
 frame=step(vid2);
 filename = [sprintf('%03d',ii) '.jpg'];
 fullname = fullfile('C:\Users\Onam\Desktop\final project\','imgs',filename);


 frame2=((im2double(frame))-(im2double(referenceimage)));
 
 imwrite(frame,fullname);

 frame1=im2bw(frame2,0.2);
 [labelimage]=bwlabel(frame1);
 stats=regionprops(labelimage,'basic');
 
 BB=stats.BoundingBox;
 X(i)=BB(1);
 Y(i)=BB(2);
 Dist=((X(i)-X(i-1))^2+(Y(i)-Y(i-1))^2)^(1/2)
 Z(i)=Dist;
 
 M=median(Z);
Speed=(Dist)*(120/18);

 if(Dist>10&&Dist<20)
 RGB = insertText(frame,position,'Medium Speed','AnchorPoint','LeftTop','BoxOpacity',0.0,'TextColor','yellow');
 fullname1 = fullfile('C:\Users\Onam\Desktop\final project\','spd',filename);

imwrite(RGB,fullname1);
 display('MEDIUM SPEED');
 
 elseif(Dist<10)
 RGB = insertText(frame,position,'Slow Speed','AnchorPoint','LeftTop','BoxOpacity',0.0,'TextColor','green');
 fullname1 = fullfile('C:\Users\Onam\Desktop\final project\','spd',filename);

imwrite(RGB,fullname1);
 display('SLOW SPEED');
 
 else
 RGB = insertText(frame,position,'Fast Speed','AnchorPoint','LeftTop','BoxOpacity',0.0,'TextColor','red');
 fullname1 = fullfile('C:\Users\Onam\Desktop\final project\','spd',filename);
 fullname2 = fullfile('C:\Users\Onam\Desktop\final project\','ovrspd',filename);
imwrite(RGB,fullname1);
imwrite(RGB,fullname2);
 display('FAST SPEED');
 end
 S=strel('disk',6);
 frame3=imclose(frame1,S);
 step(vid1,frame1);
 pause(0.005);
 
 ii = ii+1;
end

 M=median(Z);
Speed=(M)*(120/8);
 
release(vid1)


imageNames = dir(fullfile('C:\Users\Onam\Desktop\final project\','spd','*.jpg'));
imageNames = {imageNames.name}';

outputVideo = VideoWriter(fullfile('C:\Users\Onam\Desktop\final project\','output.avi'));
outputVideo.FrameRate = inputvideo1.FrameRate;
open(outputVideo)

for ii = 1:length(imageNames)
   img = imread(fullfile('C:\Users\Onam\Desktop\final project\','spd',imageNames{ii}));
   writeVideo(outputVideo,img)
end

close(outputVideo)

shuttleAvi = VideoReader(fullfile('C:\Users\Onam\Desktop\final project\','output.avi'));
ii = 1;
while hasFrame(shuttleAvi)
   mov(ii) = im2frame(readFrame(shuttleAvi));
   ii = ii+1;
end

videoFReader = vision.VideoFileReader('C:\Users\Onam\Desktop\final project\output.avi');
videoPlayer = vision.VideoPlayer;
while ~isDone(videoFReader)
  videoFrame = videoFReader();
  videoPlayer(videoFrame);
  pause(0.1)
end
release(videoPlayer);
release(videoFReader);
trafficVid = VideoReader('C:\Users\Onam\Desktop\final project\output.avi')

get(trafficVid)

%implay('traffic.mj2');


darkCarValue = 75;
darkCar = rgb2gray(read(trafficVid,71));
noDarkCar = imextendedmax(darkCar, darkCarValue);
imshow(darkCar)
figure, imshow(noDarkCar)


sedisk = strel('disk',2);
noSmallStructures = imopen(noDarkCar, sedisk);
imshow(noSmallStructures)

nframes = trafficVid.NumberOfFrames;
I = read(trafficVid, 1);
taggedCars = zeros([size(I,1) size(I,2) 3 nframes], class(I));

for k = 1 : nframes
    singleFrame = read(trafficVid, k);
    
    % Convert to grayscale to do morphological processing.
    I = rgb2gray(singleFrame);
    
    % Remove dark cars.
    noDarkCars = imextendedmax(I, darkCarValue); 
    
    % Remove lane markings and other non-disk shaped structures.
    noSmallStructures = imopen(noDarkCars, sedisk);

    % Remove small structures.
    noSmallStructures = bwareaopen(noSmallStructures, 150);
   
    % Get the area and centroid of each remaining object in the frame. The
    % object with the largest area is the light-colored car.  Create a copy
    % of the original frame and tag the car by changing the centroid pixel
    % value to red.
    taggedCars(:,:,:,k) = singleFrame;
   
    stats = regionprops(noSmallStructures, {'Centroid','Area'});
    if ~isempty([stats.Area])
        areaArray = [stats.Area];
        [junk,idx] = max(areaArray);
        c = stats(idx).Centroid;
        c = floor(fliplr(c));
        width = 2;
        row = c(1)-width:c(1)+width;
        col = c(2)-width:c(2)+width;
        taggedCars(row,col,1,k) = 255;
        taggedCars(row,col,2,k) = 0;
        taggedCars(row,col,3,k) = 0;
    end
end

frameRate = trafficVid.FrameRate;
implay(taggedCars,frameRate);
extract2('Demo_d.jpg',4);
%extract('Demo_d.jpg');
businessCard   = imread('C:\Users\Onam\Desktop\final project\lpimg.jpg');
     ocrResults     = ocr(businessCard)
     recognizedText = ocrResults.Text;    
     figure;
     imshow(businessCard);
     imwrite(businessCard,'C:\Users\Onam\Desktop\final project\lpimg1.jpg','jpg')
     text(600, 150, recognizedText, 'BackgroundColor', [1 1 1]);
     fid = fopen('C:\Users\Onam\Desktop\final project\noPlate.txt', 'wt'); % This portion of code writes the number plate
    fprintf(fid,'%s\n',recognizedText);      % to the text file, if executed a notepad file with the
    fclose(fid);                      % name noPlate.txt will be open with the number plate written.
    winopen('C:\Users\Onam\Desktop\final project\noPlate.txt')


