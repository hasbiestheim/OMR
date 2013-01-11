function [score,rawscore,count] = omr_scorer(varargin) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_scorer(img, rois, filtersize, thresh, show_figure)
%
% omr_scorer takes a target img and rois and attempts to score the
% target according to the sum of pixels in the rois that exceeds thresh.
% The first step invovles filtering the image to clear noise and remove
% lines. The second step involves cerating a matrix of sums for each roi.
% Finally, the matrix is thresholded and scored.
%
% Threshold can be either a pixel number (i.e., 275) or 'auto' which
% will automatically attempt to determine the threshold by taking the
% min of the max row-wide ROI values (i.e., find the smallest roi across
% all rows which is also the largest roi for its row). 
%
% omr_scorer returns a score vector, the rawscore matrix and a total count
% of detected marks (for error checking).
%
% If no thresh is defined omr_scorer uses a default of 275 pixels.
% If no filtersize is defined omr_scorer uses a default of 200 pixels 
% (i.e., unconnected structures < 200 pixels should be filtered out). 
%
% Finally, if show_figure = 1, omr_scorer will overlay it's scoring on 
% top of the original img for error checking. 
%
% Example: [score,rawscore,count] = omr_scorer(img, rois, 200, 0)
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
    thresh  = 275;
    showfig = 0;
  case 3
    img     = varargin{1};
    rois    = varargin{2};
    filter  = varargin{3};
    thresh  = 275;
    showfig = 0;
  case 4
    img     = varargin{1};
    rois    = varargin{2};
    filter  = varargin{3};
    thresh  = varargin{4};
    showfig = 0;
  case 5
    img     = varargin{1};
    rois    = varargin{2};
    filter  = varargin{3};
    thresh  = varargin{4};
    showfig = varargin{5};
  otherwise
    error(['omr_scorer requires and img and roi set.',...
          'Type help omr_scorer for more information.']);
end
%%% Check for omitted inputs
if isempty(thresh)
    thresh = 275;
end
if isempty(filter)
    filter = 200;
end
if isempty(showfig)
    showfig = 0;
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Filter target img to remove small objects
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Filtering target image using a filter size of %d pixels...', filter);
    imgfilt = bwareaopen(medfilt2(img,[5,2]),filter);
    %[3 3] also works well but this gets rid of lines.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Score based on ROIs and threshold
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    fprintf('Scoring... ');
    %create matrix of sums of rois
    rawscore = zeros(size(rois,1),size(rois,2));
    %loop through and create matrix of roi sums
    for i = 1:size(rois,1)
        for ii = 1:size(rois,2)
            rawscore(i,ii) = sum(imgfilt(rois{i,ii}));
        end
    end
    %Check for 'auto' thresh
    if strcmp(thresh, 'auto')
        fprintf(['Warning! Threshold set to auto.\nSelf-corrects will',...
                 'have to be manually corrected.\n']);
        thresh = max(rawscore,[],2);
        thresh = repmat(thresh,1,size(rawscore,2));
    end    
    rawscore(rawscore<thresh)=0;
    rawscore(rawscore>=thresh)=1;
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Assign likert scale values to score
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    scoremat = rawscore;
    for i = 1:size(rawscore,2)
        scoremat(scoremat(:,i)==1,i)=i;
    end
    score = max(scoremat,[],2);    %take max for vector of ratings
    fprintf('Done...\n');
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Output the total count of detected marks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    count = sum(sum(rawscore));
    fprintf('Detected %d marks out of %d ROIs...\n',count, size(rois,1));
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Make figure if user requested
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    if showfig
        fprintf('Showing Figure of Scores...\n');
        figure('Name','ROI Scorer'), imshow(omr_mask(imgfilt, [150,1,800,70]))
        %imshow(plate);
        hold on
        tmpimg = img;
        for i = 1:size(rois,2)         %Fill in detected scores
            for ii = 1:size(rois,1)
                %Get centroids from ROIs again
                tmpimg(:,:)        = 0;
                tmpimg(rois{ii,i}) = 1;
                tmp_centroids      = regionprops(tmpimg,'Centroid');
                x = tmp_centroids.Centroid(1);
                y = tmp_centroids.Centroid(2);
                %Display score
                text(x+20,y,['\color{yellow}\bf',sprintf('[%d]',scoremat(ii,i))])
                %If last col, check if row had duplicates or missing values
                %eventually overlay the unfitlered image, but that requires
                %having the entire set of centroids saved (which we should
                %do anyway, but too busy right now to code it). 
                if i ==size(rois,2)
                    if sum(rawscore(ii,:))==0
                        text(x+60,y,['\color{orange}\bf\leftarrow',sprintf('R:%d MIS',ii)])
                     elseif sum(rawscore(ii,:))>1
                        text(x+60,y,['\color{orange}\bf\leftarrow',sprintf('R:%d DUP',ii)]) 
                    end
                end               
            end
        end
        %Make ROI image (again)... We could compute centroids here too 
        tmpimg(:,:) = 0;  %zero tmpimg again
        for i = 1:size(rois,1)
            for ii = 1:size(rois,2)
                tmpimg(rois{i,ii}) = 1;       
            end
        end
        %calculate and plot boundaries
        boundaries = bwboundaries(tmpimg);
        for i = 1:size(boundaries,1)
            b = boundaries{i};
            plot(b(:,2),b(:,1),'y','LineWidth',2);
        end
        %Display title
        text(size(img,2)/2,30,['\fontsize{16}\color{orange}\bf',sprintf('Detected %d out of %d ROIs',...
            count, size(rois,1))], 'HorizontalAlignment','center');
        hold off
    end
    