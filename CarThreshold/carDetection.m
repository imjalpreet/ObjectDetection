%% Detecting Cars in a Video
% Currently, I have written the code for only detecting light coloured cars. 

%% Read the video file
videoTraffic = VideoReader('traffic.mj2');

% Get more information on the video like the number of frames.
get(videoTraffic)

%% Eliminate dark cars from a single frame

% Threshold value for removing the dark cars
darkCarThreshold = 50;

% 75th Frame with dark cars visible
darkCarVisible = rgb2gray(read(videoTraffic,75));

% 75th Frame with dark cars not visible
noDarkCarVisible = imextendedmax(darkCarVisible, darkCarThreshold);

figure, imshow(darkCarVisible); title('Original Frame');
figure, imshow(noDarkCarVisible); title('Frame without Dark Cars');

%% Remove small objects like lane markings (Morphlogical Processing)

% Objects smaller in size than the structuring element 
% that we create will be removed
structuringElementDisk = strel('disk',2);

% Small Objects are removed
noSmallStructuresVisible = imopen(noDarkCarVisible, structuringElementDisk);
figure, imshow(noSmallStructuresVisible); title('Frame with only light coloured cars');

%% Apply the Algorithm to the Full Video
% We will read the video frame by frame and apply the above algorithm

numberOfFrames = get(videoTraffic, 'NumberOfFrames');

% Get the first frame
I = read(videoTraffic, 1);

% Light colored cars will be tagged with a red dot
taggedCars = zeros([size(I,1) size(I,2) 3 numberOfFrames], class(I));

for k = 1 : numberOfFrames
    % Get current frame
    currentFrame = read(videoTraffic, k);
    
    % Convert to grayscale to do morphological processing
    I = rgb2gray(currentFrame);
    
    % Remove dark cars
    noDarkCars = imextendedmax(I, darkCarThreshold); 
    
    % Remove lane markings and other non-disk shaped structures
    noSmallStructuresVisible = imopen(noDarkCars, structuringElementDisk);

    % Remove small structures.
    noSmallStructuresVisible = bwareaopen(noSmallStructuresVisible, 150);
   
    % Get the area and centroid of each remaining object in the frame.
    % The object with the maximum area is the light colored car.
    % After getting the centroid, change the centroid pixel color to red
    % and recreate the Video.
    
    % This will be the recreated video
    taggedCars(:,:,:,k) = currentFrame;
   
    stats = regionprops(noSmallStructuresVisible, {'Centroid','Area'});
    
    if ~isempty([stats.Area])
        areaArray = [stats.Area];
        % Get ID of the object of maximum area
        [junk,idx] = max(areaArray);
        
        % Get Centroid of that object
        c = stats(idx).Centroid;
        c = floor(fliplr(c));
        
        % Size of the red dot(marker)
        width = 2;
        row = c(1)-width:c(1)+width;
        col = c(2)-width:c(2)+width;
        % Change the color of the required pixels to red
        taggedCars(row,col,1,k) = 255;
        taggedCars(row,col,2,k) = 0;
        taggedCars(row,col,3,k) = 0;
    end
end

%% Play the recreated video
% Get the frame rate of the original video and use it for taggedCars. 

frameRate = get(videoTraffic,'FrameRate');
implay(taggedCars,frameRate);