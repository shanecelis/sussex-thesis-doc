/*************************************************************************
                        Mathematica source file

        Copyright 1986 through 2000 by Wolfram Research Inc.

This material contains trade secrets and may be registered with the
U.S. Copyright Office as an unpublished work, pursuant to Title 17,
U.S. Code, Section 408.  Unauthorized copying, adaptation, distribution
or display is prohibited.

$Id: WolframRTL.h,v 1.12 2010/08/06 14:59:41 twj Exp $

*************************************************************************/

#ifndef WOLFRAMRTL_H
#define WOLFRAMRTL_H

#include "WolframLibrary.h"
#include "WolframCompileLibrary.h"


EXTERN_C DLLEXPORT void WolframRTL_initialize(mint version);

EXTERN_C DLLEXPORT WolframLibraryData WolframLibraryData_new(mint version);
EXTERN_C DLLEXPORT void WolframLibraryData_free(WolframLibraryData data);

#endif
