function [acc, yDetect, xDetect, rDetect] = circlehough(BW, radii, thres)
    % define the range of parameters for a circle the geometric equation is
    % (x-a)^2 + (y-b)^2 = r^2 
    % This defines the parameter space, where the accumulator will be an 3
    % dimentions for each feature we are extracting 

    % Given the edge image, determine all pixels that are apart of the edge
    % image. and then for each edge pixel iterate through the given radii
    % determine a possible center for that pixel
    % for each of those centers update the accumulator 

    % Once complete, threshold the acc to remove noisy responces
    % Then we can find peaks based off a given threshold value 

    % then return a list of all detections along with the acc

    


end