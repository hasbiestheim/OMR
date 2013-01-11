function img = omr_mask(varargin) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_mask(imgfile, [x,y,w,h],maskflip)
%
% omr_mask masks out a section of image set according to a bounding box.
% Optionally, omr_mask will invert the mask, keeping everything within
% the bounding box. 
%
% Example: img = omr_mask(imgfile, [200,200,400,800],1)
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
    box     = varargin{2};
    flip    = 0;
  case 3
    img     = varargin{1};
    box     = varargin{2};
    flip    = varargin{3};
  otherwise
    error(['omr_mask requires an image and bounding box.',...
          'Type help omr_loader for more information.']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Create and apply mask
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
mask            = ones(size(img,1),size(img,2));  %init mask
[rows,cols]     = omr_coord(box);                 %convert coord to matrix
mask(rows,cols) = 0;                              %Set box to 0 (mask)
if flip;                                          %Flip mask if needs be.
    mask = ~mask; 
end                       
img = img.*mask;                                  %Multiply by mask

%tmp
% tmask = ones(size(plateroi,1),size(plateroi,2));
% [rows,cols]     = omr_coord([560,220,600,1400]);
% tmask(rows,cols) = 0;
% imshow(tmask)



 