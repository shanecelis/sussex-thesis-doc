SetDirectory["/Users/shane/School/sussex/thesis/code/src"];

diff = makeFrogMorphDiff[];

geneToCTRNNC = makeGeneToCTRNNC[];

experimentsC = makeExperimentsC[];

exportToC[{diff, geneToCTRNNC, experimentsC}, {"frogRHS", 
  "geneToCTRNN", "experiments"}]; 

ResetDirectory[];
