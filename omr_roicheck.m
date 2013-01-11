function [adj_rois] = omr_roicheck(varargin) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_roicheck(img, rois, filtersize, X, Y)
%
% omr_roicheck takes a target img and rois and returns a figure
% overlaying the rois onto the target img to check for alignment
% of roi grid to img.
% 
% Optionally, omr_roicheck will take filtersize (default is 200). 
% omr_roicheck can also take X and/or Y adjustments to translate
% the roi grid. This helps in manually determining the optimal 
% values for alignment of roi_grid to image when the registration 
% was poor. omr_roicheck will then output a variable containing 
% adjusted rois which can be passed to omr_scorer. 
%
%
% Example: omr_roicheck(img, rois)
%          adj_rois = omr_roicheck(img, rois, 200, 10, 20)
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
    img     = varargin{1};
    rois    = varargin{2};
    filter  = 200;
    X       = [];
    Y       = [];
  case 3
    img     = varargin{1};
    rois    = varargin{2};
    filter  = varargin{3};
    X       = 0;
    Y       = 0;
  case 4
    img     = varargin{1};
    rois    = varargin{2};
    filter  = varargin{3};
    X       = varargin{4};
    Y       = 0;
  case 5
    img     = varargin{1};
    rois    = varargin{2};
    filter  = varargin{3};
    X       = varargin{4};
    Y       = varargin{5};
  otherwise
    error(['omr_roicheck requires an img and roi set.',...
          'Type help omr_scorer for more information.']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Filter target img to remove small objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Filtering target image using a filter size of %d pixels...', filter);
    img = bwareaopen(medfilt2(img,[5,2]),filter);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Adjust ROIs if necessary
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    if ~isempty(X)
        fprintf('Adjusting roi grid by %d,%d...', X, Y);
        for i = 1:size(rois,1)
            for ii = 1:size(rois,2)
                %convert linear index to sub index
                [y,x] = ind2sub(size(img), rois{i,ii});
                x = x + X; y = y + Y;   %I don't know why it
                                        %requires such odd asignments
                                        %but it works. 
                yx = [y,x];
                %remove out of range values
                yx(yx(:,1)>size(img,1),:) = [];
                yx(yx(:,2)>size(img,2),:) = [];
                %convert back to linear and assign to rois.
                rois{i,ii} = sub2ind(size(img),yx(:,1), yx(:,2));
            end
        end
        fprintf('Done...\n');
    end
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Make figure 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    %Create ROI grid in image space and then determine boundaries
    tmpimg      = img;
    tmpimg(:,:) = 0;
    for i = 1:size(rois,1)
        for ii = 1:size(rois,2)
            tmpimg(rois{i,ii}) = 1;       
        end
    end
    %calculate boundaries
    boundaries = bwboundaries(tmpimg);
    %show figure with boundaries of rois
    figure('Name','ROI Registration Check'), imshow(omr_mask(img, [150,1,800,70]))
    hold on
    for i = 1:size(boundaries,1)
        b = boundaries{i};
        plot(b(:,2),b(:,1),'y','LineWidth',2);
    end
    text(size(img,2)/2,30,['\fontsize{16}\color{orange}\bf','ROI Registration check'],...
         'HorizontalAlignment','center');
    hold off 

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Output adjusted ROIs based on X,Y supplied by user
%%% This could be input into omr_roifinder. If no 
%%% XY adjustments were made, then this is same as input
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    adj_rois = rois; 
    