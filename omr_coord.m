function [rows,cols] = omr_coord(varargin) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_coord([x,y,w,h])
%
% omr_coord converts x,y,width,height bounding boxes to img
% matrix row,col. If no width and height are specified, then
% omr_coord returns only the row and col cooresponding to x,y
% (i.e., y,x). 
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
    box = varargin{1};
  otherwise
    error(['omr_coord requires a single bounding box.',...
          'Type help omr_coord for more information.']);
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Convert to matrix coords
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Translate (X,Y,W,H) to matrix coords (row:row_end,col:col_end)
if length(box) == 2
    rows = box(2);
    cols = box(1);
elseif length(box) == 4
    rows = box(2):box(2)+box(4)-1;
    cols = box(1):box(1)+box(3)-1;
else
    error('bounding box should be [x,y,w,h] format.');
end
