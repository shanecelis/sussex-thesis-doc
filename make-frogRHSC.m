SetDirectory["/Users/shane/School/sussex/thesis/code"];

diff = makeFrogMorphDiff[];

geneToCTRNNC = makeGeneToCTRNNC[];

experimentsC = makeExperimentsC[];

exportToC[{diff, geneToCTRNNC, experimentsC}, {"frogRHS", 
  "geneToCTRNN", "experiments"}]; 

ResetDirectory[];
