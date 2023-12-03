img = imread("ptag_b.png");

img_hsv = rgb2hsv(img);

h = img_hsv(:,:,1);
s = img_hsv(:,:,2);
v = img_hsv(:,:,3);

figure(1)
subplot(1,3,1); imshow(h);
subplot(1,3,2); imshow(s);
subplot(1,3,3); imshow(v);

s = s < 0.10;