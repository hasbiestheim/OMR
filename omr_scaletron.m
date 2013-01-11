function [scored] = omr_scaletron(score, scaledefs) 
% OMR TOOLS
% Tools for performing OMR on scanned forms
% Last Modified: March 2012, Dylan D. Wagner
% =============================================
% omr_scaletron(score, scaledefs)
%
% omr_scaletron takes a vector of subject raw scores from omr_scorer and
% converts them to scale scores (e.g., factors of the big five) based
% on scaledefs.
%
% scaledefs is a structure containing fields for each dimension to score
% and the type of scoring required. See example below for the BFI. 
% -range is the range of the scale items (i.e. 1 to 5)
% -itmesf are the items (i.e. row numbers of the score vector) which are part of
% that dimension. 
% -itemsr are the items for each dimension that must be reverse scored.
% -method is the method for scoring the items. Options are 'sum' or
% 'mean'.
%
% scaledefs.range = [1,5];
% scaledefs.method = 'mean';
% scaledefs.open.items  = [5,10,15,20,25,30,40,44];
% scaledefs.open.itemsr = [35,41];
% scaledefs.cons.items  = [3,13,28,33,38];
% scaledefs.cons.itemsr = [8,18,23,43];
% scaledefs.extr.items  = [1,11,16,26,36];
% scaledefs.extr.itemsr = [6,21,31]
% scaledefs.agre.items  = [7,17,22,32,42];
% scaledefs.agre.itemsr = [2,12,27,37];
% scaledefs.neur.items  = [4,14,19,29,39];
% scaledefs.neur.itemsr = [9,24,34];
%
% Example: [bfi] = omr_scaletron(score, scaledefs)
%         
% DDW.2012.04.02
%--------------------------------------------------------------------------
% Change log:
% -First version - April 2012

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Set range and methods and get fields for dimensions
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    fprintf('Scoring data for %d items...\n', length(score));
    method    = scaledefs.method;
    srange    = scaledefs.range;
    scaledefs = rmfield(scaledefs,{'method','range'});
    sdimens   = fieldnames(scaledefs);
    
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Generate new structure accounting for revscores
%%% Note can get rid of the evals by calling struct 
%%% with .() ... Clean this later when time.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    for i = 1:length(sdimens)
        evalthis = sprintf('scored.%s = score(scaledefs.%s.items);',sdimens{i},sdimens{i}); 
        eval(evalthis);
        %check for reverse scored items field 
        tfield = 0;
        try 
            tmp = eval(sprintf('scaledefs.%s.itemsr;',sdimens{i})); 
            tfield = 1;
        catch
        end
        %if reverse scored items field exists and isn't empty
        if tfield && ~isempty(eval(sprintf('scaledefs.%s.itemsr;',sdimens{i})))
            eval(sprintf('tmp = %d+1-score(scaledefs.%s.itemsr);',srange(2),sdimens{i}));
            eval(sprintf('scored.%s = [scored.%s; tmp];',sdimens{i},sdimens{i}));
        end        
        %Apply scoring method
        eval(sprintf('scored.%s = %s(scored.%s);',sdimens{i},method,sdimens{i}));          
    end
      
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Convert struct 2 cell array (cleaner to do this above
%%% but realized too late that I wanted cells and not struct)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%   
    scored = [sdimens,struct2cell(scored)];
    fprintf('Done...\n');
    
    