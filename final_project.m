clc
close all
clear all

% RGB -> HSI
% figure
logs = imread('woodlogs_b.png');


hsv_logs = rgb2hsv(logs);
% imshow(hsv_logs, [])

figure
h = hsv_logs(:,:,1);
h = h < .10;

h = bwareaopen(h, 10000);


h = imfill(h, "holes");
h = uint8(h);
imshow(h, [])

s = hsv_logs(:,:,2);

s = s < 0.6;
% s = bwareafilt(s, [150000 200000]);
s = uint8(s);

figure
imshow(s, [])

logs_bw = h .* s;

figure
imshow(logs_bw, [])

edge_img = edge(logs_bw, "canny", [0.6, 0.9], 1.5); 

% [himage, t, r] = hough(edge_img, "Theta", 1, "RhoResolution", 1);
% 
% [himage, r] = imfindcircles(edge_img, [100 200]);
% viscircles(himage, r);

figure
imshow(edge_img, [])
figure, 
imshow(logs_bw - h, [])
%%
i
figure, 
[acc,T,R] = hough(edge_img, 'ThetaResolution', 0.75, 'RhoResolution', 0.75);
subplot(1,2,1)
imshow(log(acc+1), [], 'XData', T, 'YData', R, 'InitialMagnification','fit');
xlabel('\theta'), ylabel('\rho'); axis on, axis normal;

<<<<<<< Updated upstream
figure
% imshow(himage, [])




=======
P = houghpeaks(acc, 15, 'Threshold', 0.25*max(acc(:)) );
    
%%
figure
a = imread("circlesBrightDark.png");
imshow(a)
a = a < 100;
>>>>>>> Stashed changes

stats = regionprops('table',a,'Centroid', ...
                             'MajorAxisLength','MinorAxisLength');

% Get centers and radii of the circles
centers = stats.Centroid;
diameters = mean([stats.MajorAxisLength stats.MinorAxisLength],2);
radii = diameters/2;

% Plot the circles
hold on
viscircles(centers,radii);
hold off