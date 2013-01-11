function img = omr_loader(varargin) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_loader(imgfile, invert, rotate)
%
% omr_loader loads an image file and binarizes it. 
% Optionally, omr_loader will inver the image (usually necessary for
% image analysis) and/or rotate the image (such as when you scanned them
% upside down, as we did). 
%
% omr_register returns the binarized, inverted and rotated image.
%
% Example: img = omr_loader(imgfile, 1, 180)
%         
% DDW.2012.03.20
%--------------------------------------------------------------------------
% Change log:
% -First version - March 2012

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Input checks
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
switch (nargin)
  case 1
    imgfile = varargin{1};
    invert  = 0;
    rotate  = 0;
  case 2
    imgfile = varargin{1};
    invert  = varargin{2};
    rotate  = 0;
  case 3
    imgfile = varargin{1};
    invert  = varargin{2};
    rotate  = varargin{3};
  otherwise
    error(['omr_loader requires at least one input and no more than three.',...
          'Type help omr_loader for more information.']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Load and binarize image, invert and rotate if asked
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    img = imread(imgfile);            %Read in image
    img = im2bw(img,graythresh(img)); %Binarize   
    if invert
        img = ~img;                   %Invert img.
    end
    if rotate
        img = imrotate(img,rotate);   %Rotate img.
    end
 