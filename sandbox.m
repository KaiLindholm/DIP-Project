close all; 
I = imread("woodlogs_b.png");
figure("Name", "Original Image") 
imshow(I, [])
R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

hsv = rgb2hsv(I);
h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);
% 
% figure("Name", "Input and its band")
% subplot(2,3,1), imshow(R, []);
% subplot(2,3,2), imshow(G, []);
% subplot(2,3,3), imshow(B, []);
% 
% subplot(2,3,4), imshow(h, []);
% subplot(2,3,5), imshow(s, []);
% subplot(2,3,6), imshow(v, []);
% 
%% Find where the background pixels are located 
backgroundThresh = 0.10; 

bgMask = h < backgroundThresh;
bgMask = bwareaopen(bgMask, 10000);
figure("Name", "Image background mask")
imshow(bgMask, [])
bgMask = imdilate(bgMask, strel('disk',5));
bgMask = imfill(bgMask, "holes");

figure("Name", "Fill Holes in Mask")
imshow(bgMask, [])

%% Perform a median filter on s
figure("Name", "Median filter of Saturation") 
medS = s .* bgMask; 
medS = imgaussfilt(medS, 5);
medS = medfilt2(medS, [5 5]);
medS = medS ./ max(medS(:));
imshow(medS, [])

figure("Name", "Saturation Histogram")
subplot(1,2,1); imhist(medS, 20);
subplot(1,2,2); imshow(medS, [])

%% Remove high saturation regions
close all; 
input = medS;
test = imhmin(input, 0.40, 4);
figure, 
imshow(test, [])

log_faces_mask = test < 0.76 & test > 0.40;
figure("Name", "Log Faces Mask")
imshowpair(log_faces_mask, test, 'montage')
figure("Name", "Clean up mask")
% cleanup = imerode(log_faces_mask, strel('disk', 10, 8));
% cleanup = bwmorph(log_faces_mask, 'majority', Inf);
cleanup = bwmorph(log_faces_mask, "close", 10);

imshow(cleanup, [])

%% Apply distance transform on faces 
close all; 
input = cleanup; 
D = bwdist(~input);
figure("Name", "Distance Transform")
subplot(1,2,1); imshow(D, []), title("Distance Transform")
D = -D; 
subplot(1,2,2); imshow(D, []), title("Compliment of Distance Transform")

labels = watershed(D);
labels(~input) = 0; 

mask = labels > 0; 
figure("Name", "Gray Labels")
imshow(mask, []), title("Labels")

figure, 
imshow(mask, [])

%% Edges
border = edge(cleanupMask, "canny", [0.5 0.9], 1.5);
figure, 
imshow(border, [])

%% Find circles in 
close all; 
input = mask; 
[c, r, metric] = imfindcircles(input, [90 170], "Method", "TwoStage", "Sensitivity", 0.96);


%% PostProcessing
strongMetric = metric > 0.05;
c = c(strongMetric, :);
r = r(strongMetric);

circs = size(c, 1);
fprintf("Number of circles found %d\n", circs)
figure("Name", "Final Output")
imshow(input, [])
viscircles(c, r);