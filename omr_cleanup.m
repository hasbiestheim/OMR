function [score,rawscore,count] = omr_cleanup(varargin) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_cleanup(img, rois, rawscore)
%
% omr_cleanup takes a target img, rois and the rawscore matrix from 
% omr_scorer and allows the user to manually input missing data or 
% fix duplicate entries. 
%
% omr_cleanup then returns a new score, rawscore and count matrix which
% contain the "cleaned" data. 
%
% Example: [score_c,rawscore_c,count_c] = omr_cleanup(img, rois, rawscore)
%         
% DDW.2012.03.20
%--------------------------------------------------------------------------
% Change log:
% -First version - March 2012

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Input checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch (nargin)
  case 3
    img      = varargin{1};
    rois     = varargin{2};
    rawscore = varargin{3};
  otherwise
    error(['omr_cleanup requires the image, rois and rawscore (from omr_scorer).',...
          'Type help omr_cleanup for more information.']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Make figure 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%  
    fprintf('\nWelcome to omr_cleaner...\nShowing figure of missing and/or duplicate scores...\n');
    %%% Manually mask region for title (can't use omr_mask this time
    %%% because we're not inverting the image)
    [xm,ym]     = omr_coord([150,1,800,70]);
    img(xm,ym)  = 0;
    %%% Init some vars
    tmpimg = img;
    mcount = 1;  dcount = 1;
    mis    = []; dup    = [];
    %%% Build figure
    h = figure('Name','Score Cleaner');
    imshow(~img)
    hold on
    for i = 1:size(rois,2)         %Show ROIs, find Duplicates
        for ii = 1:size(rois,1)
            %Get centroids from ROIs again
            tmpimg(:,:)        = 0;
            tmpimg(rois{ii,i}) = 1;
            tmp_centroids      = regionprops(tmpimg,'Centroid');
            x = tmp_centroids.Centroid(1);
            y = tmp_centroids.Centroid(2);
            %If last col, check if row had duplicates or missing values
            %eventually overlay the unfitlered image, but that requires
            %having the entire set of centroids saved (which we should
            %do anyway, but too busy right now to code it). 
            if i ==size(rois,2)
                if sum(rawscore(ii,:))==0
                    text(x+30,y,['\color{red}\bf\leftarrow',sprintf('R:%d MIS',ii)])
                    mis(mcount) = ii;
                    mcount      = mcount + 1;
                 elseif sum(rawscore(ii,:))>1
                    text(x+30,y,['\color{red}\bf\leftarrow',sprintf('R:%d DUP',ii)]) 
                    dup(dcount) = ii;
                    dcount      = dcount + 1;
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
        plot(b(:,2),b(:,1),'b','LineWidth',2);
    end
    %Display title
    text(size(img,2)/2,30,['\fontsize{16}\color{orange}\bf','Cleanup'], 'HorizontalAlignment','center');
    hold off
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Cleanup Missing and Duplicates
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    % Concat mis and dup
    fixthese = sort([mis,dup]);
    if ~isempty(fixthese)
        for i = 1:length(fixthese)
           fprintf('Fixing values at row %d...\n',fixthese(i));
           dlg_title = 'Fix Value';
           prompt = (sprintf('Row %d: Enter Column Number (1 to %d)',fixthese(i),size(rois,2)));
           fixcol = inputdlg(prompt,dlg_title);
           rawscore(fixthese(i),:)      = 0;
           rawscore(fixthese(i),str2num(fixcol{1})) = 1;
        end
    end
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Assign likert scale values to score
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%     
    fprintf('Rescoring cleaned data...\n');
    scoremat = rawscore;
    for i = 1:size(rawscore,2)
        scoremat(scoremat(:,i)==1,i)=i;
    end
    score = max(scoremat,[],2);    %take max for vector of ratings
   
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Output the total count of detected marks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%    
    count = sum(sum(rawscore));
    close(h)
    fprintf('Cleaned data contains %d marks out of %d ROIs...\n\n',count, size(rois,1));
    

    