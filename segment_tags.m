% Read the image
close all; 

I = imread('tags/target_tag_7.jpg');
I = imrotate(I, -90);
imshow(I, [])
%%
figure, 
% Convert to grayscale
grayImg = rgb2gray(I);
enhancedImg = histeq(grayImg);
subplot(1,2,1); imshow(grayImg);
subplot(1,2,2); imshow(enhancedImg);

% % Thresholding
% binaryImg = imbinarize(enhancedImg);
% figure, imshow(binaryImg)

%% Morphological operations (dilation and erosion)
input = enhancedImg;
se = strel('rectangle', [20 60]); % Define structuring element

figure, 
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

% figure, 
% fgm = imregionalmax(Iobrcbr, 8);
% imshow(fgm)
% title("Regional Maxima of Opening-Closing by Reconstruction")
% 
% 
% figure, 
% I2 = labeloverlay(input,fgm);
% imshow(I2)
% title("Regional Maxima Superimposed on Original Image")

% dilatedImg = imdilate(enhancedImg, se);
% finalImg = imerode(enhancedImg, se);

%%
input = Iobrcbr; 

% finalImg = histeq(input);
figure, 
subplot(1,2,1), imshow(input, [])

finalImg = input > 218  & input < 255; 

subplot(1,2,2); imshow(finalImg, [])

%%
input = logical(finalImg);
stats = regionprops(input, 'Area', 'BoundingBox', 'Extent');


extentThres = 0.45;
areaThres = 500; 
filteredRegions = stats([stats.Extent] > extentThres);
filteredRegions = filteredRegions([filteredRegions.Area] > areaThres);

aspectRatios = zeros(size(filteredRegions)); % Preallocate an array for aspect ratios
numRegions = size(aspectRatios, 1);

for k = 1:numRegions
    boundingBox = filteredRegions(k).BoundingBox; % Get the bounding box of each region
    width = boundingBox(3); % Width is the 3rd element of BoundingBox
    height = boundingBox(4); % Height is the 4th element of BoundingBox
    aspectRatios(k) = width / height; % Calculate aspect ratio
end

highAspect = 8; 
lowAspect = 1.5;

aspectMask = aspectRatios > lowAspect & aspectRatios < highAspect; 
finalTags = filteredRegions(aspectMask);
figure, 
histogram(aspectMask);

finalTags = finalTags([finalTags.Extent] > extentThres);
figure, 
histogram([finalTags.Extent])

%%
% Filter regions based on properties (e.g., area)

% Extract or overlay bounding boxes on original image
figure, 
imshow(I, []);
hold on;
for i = 1:numel(finalTags)
    rectangle('Position', finalTags(i).BoundingBox, 'EdgeColor', 'r', 'LineWidth', 2);
    fprintf("Aspect Ratio: %.2f\t Area: %d\n Extent: %.2f\n", aspectRatios(i), finalTags(i).Area, finalTags(i).Extent)
    pause
end