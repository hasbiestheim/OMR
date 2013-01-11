function [imgcoord, imgsize, imgarea, imgcentroid] = omr_corners(varargin) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_corners(img, bounding_box)
%
% omr_corners takes an binary image matrix and coordinates of a bounding 
% box [x,y,width,height] defining a search area in the image to look for 
% major features. Returns the coordiantes in the original image space of 
% the top left corner of the largest feature found in the specified 
% bounding box.  Also returns the size(width,height) of a bounding box 
% encompasing the feature, the area of the feature and the centroid. 
%
% Example: [sqcorner, sqsize, sqarea, sqcentroid] = omr_corners(image, [1,1,100,100])
%         
% DDW.2012.03.20
%--------------------------------------------------------------------------
% Change log:
% -First version - March 2012

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Input checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch (nargin)
  case 2
    img = varargin{1};
    box = varargin{2};
  otherwise
    error(['omr_corners requires both an image and a bounding box.',...
          'Type help omr_corners for more information.']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Keep only major feature based on max area
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Translate (X,Y,W,H) to matrix coords (row:row_end,col:col_end)
[rows,cols] = omr_coord(box);
features    = regionprops(img(rows,cols));
features    = features(cat(1,features.Area)==max(cat(1,features.Area))); 
%%%BLOODY HELL, ONE IMAGE ACTUALLY HAS 2 FEATURE OF SAME AREA AND THEREFORE
%%%THERE IS NO MAX IMAGE (both same area).
%%% TIE BREAKER, assume square'ish bounding box
if length(features)>1 
    [wh1] = features(1).BoundingBox;
    [wh2] = features(2).BoundingBox;
    sq1chk          = round(wh1(4)-wh1(3));
    sq2chk          = round(wh2(4)-wh2(3));
    if sq1chk < sq2chk
        features = features(1);
    else
        features = features(2);
    end
end
bbox        = features.BoundingBox;

%Since bbox is from topleft corner of the smaller image section
%add original bounding box coords back to get bbox in img space
bbox(1)  = round(bbox(1)+box(1)-1);
bbox(2)  = round(bbox(2)+box(2)-1);

%Assign output
imgcoord    = round([bbox(1),bbox(2)]);
imgsize     = round([bbox(3),bbox(4)]);
imgarea     = features.Area;
imgcentroid = [features.Centroid(1)+box(1)-1,features.Centroid(2)+box(2)-1];

