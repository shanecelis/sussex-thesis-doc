#include "WolframLibrary.h"

EXTERN_C DLLEXPORT int Initialize_experiments(WolframLibraryData libData);

EXTERN_C DLLEXPORT void Uninitialize_experiments(WolframLibraryData libData);

EXTERN_C DLLEXPORT int experiments(WolframLibraryData libData, mint A1, mreal A2, mint A3, MTensor *Res);

