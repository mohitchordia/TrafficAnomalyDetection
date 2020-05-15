clear;
close all;

addpath(genpath('toolbox'))

thresh=15;
show = 1;

results=[];
vid=VideoReader('dataset.mp4');


frn=0; %frame number
numberOfFrames = vid.Duration * vid.FrameRate;
time=[];


% Load ROI and getting Mask
getROI = true;

detector = AcfDetector('C:\Users\Onam\Desktop\car-detection-tracking-master\car-detection-tracking-master\models\AUTCUP64-minds32Detector.mat');
tracker = MultiobjectKalmanTracker;


while(frn < numberOfFrames )
    % if frn > 30 * vid.FrameRate , break; end
    
    im=readFrame(vid);
    %im = imrotate(im,90);
    if(frn == 0)
        %delete detailResults.txt
        if(getROI == true)
            ROI = roipoly(im);
            save ROI ROI
        else
            load ROI
        end
    end
    %im=imresize(im,[size(im,1)*.4, size(im,2)*.4]);
    im(~repmat(ROI, [1, 1, 3])) = 0;
 
    bboxes = detector.detect(im);
    frn=frn+1;
    
    tracks = tracker.track(bboxes);
    tic;
    
    time(frn)=toc;
    if (show)
        positions=[];
        labels_str={};
        results=[];
        for j=1:size(tracks,2)
            if(tracks(j).totalVisibleCount > thresh)
                positions = [positions;tracks(j).bbox];
                labels_str{end+1}=num2str(tracks(j).id);
                
                % for saving in txt file, if it was inside the  ROI, It
                % would be written in txt file
                
                results = [results;[ frn, tracks(j).id, tracks(j).bbox(1:4)]];
                %    end
                
            end
        end
        
        %dlmwrite('detailResultsFull.txt',results,'-append');
        %im=insertObjectAnnotation(im,'rectangle',bboxes,ones(size(bboxes,1),1),'TextBoxOpacity',0.1,'FontSize',8,'Color','r');
        if length(positions)>0
            im=insertObjectAnnotation(im,'rectangle',positions,labels_str,'TextBoxOpacity',0.1,'FontSize',8);
        end
        imshow(im);
        %out_image=getframe(h);
        %writeVideo(vout,im);
        %pause(.0000001);
        %drawnow
        %hold on;
         %fill(xROI,yROI,'r','FaceAlpha',0.5);
        drawnow
        
        
    end
    clc;
    %    fprintf('Video Number = %d\n',video);
    fprintf('Progress = %.2f %%',frn*100/numberOfFrames);
end