#include "WolframLibrary.h"

EXTERN_C DLLEXPORT int Initialize_frogRHS(WolframLibraryData libData);

EXTERN_C DLLEXPORT void Uninitialize_frogRHS(WolframLibraryData libData);

EXTERN_C DLLEXPORT int frogRHS(WolframLibraryData libData, MTensor A1, MTensor A2, MTensor *Res);

EXTERN_C DLLEXPORT int geneToCTRNN(WolframLibraryData libData, MTensor A1, MTensor *Res);
EXTERN_C DLLEXPORT int experiments(WolframLibraryData libData, mint A1, mreal A2, mint A3, MTensor *Res);
