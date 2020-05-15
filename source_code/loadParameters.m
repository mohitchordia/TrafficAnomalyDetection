function params = loadParameters(paramId)

paramsCustom = strcat('C:\Users\Onam\Desktop\traffic-violation-detection-master\traffic-violation-detection-master\source_code\setup_params\', paramId,'.mat');
paramsDefault = 'C:\Users\Onam\Desktop\traffic-violation-detection-master\traffic-violation-detection-master\source_code\setup_params\default_params.mat';
try
    params = load(paramsCustom);
    fprintf('Loaded initial params from: %s \n', paramsCustom);
    
catch
    params = load(paramsDefault);
    fprintf('Could not load %s \nUsing %s instead\n', paramsCustom, paramsDefault);
end

end