boxImage = imresize(rgb2gray(imread('object.jpg')), 0.5);
figure;
subplot(2,2,1);
imshow(boxImage);
title('Object Image');

sceneImage = imresize(rgb2gray(imread('TestImage.jpg')), 0.5);
subplot(2,2,2);
imshow(sceneImage);
title('Image of a Cluttered Scene');

boxPoints = detectSURFFeatures(boxImage);
scenePoints = detectSURFFeatures(sceneImage);

%{
figure;
imshow(boxImage);
title('100 Strongest Feature Points from Object Image');
hold on;
plot(selectStrongest(boxPoints, 100));
%}

%figure;
%imshow(sceneImage);
%title('300 Strongest Feature Points from Scene Image');
%hold on;
%plot(selectStrongest(scenePoints, 300));

[boxFeatures, boxPoints] = extractFeatures(boxImage, boxPoints);
[sceneFeatures, scenePoints] = extractFeatures(sceneImage, scenePoints);

boxPairs = matchFeatures(boxFeatures, sceneFeatures);

matchedBoxPoints = boxPoints(boxPairs(:, 1), :);
matchedScenePoints = scenePoints(boxPairs(:, 2), :);
%figure;
%showMatchedFeatures(boxImage, sceneImage, matchedBoxPoints, ...
%    matchedScenePoints, 'montage');
%title('Putatively Matched Points (Including Outliers)');

[tform, inlierBoxPoints, inlierScenePoints] = ...
    estimateGeometricTransform(matchedBoxPoints, matchedScenePoints, 'affine');

subplot(2,2,3);
showMatchedFeatures(boxImage, sceneImage, inlierBoxPoints, ...
    inlierScenePoints, 'montage');
title('Matched Points (Inliers Only)');

boxPolygon = [1, 1;...                           % top-left
        size(boxImage, 2), 1;...                 % top-right
        size(boxImage, 2), size(boxImage, 1);... % bottom-right
        1, size(boxImage, 1);...                 % bottom-left
        1, 1];                   % top-left again to close the polygon

newBoxPolygon = transformPointsForward(tform, boxPolygon);

subplot(2,2,4);
imshow(sceneImage);
hold on;
line(newBoxPolygon(:, 1), newBoxPolygon(:, 2), 'Color', 'y');
title('Detected Object');