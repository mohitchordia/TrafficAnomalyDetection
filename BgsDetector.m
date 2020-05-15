classdef BgsDetector
    %BGSDETECTOR A object detector based on background subtraction
    %   This class detect add moving object in a movie
    
    properties
        bgs 
        blobAnalyser
    end
    
    methods
        % Constructor
        function obj = BgsDetector()
            obj.bgs = vision.ForegroundDetector(...
                'NumTrainingFrames', 100, ... % 5 because of short video
                'InitialVariance', 30*30, ...
                'LearningRate', .005); % initial standard deviation of 30
            obj.blobAnalyser = vision.BlobAnalysis(...
                'CentroidOutputPort', false, 'AreaOutputPort', false, ...
                'BoundingBoxOutputPort', true, ...
                'MinimumBlobAreaSource', 'Property', 'MinimumBlobArea', 250);
        end
        
        function bboxes = detect(obj, image)
            foreground = step(obj.bgs, image );
            bboxes   = step(obj.blobAnalyser, foreground);
            bboxes = double(bboxes);  
        end
        
    end
    
end

