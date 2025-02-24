clc
clear 
close all
%%
% tested for
% 'video_data_sunday/IMG_5108.mov'
% 'video_data_sunday/IMG_6914.mov' P1&P3
% 'video_data_sunday/IMG_6919.mov'
% 'video_data_sunday/IMG_6915_01.mov'
% 'video_data_sunday/IMG_6917_01.mov' the turn: p1 bbox "jumps" on the p2 box (which disappears)
%%


videoPath = 'C:\Users\Onam\Desktop\final project\source_code\video_data_sunday\IMG_6919.mov';
videoId = getVideoId(videoPath); % this is just the IMG_6919 part of the videoPath
default_params =  loadParameters('default_params');
custom_params = loadParameters(videoId);
params = setstructfields(default_params, custom_params);
car_tracking(videoPath, params);
