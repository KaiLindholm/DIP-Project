% Read the image
close all; 

I = imread('tags/target_tag_1.jpg');
imshow(I, [])

%%
figure("Name", "Gray Value Image")
% Convert to grayscale
grayImg = rgb2gray(I);
subplot(1,2,1);imshow(grayImg);
subplot(1,2,2); imshow(I, [])

%% Morphological operations (dilation and erosion)
input = grayImg;
se = strel('rectangle', [20 60]); % Define structuring element

figure("Name", "Opening")
Ie = imerode(input,se);
Iobr = imreconstruct(Ie,input);
imshow(Iobr)
title("Opening-by-Reconstruction")

figure("Name", "Opening-Closing")
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
Iobrcbr = histeq(Iobrcbr);
imshow(Iobrcbr)
title("Opening-Closing by Reconstruction")

se2 = strel('rectangle', [20 20]);
erode = imerode(Iobrcbr, se2);
erode = imdilate(erode, se2);

figure("Name", "Final erosion")
imshow(erode, [])

%%
input = erode; 
median = medfilt2(input, [50 5]); 
% finalImg = histeq(median);
finalImg = median > 218 & median < 256; 

figure("Name", "Median Filtering")
imshow(median, [])


figure("Name", "Thresholding")
imshow(finalImg, [])

%% Find and filter regionprops
input = finalImg;
stats = regionprops(input, 'Area', 'BoundingBox', 'Extent', 'Eccentricity', 'Circularity');
figure("Name", "Stats")
fields = fieldnames(stats); 
for i=1:numel(fields)
    statName = fields{i};
    subplot(1,numel(fields),i), histogram([stats.(statName)]);
    title(sprintf(statName))
end

aspectRatios = zeros(size(stats)); % Preallocate an array for aspect ratios
numRegions = size(stats, 1);

for k = 1:numRegions
    boundingBox = stats(k).BoundingBox; % Get the bounding box of each region
    width = boundingBox(3); % Width is the 3rd element of BoundingBox
    height = boundingBox(4); % Height is the 4th element of BoundingBox
    aspectRatios(k) = width / height; % Calculate aspect ratio
end             % find all aspect ratios 

% Filter Extent and Area 
areaThresLow = 10000; 
filteredRegions = stats([stats.Area] > areaThresLow); 

% We want the number of active pixels in the region to be high 
extentThres = 0.63; 
filteredRegions = filteredRegions([filteredRegions.Extent] > extentThres); 

% We want to allow for the 
eccThresh = 0.88;
filteredRegions = filteredRegions([filteredRegions.Eccentricity] > eccThresh);
circThres = 0.55; 
filteredRegions = filteredRegions([filteredRegions.Circularity] > circThres);

aspectRatiosFiltered = zeros(size(filteredRegions)); % Preallocate an array for aspect ratios
numRegions = size(aspectRatiosFiltered, 1);

for k = 1:numRegions
    boundingBox = filteredRegions(k).BoundingBox; % Get the bounding box of each region
    width = boundingBox(3); % Width is the 3rd element of BoundingBox
    height = boundingBox(4); % Height is the 4th element of BoundingBox
    aspectRatiosFiltered(k) = width / height; % Calculate aspect ratio
end    % find all aspect ratios 

% filter Aspect Ratios
highAspect = 2.75; 
lowAspect = 1.90;

aspectMask = aspectRatiosFiltered > lowAspect & aspectRatiosFiltered < highAspect; 
finalAR = aspectRatiosFiltered(aspectMask);
finalTags = filteredRegions(aspectMask);

%% Display Final borders
figure("Name", "Final Labeling")
imshow(input, []);
hold on;

regions = finalTags; 
aspects = finalAR; 
% store data for bounding boxes X1 Y1 and X2 Y2
points = zeros(size(regions,1), 6);

for i = 1:numel(regions)
    bb = regions(i).BoundingBox; 
    points(i, :) = [i, bb(1), bb(2), bb(1) + bb(3), bb(2) + bb(4), 1];
    AR = aspects(i);
    area = regions(i).Area;
    ext = regions(i).Extent;
    circ = regions(i).Circularity;
    ecc = regions(i).Eccentricity; 

    rectangle('Position', bb, 'EdgeColor', 'r', 'LineWidth', 2);

    fprintf("Aspect Ratio: %.2f\n"    + ...
                "Extent: %.2f\n"         + ...
                "Circularity: %0.2f\n"+ ...
                "Area: %0.2f\n" + ...
                "Eccentricity: %0.2f\n", AR, ext, circ, area, ecc);
    disp("---");
end
hold off 
fprintf("The number of tags: %d\n", numel(regions))
writematrix(points, 'g1_part2.csv')
