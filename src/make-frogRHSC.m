SetDirectory["/Users/shane/School/sussex/thesis/code/src"];

diff = makeFrogMorphDiff[];

geneToCTRNNC = makeGeneToCTRNNC[];

experimentsC = makeExperimentsC[];

physconsC = makePhysicsConstantsC[];

exportToC[{diff, geneToCTRNNC, experimentsC, physconsC}, {"frogRHS", 
  "geneToCTRNN", "experiments", "physicsConstants"}];  

ResetDirectory[];
