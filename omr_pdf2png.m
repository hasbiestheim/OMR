function omr_pdf2png(varargin) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_pdf2png(file,dpi,gs_location)
%
% omr_pdf2png converts PDFs to binary PNG files (black,white) which 
% can then be used for further analysis. 
%
% omr_pdf2png optional takes dpi (default is 15) and the location of the 
% user's ghostscript installation. Unfortunately, at this time, Matlab's
% native ghostscript cannot be used for conversion (it's very fussy). 
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
    file        = varargin{1};
    dpi         = 150;
    gs_location = [];
    case 2
    file        = varargin{1};
    dpi         = varargin{2};
    gs_location = [];
  case 3
    file        = varargin{1};
    dpi         = varargin{2};
    gs_location = varargin{3};
  otherwise
    error(['omr_pdf2png requires a file to work on',...
          'Type help omr_pdf2png for more information.']);
end

%%% Attempt to find ghostscript
if ispc
    if isempty(gs_location) 
        gs_location = 'C:\Program Files\GPLGS\';       
    end   
    gs = [gs_location, 'gswin32c.exe'];
else
    gs = '/usr/bin/gs';
end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Run GS
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
[filepath,filename] = fileparts(file);
fprintf('Converting %s.pdf to individual images (grayscale, %ddpi)...\n',filename, dpi);
system(sprintf('"%s" %s', gs, sprintf('-dNOPAUSE -dBATCH -sDEVICE=pnggray -r%d -sOutputFile="%s_%%03d.png" "%s.pdf"',...
                                      dpi,file,file)));
fprintf('Done\n');
