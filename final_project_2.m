img = imread("ptag_b.png");

img_hsv = rgb2hsv(img);

% w = watershed(img, 4);

figure()
% imshow(w, [])

h = img_hsv(:,:,1);
s = img_hsv(:,:,2);
v = img_hsv(:,:,3);

img = rgb2gray(img);

imgc = imread("ptag_b.png");


figure(1)
subplot(2,2,1); xlabel("grayscale");
imshow(img);

r = imgc(:,:,1);
g = imgc(:,:,2);
b = imgc(:,:,3);

subplot(2,2,2); 
imshow(r); xlabel("red");

subplot(2,2,3)
imshow(g); xlabel("green");

subplot(2,2,4);
imshow(b); xlabel("blue");



% imshow(img);

impixelinfo

figure(2)
% img = histeq(img);
imhist(b); xlabel('blue')
% imshow(img); xlabel('histeq');


figure(3)
hi_img = b > 220 & b < 248;
mid_img = r > 160 & r < 220 & g > 160 & g < 210 & b > 160 & b < 210;


% hi_img = uint8(hi_img);
% hi_img = hi_img .* img;


% hi_img = medfilt2(hi_img, [5 10]);
% 
f = fspecial("gaussian", [10 10], 5);
hi_img = imfilter(hi_img, f, "same", "replicate");
% 
m = bwareaopen(hi_img, 1000);
hi_img = imfill(m, "holes");
% 
% 
% hi_img = bwareaopen(hi_img, 5000);
% hi_img = imfill(hi_img, "holes");


imshow(hi_img);
figure(4);
imshow(imgc)

figure(5)

% hi_img = uint8(hi_img);
% overlay = hi_img .*b;


% impixelinfo




% imshow(overlay);
%%

figure(6)
% mid_img = mid_img .* img;
subplot(1,2,1); imshow(mid_img)
f = fspecial("gaussian", [5 5], 5);
mid_img = imfilter(mid_img, f, "same", "replicate");
m = bwareaopen(mid_img, 500);
mid_img = imfill(m, "holes");
subplot(1,2,2); imshow(mid_img); xlabel('gray tags')
%%
figure(7)
imshow(imgc);
hold on
% 75 pixels x 218

props = regionprops(hi_img, 'BoundingBox');
props2 = regionprops(mid_img, 'BoundingBox');
for k = 1 : length(props)
    thisBB = props(k).BoundingBox;

    rectangle('Position', thisBB, 'EdgeColor', 'r', 'LineWidth', 2);
end

for j = 1 : length(props2)
    thisBB = props2(j).BoundingBox;

    rectangle('Position', thisBB, 'EdgeColor', 'g', 'LineWidth', 2);
end
hold off;

%%
% 
% figure(5)
% ptag = hi_img + mid_img;
% 
% imshow(ptag)

% figure(7)
% 
% imhist(r);
% figure(8)

% subplot(1,3,1); imshow(hue);
% subplot(1,3,2); imshow(s);
% subplot(1,3,3); imshow(v);

% s = s < 0.14;
% s = uint8(s);
% % s = regionprops(s, "BoundingBox");
% imshow(s)

% figure(9)

% both = s.*overlay;
% 
% imshow(both);



