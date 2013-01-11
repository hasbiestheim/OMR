function rois = omr_roifinder(varargin) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_roifinder(template, mask_box, flipmask, show_figure)
%
% omr_roifinder filters and masks a template image then segments
% the iamge looking for bubbles (rois), finally it returns a cell
% array (rows of questions and columns of responses) of roi locaitons. 
%
% Optionally, omr_roifinder will display a figure showing what it thinks
% the bubbles are and their row,col number. 
%
% Example: bubbles = omr_roifinder(template, [50,250,600,1400],1,1)
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
    plate   = varargin{1};
    mask    = varargin{2};
    flip    = 0;
    showfig = 0;
  case 3
    plate   = varargin{1};
    mask    = varargin{2};
    flip    = varargin{3};
    showfig = 0;
  case 4
    plate   = varargin{1};
    mask    = varargin{2};
    flip    = varargin{3};
    showfig = varargin{4};
  otherwise
    error(['omr_roifinder requires at a minimum a template img and mask box.',...
          'Type help omr_roifinder for more information.']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Filter plate image (this is hardcoded and works for my 
%%% templates but might not generalize)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %Filter, remove small objects (less than 100pixels) and fill holes
    fprintf('\nFiltering and masking template image...');
    plateroi = imfill(bwareaopen(medfilt2(plate,[3,3]),100),'holes');
    plateroi = omr_mask(plateroi,mask,flip);  %mask ~bubbles

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Segment image and sort ROIs
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    fprintf('Segmenting image...');
    roi_cc = bwconncomp(plateroi, 8);   %8 seems to work best
    %Calculate centroids
    roi_centroids = regionprops(roi_cc,'Centroid');
    %Get diameter for later(see figure)
    roi_diameter  = regionprops(roi_cc,'MajorAxisLength');
    roi_diameter  = round(roi_diameter(1).MajorAxisLength);
    %Figure out number of rows based on changes in distance
    if size(roi_centroids,2) ~= 1
        for i = 3:length(roi_centroids)
            distA = abs(roi_centroids(i-1).Centroid(2) - roi_centroids(i-2).Centroid(2));
            distB = abs(roi_centroids(i).Centroid(2) - roi_centroids(i-1).Centroid(2));
            %check if 3*usual distance (3 to be safe)
            if distB > 3*distA
                roi_rows = i-1;
                roi_cols = roi_cc.NumObjects / roi_rows;
                break
            end    
        end
    else
        roi_rows = 1;
        roi_cols = size(roi_centroids,1);
    end
    %Assign indexes to cell arraw of rows x cols
    rois = cell(roi_rows,roi_cols);
    irows = 1; icols = 1;
    for i = 1:roi_cc.NumObjects
        rois(irows,icols) = roi_cc.PixelIdxList(i);
        if irows == roi_rows
            irows = 1;
            icols = icols + 1;
        else
            irows = irows + 1;
        end
    end
    fprintf('Done...\nROIs:%d Rows:%d Cols:%d\n',roi_cc.NumObjects,roi_rows,roi_cols);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Make figure if user requested
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    if showfig
        fprintf('\nShowing Figure of ROIs... %d ROIs found.\n',roi_cc.NumObjects);
        roi_img = label2rgb(labelmatrix(roi_cc));
        figure('Name','ROI Finder'), imshow(omr_mask(plate, [150,1,800,70]))
        hold on
        h = imshow(roi_img);  
        icent = 1;
        for i = 1:size(rois,2)
            for ii = 1:size(rois,1)
                x = roi_centroids(icent).Centroid(1);
                y = roi_centroids(icent).Centroid(2);
                text(x+roi_diameter/2+5,y,['\fontsize{8}\color{orange}\bf',sprintf('[%d,%d]',ii,i)])
                icent = icent + 1;
            end
        end
        text(size(plate,2)/2,30,['\fontsize{16}\color{orange}',sprintf('Total ROIs: %d, Rows: %d, Cols: %d',...
             roi_cc.NumObjects,roi_rows,roi_cols)], 'HorizontalAlignment','center');
        set(h, 'AlphaData', plateroi);
    end

    
%%%UNUSED CODE
%     figure, imshow(RGB_label)
%     grain = false(size(plate_img));
%     grain(cc.PixelIdxList{44}) = true;
%     imshow(grain);
