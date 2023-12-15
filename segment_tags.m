% Read the image
close all; 

I = imread('tags/ptag_b.png');
imshow(I, [])

%%
figure(1)
set(gcf, "Name", "Gray Value Image")
% Convert to grayscale
grayImg = rgb2gray(I);
subplot(1,2,1);imshow(grayImg);
subplot(1,2,2); imshow(I, [])

%% Morphological operations (dilation and erosion)
input = grayImg;
se = strel('rectangle', [20 60]); % Define structuring element

figure(2)
set(gcf, "Name", "Opening")
Ie = imerode(input,se);
Iobr = imreconstruct(Ie,input);
imshow(Iobr)
title("Opening-by-Reconstruction")

figure(3)
set(gcf, "Name", "Opening-Closing")
Iobrd = imdilate(Iobr,se);
Iobrcbr = imreconstruct(imcomplement(Iobrd),imcomplement(Iobr));
Iobrcbr = imcomplement(Iobrcbr);
Iobrcbr = histeq(Iobrcbr);
imshow(Iobrcbr)
title("Opening-Closing by Reconstruction")

se2 = strel('rectangle', [20 20]);
erode = imerode(Iobrcbr, se2);
erode = imdilate(erode, se2);

figure(4)
set(gcf, "Name", "Final erosion")
imshow(erode, [])

%%
input = erode; 
median = medfilt2(input, [50 5]); 
% finalImg = histeq(median);
finalImg = median > 218 & median < 256; 

figure(5)
set(gcf, "Name", "Median Filtering")
imshow(median, [])


figure(6)
set(gcf, "Name", "Thresholding")
imshow(finalImg, [])

%% Find and filter regionprops
input = finalImg;
stats = regionprops(input, 'Area', 'BoundingBox', 'Extent', 'Eccentricity', 'Circularity');
figure(7)
set(gcf, "Name", "Stats")
fields = fieldnames(stats); 
for i=1:numel(fields)
    statName = fields{i};
    subplot(1,numel(fields),i), histogram([stats.(statName)]);
    title(sprintf(statName))
end
close all

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
extentThres = 0.6; 
filteredRegions = filteredRegions([filteredRegions.Extent] > extentThres); 

% We want to allow for the 
eccThresh = 0.6;
filteredRegions = filteredRegions([filteredRegions.Eccentricity] > eccThresh);
circThres = 0.6; 
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

aspectMask1 = aspectRatiosFiltered > lowAspect & aspectRatiosFiltered < highAspect;



highAspect = 1.5; 
lowAspect = 0.8;


aspectMask2 = aspectRatiosFiltered > lowAspect & aspectRatiosFiltered < highAspect; 
if (size(aspectMask1, 1) > size(aspectMask2, 1))
    aspectMask = aspectMask1;
else
    aspectMask = aspectMask2;
end
finalAR = aspectRatiosFiltered(aspectMask);
finalTags = filteredRegions(aspectMask);

if aspectMask == aspectMask2
    filteredImg = uint8(input) .*grayImg;
    % filteredImg = histeq(filteredImg);

    h = fspecial("gaussian", [5 5], 2);
   
    top = filteredImg < 215 & filteredImg > 90;
    % top = uint8(top) .* grayImg;
    top = imfilter(top, h);
    top = medfilt2(top, [3 10]);
    top = bwareaopen(top, 200);
    top = imfill(top, "holes");

    bottom = filteredImg > 215;
    % bottom = uint8(bottom) .* grayImg;
    bottom = imfilter(bottom, h);
    bottom = medfilt2(bottom, [3 10]);
    bottom = bwareaopen(bottom, 200);
    bottom = imfill(bottom, "holes");

    stats_top = regionprops(top, "BoundingBox");
    stats_bottom = regionprops(bottom, "BoundingBox");

    imshow(I, []);
    hold on
    for k = 1:length(stats_top)
        thisBB = stats_top(k).BoundingBox;
        rectangle('Position', thisBB, ...
              'EdgeColor', 'g', 'LineWidth', 2);
    end

    for k = 1:length(stats_bottom)
        thisBB = stats_bottom(k).BoundingBox;
        rectangle('Position', thisBB, ...
              'EdgeColor', 'r', 'LineWidth', 2);
    end

    hold off

               
  

end

figure(8)
subplot(1,3,1)
imshow(filteredImg); impixelinfo
subplot(1,3,2); imshow(top); xlabel('top')
subplot(1,3,3); imshow(bottom); xlabel('bottom')



%% Display Final borders
figure(9)
set(gcf, "Name", "Final Labeling")
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
