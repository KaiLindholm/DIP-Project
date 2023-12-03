img = imread("ptag_b.png");

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
img = b;
imhist(img);
% imshow(img); xlabel('histeq');


figure(3)
hi_img = b > 220 & b < 248;
mid_img = r > 180 & r < 200;

% hi_img = uint8(hi_img);
% hi_img = hi_img .* img;


% hi_img = medfilt2(hi_img, [5 10]);
% 
h = fspecial("gaussian", [10 10], 5);
hi_img = imfilter(hi_img, h, "same", "replicate");
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

hi_img = uint8(hi_img);
overlay = hi_img .*b;

imshow(overlay);

% figure(4)
% mid_img = uint8(mid_img);
% mid_img = mid_img .* img;
% imshow(mid_img)
% 
% figure(5)
% ptag = hi_img + mid_img;
% 
% imshow(ptag)
