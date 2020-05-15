classdef MultiobjectKalmanTracker < handle
    properties
        tracks
        nextId
    end
    
    methods
        function obj = MultiobjectKalmanTracker()
            obj.nextId = 0;
            obj.initializeTracks();
        end
        
        function tracks = track(obj, detections)
            obj.predictNewLocationsOfTracks();
            [assignments, unassignedTracks, unassignedDetections] = ...
                obj.detectionToTrackAssignment(detections);
            obj.updateAssignedTracks(detections, assignments);
            obj.updateUnassignedTracks(unassignedTracks);
            obj.deleteLostTracks();
            obj.createNewTracks(detections(unassignedDetections,:));
            obj.deleteInvalidTracks();
            tracks = obj.tracks;
        end
        
    end
    
    methods (Access = private)
        function initializeTracks(obj)
            % create an empty array of tracks
            obj.tracks = struct(...
                'id', {}, ...
                'bbox', {}, ...
                'kalmanFilter', {}, ...
                'age', {}, ...
                'totalVisibleCount', {}, ...
                'consecutiveInvisibleCount', {});
        end
        
        
        function tracks = predictNewLocationsOfTracks(obj)
            for i = 1:length(obj.tracks)
                %bbox = tracks(i).bbox;
                
                % Predict the current location of the track.
                predictedBbbox = predict(obj.tracks(i).kalmanFilter);
                
                % Shift the bounding box so that its center is at
                % the predicted location.
                %predictedCentroid = predictedCentroid - bbox(3:4) / 2;
                obj.tracks(i).bbox = predictedBbbox;
            end
            tracks = obj.tracks;
            
        end
        
        
        function [assignments, unassignedTracks, unassignedDetections] = ...
                detectionToTrackAssignment(obj, bboxes)
            
            nTracks = length(obj.tracks);
            nDetections = size(bboxes, 1);
            
            % Compute the cost of assigning each detection to each track.
            cost = zeros(nTracks, nDetections);
            for i = 1:nTracks
                for j=1:nDetections
                    cost(i,j)=-rectint(obj.tracks(i).bbox,bboxes(j,:))/ ...
                    sqrt(obj.tracks(i).bbox(3)*obj.tracks(i).bbox(4)* ...
                    bboxes(j,4)*bboxes(j,3));
                end
                %cost(i, :) = distance(tracks(i).kalmanFilter, centroids);
            end
            
            % Solve the assignment problem.
            costOfNonAssignment = -0.01;
            [assignments, unassignedTracks, unassignedDetections] = ...
                assignDetectionsToTracks(cost, costOfNonAssignment);
        end
        
        
        
        %% Update Assigned Tracks
        % The |updateAssignedTracks| function updates each assigned track with the
        % corresponding detection. It calls the |correct| method of
        % |vision.KalmanFilter| to correct the location estimate. Next, it stores
        % the new bounding box, and increases the age of the track and the total
        % visible count by 1. Finally, the function sets the invisible count to 0.
        
        function updateAssignedTracks(obj, bboxes, assignments)
            numAssignedTracks = size(assignments, 1);
            for i = 1:numAssignedTracks
                trackIdx = assignments(i, 1);
                detectionIdx = assignments(i, 2);
                %        centroid = centroids(detectionIdx, :);
                bbox = bboxes(detectionIdx, :);
                
                % Correct the estimate of the object's location
                % using the new detection.
                correct(obj.tracks(trackIdx).kalmanFilter, bbox);
                
                % Replace predicted bounding box with detected
                % bounding box.
                %tracks(trackIdx).bbox = bbox;
                
                % Update track's age.
                obj.tracks(trackIdx).age = obj.tracks(trackIdx).age + 1;
                
                % Update visibility.
                obj.tracks(trackIdx).totalVisibleCount = ...
                    obj.tracks(trackIdx).totalVisibleCount + 1;
                obj.tracks(trackIdx).consecutiveInvisibleCount = 0;
            end
        end
        
        %% Update Unassigned Tracks
        % Mark each unassigned track as invisible, and increase its age by 1.
        
        function updateUnassignedTracks(obj,unassignedTracks)
            for i = 1:length(unassignedTracks)
                ind = unassignedTracks(i);
                obj.tracks(ind).age = obj.tracks(ind).age + 1;
                obj.tracks(ind).consecutiveInvisibleCount = ...
                    obj.tracks(ind).consecutiveInvisibleCount + 1;
            end
        end
        
        %% Delete Lost Tracks
        % The |deleteLostTracks| function deletes tracks that have been invisible
        % for too many consecutive frames. It also deletes recently created tracks
        % that have been invisible for too many frames overall.
        
        function deleteLostTracks(obj)
            if isempty(obj.tracks)
                return;
            end
            
            invisibleForTooLong = 50;
            ageThreshold = 8;
            
            % Compute the fraction of the track's age for which it was visible.
            ages = [obj.tracks(:).age];
            totalVisibleCounts = [obj.tracks(:).totalVisibleCount];
            visibility = totalVisibleCounts ./ ages;
            
            % Find the indices of 'lost' tracks.
            lostInds = (ages < ageThreshold & visibility < 0.6) | ...
                [obj.tracks(:).consecutiveInvisibleCount] >= invisibleForTooLong;
            
            % Delete lost tracks.
            obj.tracks = obj.tracks(~lostInds);
        end
        
        
            
        function deleteInvalidTracks(obj)
            if isempty(obj.tracks)
                return;
            end    
            bboxes = reshape([obj.tracks(:).bbox]',4,length(obj.tracks))';
            heights = bboxes(:,4);
            widths = bboxes(:,3);
            
            validTracks = heights>0 & widths>0;
            obj.tracks = obj.tracks(validTracks);
        end
        
        %% Create New Tracks
        % Create new tracks from unassigned detections. Assume that any unassigned
        % detection is a start of a new track. In practice, you can use other cues
        % to eliminate noisy detections, such as size, location, or appearance.
        
        function createNewTracks(obj, bboxes)
            %    centroids = centroids(unassignedDetections, :);
            %bboxes = bboxes(unassignedDetections, :);
            
            for i = 1:size(bboxes, 1)
                
                %centroid = centroids(i,:);
                bbox = bboxes(i, :);
                
                % Create a Kalman filter object.
                %kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                %    bbox, [100, 100], [100 , 10], 1e5);
                
                StateTransitionModel=[1 0 0 0 1 0 0 0; ...
                    0 1 0 0 0 1 0 0; ...
                    0 0 1 0 0 0 1 0; ...
                    0 0 0 1 0 0 0 1; ...
                    0 0 0 0 1 0 0 0; ...
                    0 0 0 0 0 1 0 0; ...
                    0 0 0 0 0 0 1 0; ...
                    0 0 0 0 0 0 0 1];
                MeasurementModel= [1 0 0 0 0 0 0 0; ...
                    0 1 0 0 0 0 0 0; ...
                    0 0 1 0 0 0 0 0; ...
                    0 0 0 1 0 0 0 0];
                kalmanFilter=vision.KalmanFilter(StateTransitionModel,MeasurementModel);
                
                kalmanFilter.MeasurementNoise = [1e3 0 0 0; ...
                    0 1e3 0 0; ...
                    0 0 1e4 0; ...
                    0 0 0 1e4];
                kalmanFilter.State = [bbox 0 0 0 0];
                
                
                
                %  kalmanFilter = configureKalmanFilter('ConstantVelocity', ...
                %     centroid, [5, 5], [5, 5], 100);
                
                % Create a new track.
                newTrack = struct(...
                    'id', obj.nextId, ...
                    'bbox', bbox, ...
                    'kalmanFilter', kalmanFilter, ...
                    'age', 1, ...
                    'totalVisibleCount', 1, ...
                    'consecutiveInvisibleCount', 0);
                
                % Add it to the array of tracks.
                obj.tracks(end + 1) = newTrack;
                
                % Increment the next id.
                obj.nextId = obj.nextId + 1;
            end
        end
    
    end
end


