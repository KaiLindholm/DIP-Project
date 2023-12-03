img = imread("ptag_b.png");

img = rgb2gray(img);

figure(1)

imshow(img);
impixelinfo

figure(2)
histeq(img);
imhist(img);

figure(3)
hi_img = img > 230 & img < 248;
mid_img = img > 180 & img < 220;

% hi_img = uint8(hi_img);
% hi_img = hi_img .* img;

% h = fspecial("gaussian", [5 5], 10);
% hi_img = imfilter(hi_img, h, "same", "replicate");


hi_img = medfilt2(hi_img, [5 10]);
hi_img = bwareaopen(hi_img, 1000, 4);

imshow(hi_img);



% figure(4)
% mid_img = uint8(mid_img);
% mid_img = mid_img .* img;
% imshow(mid_img)
% 
% figure(5)
% ptag = hi_img + mid_img;
% 
% imshow(ptag)
