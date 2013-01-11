function img = omr_register(varargin) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_register(template, target, template_search, target_search)
%
% omr_register calculates an affine transformation based on centroids
% of the square markers in both the target and template image.
%
% Optionally, omr_register will take 2 3x4 matrix of the bounding boxes
% for the image region to search for the square markers in the template
% and in the target. If unspecified the default of a 100x100 search 
% rectangle in the upper left, upper right and lower right corners of the
% image is used.
%
% omr_register returns an img registered and cropped to match the template
%
% Example: newimg = omr_register(template, target)
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
    plate    = varargin{1};
    target   = varargin{2};
    %In theory p_search and t_search are same because both target and
    %template images should have same size to start. Nevertheless...
    p_search = [1,1,100,100;...                               %TopLeftSquare
            size(plate,2)-100,1,100,100;...                   %TopRightSquare
            size(plate,2)-100,size(plate,1)-100,100,100];     %BottomRightSquare
    t_search = [1,1,100,100;...                               %TopLeftSquare
            size(target,2)-100,1,80,80;...                    %TopRightSquare
            size(target,2)-100,size(target,1)-100,100,100];   %BottomRightSquare
  case 4
    plate    = varargin{1};
    target   = varargin{2};
    p_search = varargin{3};
    t_search = varargin{4};  
  otherwise
    error(['omr_register requires at a minimum a template and target img.',...
          'Type help omr_register for more information.']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Copy target with holes filled for ctr point detection
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    target_tmp = imfill(target,'holes'); %aggresively cleans bad scans
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Find squares and centroids on template and subject
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Finding control points...');
    %%%TEMPLATE
    for i = 1:size(p_search,1)
        [sqcoord(i,:),sqsize(i,:),sqarea(i,:),sqcentroid(i,:)] = omr_corners(plate,p_search(i,:));  
    end
    ctrp_plate  = sqcentroid;    %assign centroids as control points
    %%%SUBJECT
    for i = 1:size(t_search,1)
        [sqcoord(i,:),sqsize(i,:),sqarea(i,:),sqcentroid(i,:)] = omr_corners(target_tmp,t_search(i,:));  
    end
    ctrp_target = sqcentroid;   %assign centroids as control points
    %CHECK centroids
%     figure, imshow(plate)
%     hold on 
%     plot(ctrp_plate(:,1),ctrp_plate(:,2),'+','Color','r')
%     hold off
%     pause
%     figure, imshow(target)
%     hold on 
%     plot(ctrp_target(:,1),ctrp_target(:,2),'+','Color','r')
%     hold off 
%     pause
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Use control points to calculate an affine transform
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Applying affine transformation...');
    imgtform = cp2tform(ctrp_target,ctrp_plate,'affine'); %Calculate affine
    img      = imtransform(target,imgtform);              %transform image
    img_tmp  = imtransform(target_tmp,imgtform);          %transform tmp img
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Crop target image to square markers
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Cropping...');
    %Find square markers in registered img requires new sqsearch
    %This part could get dangerous since we override user, but should work
    %since we're now aligned to template but image is bigger.
    q_search = [1,1,100,100;...                         %TopLeftSquare
            size(img,2)-100,1,100,100;...               %TopRightSquare
            size(img,2)-100,size(img,1)-100,100,100];   %BottomRightSquare
    for i = 1:size(p_search,1)                %use plate search regions now since we're aligned
        [sqcoord(i,:),sqsize(i,:),sqarea(i,:),sqcentroid(i,:)] = omr_corners(img_tmp,q_search(i,:));  
    end
%     figure, imshow(img)
%     hold on 
%     plot(sqcentroid(:,1),sqcentroid(:,2),'+','Color','r')
%     hold off 
    %Crop to square markers
%     img = imcrop(img,[sqcoord(1,1), sqcoord(2,2),sqcoord(2,1)+sqsize(2,1)-sqcoord(1,1),sqcoord(3,2)+sqsize(3,2)-sqcoord(2,2)]);
%     %Crop again to template size. Should already be same, but just to be
%     %safe we'll shave off a few extra pixels.
%     img = imcrop(img,[1,1,size(plate,2)-1,size(plate,1)-1]);
    %Crop to top left square in size of template instead!!
    %This works well for poorly registered images due to bad scanner
    %quality, namely it at least gets us into the same size as the template
    img = imcrop(img,[sqcoord(1,1),sqcoord(2,2),size(plate,2)-1,size(plate,1)-1]);
    %pad if necessary
    if size(img,1) ~= size(plate,1)
        fprintf('Padding rows...');
        img(end:size(plate,1),:) = 0;    
    end
    if size(img,2) ~= size(plate,2)
        fprintf('Padding columns...');
        img(:,end:size(plate,2)) = 0;
    end
    fprintf('Done\n');

