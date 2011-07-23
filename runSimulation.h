#include "WolframLibrary.h"

EXTERN_C DLLEXPORT int Initialize_runSimulation(WolframLibraryData libData);

EXTERN_C DLLEXPORT void Uninitialize_runSimulation(WolframLibraryData libData);

EXTERN_C DLLEXPORT int runSimulation(WolframLibraryData libData, MTensor A1, mreal A2, MTensor A3, MTensor *Res);

