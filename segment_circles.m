close all; 
I = imread("woodlogs_b.png");

% figure("Name", "Original Image") 
% imshow(I, [])

R = I(:,:,1);
G = I(:,:,2);
B = I(:,:,3);

hsv = rgb2hsv(I);
h = hsv(:,:,1);
s = hsv(:,:,2);
v = hsv(:,:,3);

% figure("Name", "Input and its band")
% subplot(2,3,1), imshow(R, []);
% subplot(2,3,2), imshow(G, []);
% subplot(2,3,3), imshow(B, []);
% 
% subplot(2,3,4), imshow(h, []);
% subplot(2,3,5), imshow(s, []);
% subplot(2,3,6), imshow(v, []);

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

%% Filtering Step on 
figure("Name", "Median filter of Saturation") 
medS = v .* bgMask; 
medS = imgaussfilt(medS, 1.5, "FilterSize", [5 5]);
% medS = medS ./ max(medS(:));
imshow(medS, [])

figure("Name", "Saturation Histogram")
subplot(1,2,1); imhist(medS);
subplot(1,2,2); imshow(medS, [])

%% Morphological Techniques to mark foreground objects 
close all; 
input = histeq(medS);

figure, 
se = strel("disk", 30);
Ie = imerode(input,se);
Iobr = imreconstruct(Ie,input);
imshow(Iobr)
title("Opening-by-Reconstruction")

figure, 
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
imshow(Iobrcbr)
title("Opening-Closing by Reconstruction")

%%
filtered = imgaussfilt(Iobrd, 0.5, "FilterSize", [3 3]);
imshow(filtered, [])

%%
figure, 
bw = Iobrcbr > 0.63;
se2 = strel(ones(11, 11));
bw2 = imerode(bw,se2);

imshow(bw)
title("Thresholded Opening-Closing by Reconstruction")

%% Find circles
close all; 
input2 = bw; 
[c, r, metric] = imfindcircles(input2, [90 180], "ObjectPolarity", "bright", "Method", "TwoStage", "Sensitivity", 0.968);
fprintf("Preliminary Number of circles found %d\n", size(c, 1))

%%

strongMetric = metric > 0.033;
strongC = c(strongMetric, :);
strongR = r(strongMetric);

fprintf("Number of circles found %d\n", size(c, 1))

figure("Name", "Final Output")
imshow(I, [])
viscircles(strongC, strongR);
viscircles(c(~strongMetric, :), r(~strongMetric), "Color", "blue")

points = zeros(size(c,1), 4);
for i=1:size(c,1)
    points(i,:) = [i, c(i,:), r(i)];
end

writematrix(points, 'g1_part1.csv')
