classdef AcfDetector
    %ACFDETECTOR Detect Cars using acf detector
    %   Aggregated Channel Features
    
    properties
        detector
    end
    
    methods
        function obj = AcfDetector(modelAddress)
            model = load(modelAddress);
            obj.detector = model.detector;
        end
        
        function bboxes = detect(obj, image)
            bboxesWithScores = acfDetect(image, obj.detector);
            bboxes = bboxesWithScores(:,1:4);
        end
    end
    
end

