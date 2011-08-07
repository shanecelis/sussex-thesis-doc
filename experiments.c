#include "math.h"

#include "WolframRTL.h"

static WolframCompileLibrary_Functions funStructCompile;

static LibraryFunctionPointer FP0;

static LibraryFunctionPointer FP1;

static MArgument FPA[3];


static mint I0_2;

static mint I0_3;

static mint I0_4;

static mint I0_5;

static mint I0_6;

static mint I0_7;

static mint I0_8;

static mreal R0_1;

static mreal R0_4;

static mreal R0_5;

static mreal R0_6;

static MTensor T0_0B = 0;

static MTensor* T0_0 = &T0_0B;

static MTensor T0_2B = 0;

static MTensor* T0_2 = &T0_2B;

static MTensor T0_6B = 0;

static MTensor* T0_6 = &T0_6B;

static MTensor T0_14B = 0;

static MTensor* T0_14 = &T0_14B;

static mint *P0;

static mint *P1;

static mint *P2;

static mint *P3;

static mbool initialize = 1;

#include "experiments.h"

DLLEXPORT int Initialize_experiments(WolframLibraryData libData)
{
int err = 0;
if( initialize)
{
funStructCompile = libData->compileLibraryFunctions;
R0_5 = (mreal) 0.3333333333333333;
I0_3 = (mint) 0;
{
mint S0[1];
S0[0] = 1;
err = funStructCompile->MTensor_allocate(T0_14, 2, 1, S0);
if( err)
{
goto error_label;
}
P0 = MTensor_getIntegerDataMacro(*T0_14);
P0[0] = -2;
}
I0_8 = (mint) 6;
I0_7 = (mint) 5;
{
mint S0[1];
S0[0] = 1;
err = funStructCompile->MTensor_allocate(T0_0, 2, 1, S0);
if( err)
{
goto error_label;
}
P1 = MTensor_getIntegerDataMacro(*T0_0);
P1[0] = 1;
}
I0_5 = (mint) 2;
R0_6 = (mreal) 0.6666666666666666;
I0_2 = (mint) 1;
R0_1 = (mreal) 1.;
{
mint S0[1];
S0[0] = 1;
err = funStructCompile->MTensor_allocate(T0_6, 2, 1, S0);
if( err)
{
goto error_label;
}
P2 = MTensor_getIntegerDataMacro(*T0_6);
P2[0] = 4;
}
{
mint S0[1];
S0[0] = 1;
err = funStructCompile->MTensor_allocate(T0_2, 2, 1, S0);
if( err)
{
goto error_label;
}
P3 = MTensor_getIntegerDataMacro(*T0_2);
P3[0] = -1;
}
I0_6 = (mint) 4;
I0_4 = (mint) 3;
R0_4 = (mreal) 0.;
FP0 = funStructCompile->getFunctionCallPointer("CoerceTensor");
if( FP0 == 0)
{
return LIBRARY_FUNCTION_ERROR;
}
FP1 = funStructCompile->getFunctionCallPointer("CopyTensor");
if( FP1 == 0)
{
return LIBRARY_FUNCTION_ERROR;
}
initialize = 0;
}
error_label:
return err;
}

DLLEXPORT void Uninitialize_experiments(WolframLibraryData libData)
{
if( !initialize)
{
if( *T0_14)
{
libData->MTensor_free(*T0_14);
*T0_14 = 0;
}
if( *T0_0)
{
libData->MTensor_free(*T0_0);
*T0_0 = 0;
}
if( *T0_6)
{
libData->MTensor_free(*T0_6);
*T0_6 = 0;
}
if( *T0_2)
{
libData->MTensor_free(*T0_2);
*T0_2 = 0;
}
initialize = 1;
}
}

DLLEXPORT int experiments(WolframLibraryData libData, mint A1, mreal A2, mint A3, MTensor *Res)
{
mbool B0_0;
mbool B0_1;
mbool B0_2;
mbool B0_3;
mbool B0_4;
mbool B0_5;
mbool B0_6;
mbool B0_7;
mbool B0_8;
mbool B0_9;
mbool B0_10;
mint I0_0;
mint I0_1;
mreal R0_0;
mreal R0_2;
mreal R0_3;
mreal R0_7;
mreal R0_8;
mreal R0_9;
MTensor* T0_1;
MTensor* T0_3;
MTensor* T0_4;
MTensor* T0_5;
MTensor* T0_7;
MTensor* T0_8;
MTensor* T0_9;
MTensor* T0_10;
MTensor* T0_11;
MTensor* T0_12;
MTensor* T0_13;
MTensorInitializationData Tinit;
mreal *P4;
mreal *P5;
mreal *P6;
mreal *P7;
mreal *P8;
mreal *P9;
mreal *P10;
mreal *P11;
mreal *P12;
MArgument FPA[3];
int err = 0;
Tinit = funStructCompile->GetInitializedMTensors(libData, 11);
T0_1 = MTensorInitializationData_getTensor(Tinit, 0);
T0_10 = MTensorInitializationData_getTensor(Tinit, 1);
T0_11 = MTensorInitializationData_getTensor(Tinit, 2);
T0_12 = MTensorInitializationData_getTensor(Tinit, 3);
T0_13 = MTensorInitializationData_getTensor(Tinit, 4);
T0_3 = MTensorInitializationData_getTensor(Tinit, 5);
T0_4 = MTensorInitializationData_getTensor(Tinit, 6);
T0_5 = MTensorInitializationData_getTensor(Tinit, 7);
T0_7 = MTensorInitializationData_getTensor(Tinit, 8);
T0_8 = MTensorInitializationData_getTensor(Tinit, 9);
T0_9 = MTensorInitializationData_getTensor(Tinit, 10);
I0_0 = A1;
R0_0 = A2;
I0_1 = A3;
B0_0 = I0_0 == I0_2;
if( !B0_0)
{
goto lab20;
}
B0_1 = I0_1 == I0_3;
if( !B0_1)
{
goto lab8;
}
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_0;
MArgument_getMTensorAddress(FPA[2]) = T0_4;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
MArgument_getMTensorAddress(FPA[0]) = T0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_1;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P5 = MTensor_getRealDataMacro(*T0_1);
goto lab18;
lab8:
B0_2 = I0_1 == I0_2;
if( !B0_2)
{
goto lab15;
}
R0_2 = (mreal) I0_3;
R0_3 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_1, 3, 1, &S0);
if( err)
{
goto error_label;
}
P5 = MTensor_getRealDataMacro(*T0_1);
P5[0] = R0_2;
P5[1] = R0_1;
P5[2] = R0_0;
P5[3] = R0_1;
P5[4] = R0_0;
P5[5] = R0_1;
P5[6] = R0_3;
P5[7] = R0_1;
P5[8] = R0_0;
P5[9] = R0_1;
P5[10] = R0_0;
P5[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_1;
MArgument_getMTensorAddress(FPA[1]) = T0_3;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P6 = MTensor_getRealDataMacro(*T0_3);
goto lab17;
lab15:
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_2;
MArgument_getMTensorAddress(FPA[2]) = T0_4;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
MArgument_getMTensorAddress(FPA[0]) = T0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_3;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P6 = MTensor_getRealDataMacro(*T0_3);
lab17:
MArgument_getMTensorAddress(FPA[0]) = T0_3;
MArgument_getMTensorAddress(FPA[1]) = T0_1;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P5 = MTensor_getRealDataMacro(*T0_1);
lab18:
MArgument_getMTensorAddress(FPA[0]) = T0_1;
MArgument_getMTensorAddress(FPA[1]) = T0_3;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P6 = MTensor_getRealDataMacro(*T0_3);
goto lab222;
lab20:
B0_1 = I0_0 == I0_5;
if( !B0_1)
{
goto lab39;
}
B0_2 = I0_1 == I0_3;
if( !B0_2)
{
goto lab27;
}
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_0;
MArgument_getMTensorAddress(FPA[2]) = T0_5;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P7 = MTensor_getRealDataMacro(*T0_5);
MArgument_getMTensorAddress(FPA[0]) = T0_5;
MArgument_getMTensorAddress(FPA[1]) = T0_3;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P6 = MTensor_getRealDataMacro(*T0_3);
goto lab37;
lab27:
B0_3 = I0_1 == I0_2;
if( !B0_3)
{
goto lab34;
}
R0_3 = (mreal) I0_3;
R0_2 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_3, 3, 1, &S0);
if( err)
{
goto error_label;
}
P6 = MTensor_getRealDataMacro(*T0_3);
P6[0] = R0_3;
P6[1] = R0_4;
P6[2] = R0_0;
P6[3] = R0_4;
P6[4] = R0_0;
P6[5] = R0_4;
P6[6] = R0_2;
P6[7] = R0_1;
P6[8] = R0_0;
P6[9] = R0_1;
P6[10] = R0_0;
P6[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_3;
MArgument_getMTensorAddress(FPA[1]) = T0_4;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
goto lab36;
lab34:
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_2;
MArgument_getMTensorAddress(FPA[2]) = T0_5;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P7 = MTensor_getRealDataMacro(*T0_5);
MArgument_getMTensorAddress(FPA[0]) = T0_5;
MArgument_getMTensorAddress(FPA[1]) = T0_4;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
lab36:
MArgument_getMTensorAddress(FPA[0]) = T0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_3;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P6 = MTensor_getRealDataMacro(*T0_3);
lab37:
MArgument_getMTensorAddress(FPA[0]) = T0_3;
MArgument_getMTensorAddress(FPA[1]) = T0_5;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P7 = MTensor_getRealDataMacro(*T0_5);
goto lab221;
lab39:
B0_2 = I0_0 == I0_4;
if( !B0_2)
{
goto lab82;
}
B0_3 = I0_1 == I0_3;
if( !B0_3)
{
goto lab46;
}
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_6;
MArgument_getMTensorAddress(FPA[2]) = T0_7;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
MArgument_getMTensorAddress(FPA[0]) = T0_7;
MArgument_getMTensorAddress(FPA[1]) = T0_5;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P7 = MTensor_getRealDataMacro(*T0_5);
goto lab80;
lab46:
B0_4 = I0_1 == I0_2;
if( !B0_4)
{
goto lab53;
}
R0_3 = (mreal) I0_3;
R0_2 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_5, 3, 1, &S0);
if( err)
{
goto error_label;
}
P7 = MTensor_getRealDataMacro(*T0_5);
P7[0] = R0_3;
P7[1] = R0_1;
P7[2] = R0_0;
P7[3] = R0_1;
P7[4] = R0_0;
P7[5] = R0_1;
P7[6] = R0_2;
P7[7] = R0_4;
P7[8] = R0_0;
P7[9] = R0_4;
P7[10] = R0_0;
P7[11] = R0_4;
}
MArgument_getMTensorAddress(FPA[0]) = T0_5;
MArgument_getMTensorAddress(FPA[1]) = T0_4;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
goto lab79;
lab53:
B0_5 = I0_1 == I0_5;
if( !B0_5)
{
goto lab60;
}
R0_2 = (mreal) I0_3;
R0_3 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_4, 3, 1, &S0);
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
P4[0] = R0_2;
P4[1] = R0_1;
P4[2] = R0_0;
P4[3] = R0_1;
P4[4] = R0_0;
P4[5] = R0_1;
P4[6] = R0_3;
P4[7] = R0_5;
P4[8] = R0_0;
P4[9] = R0_5;
P4[10] = R0_0;
P4[11] = R0_5;
}
MArgument_getMTensorAddress(FPA[0]) = T0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_7;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
goto lab78;
lab60:
B0_6 = I0_1 == I0_4;
if( !B0_6)
{
goto lab67;
}
R0_3 = (mreal) I0_3;
R0_2 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_7, 3, 1, &S0);
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
P8[0] = R0_3;
P8[1] = R0_1;
P8[2] = R0_0;
P8[3] = R0_1;
P8[4] = R0_0;
P8[5] = R0_1;
P8[6] = R0_2;
P8[7] = R0_6;
P8[8] = R0_0;
P8[9] = R0_6;
P8[10] = R0_0;
P8[11] = R0_6;
}
MArgument_getMTensorAddress(FPA[0]) = T0_7;
MArgument_getMTensorAddress(FPA[1]) = T0_8;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
goto lab77;
lab67:
B0_7 = I0_1 == I0_6;
if( !B0_7)
{
goto lab74;
}
R0_3 = (mreal) I0_3;
R0_2 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_8, 3, 1, &S0);
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
P9[0] = R0_3;
P9[1] = R0_1;
P9[2] = R0_0;
P9[3] = R0_1;
P9[4] = R0_0;
P9[5] = R0_1;
P9[6] = R0_2;
P9[7] = R0_1;
P9[8] = R0_0;
P9[9] = R0_1;
P9[10] = R0_0;
P9[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_8;
MArgument_getMTensorAddress(FPA[1]) = T0_9;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
goto lab76;
lab74:
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_2;
MArgument_getMTensorAddress(FPA[2]) = T0_10;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
MArgument_getMTensorAddress(FPA[0]) = T0_10;
MArgument_getMTensorAddress(FPA[1]) = T0_9;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
lab76:
MArgument_getMTensorAddress(FPA[0]) = T0_9;
MArgument_getMTensorAddress(FPA[1]) = T0_8;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
lab77:
MArgument_getMTensorAddress(FPA[0]) = T0_8;
MArgument_getMTensorAddress(FPA[1]) = T0_7;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
lab78:
MArgument_getMTensorAddress(FPA[0]) = T0_7;
MArgument_getMTensorAddress(FPA[1]) = T0_4;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
lab79:
MArgument_getMTensorAddress(FPA[0]) = T0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_5;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P7 = MTensor_getRealDataMacro(*T0_5);
lab80:
MArgument_getMTensorAddress(FPA[0]) = T0_5;
MArgument_getMTensorAddress(FPA[1]) = T0_4;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
goto lab220;
lab82:
B0_3 = I0_0 == I0_6;
if( !B0_3)
{
goto lab125;
}
B0_4 = I0_1 == I0_3;
if( !B0_4)
{
goto lab89;
}
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_6;
MArgument_getMTensorAddress(FPA[2]) = T0_8;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
MArgument_getMTensorAddress(FPA[0]) = T0_8;
MArgument_getMTensorAddress(FPA[1]) = T0_4;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
goto lab123;
lab89:
B0_5 = I0_1 == I0_2;
if( !B0_5)
{
goto lab96;
}
R0_3 = (mreal) I0_3;
R0_2 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_4, 3, 1, &S0);
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
P4[0] = R0_3;
P4[1] = R0_1;
P4[2] = R0_0;
P4[3] = R0_1;
P4[4] = R0_0;
P4[5] = R0_1;
P4[6] = R0_2;
P4[7] = R0_4;
P4[8] = R0_0;
P4[9] = R0_4;
P4[10] = R0_0;
P4[11] = R0_4;
}
MArgument_getMTensorAddress(FPA[0]) = T0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_7;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
goto lab122;
lab96:
B0_6 = I0_1 == I0_5;
if( !B0_6)
{
goto lab103;
}
R0_3 = (mreal) I0_3;
R0_2 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_7, 3, 1, &S0);
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
P8[0] = R0_3;
P8[1] = R0_6;
P8[2] = R0_0;
P8[3] = R0_6;
P8[4] = R0_0;
P8[5] = R0_6;
P8[6] = R0_2;
P8[7] = R0_5;
P8[8] = R0_0;
P8[9] = R0_5;
P8[10] = R0_0;
P8[11] = R0_5;
}
MArgument_getMTensorAddress(FPA[0]) = T0_7;
MArgument_getMTensorAddress(FPA[1]) = T0_8;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
goto lab121;
lab103:
B0_7 = I0_1 == I0_4;
if( !B0_7)
{
goto lab110;
}
R0_3 = (mreal) I0_3;
R0_2 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_8, 3, 1, &S0);
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
P9[0] = R0_3;
P9[1] = R0_5;
P9[2] = R0_0;
P9[3] = R0_5;
P9[4] = R0_0;
P9[5] = R0_5;
P9[6] = R0_2;
P9[7] = R0_6;
P9[8] = R0_0;
P9[9] = R0_6;
P9[10] = R0_0;
P9[11] = R0_6;
}
MArgument_getMTensorAddress(FPA[0]) = T0_8;
MArgument_getMTensorAddress(FPA[1]) = T0_9;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
goto lab120;
lab110:
B0_8 = I0_1 == I0_6;
if( !B0_8)
{
goto lab117;
}
R0_3 = (mreal) I0_3;
R0_2 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_9, 3, 1, &S0);
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
P10[0] = R0_3;
P10[1] = R0_4;
P10[2] = R0_0;
P10[3] = R0_4;
P10[4] = R0_0;
P10[5] = R0_4;
P10[6] = R0_2;
P10[7] = R0_1;
P10[8] = R0_0;
P10[9] = R0_1;
P10[10] = R0_0;
P10[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_9;
MArgument_getMTensorAddress(FPA[1]) = T0_10;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
goto lab119;
lab117:
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_2;
MArgument_getMTensorAddress(FPA[2]) = T0_11;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P12 = MTensor_getRealDataMacro(*T0_11);
MArgument_getMTensorAddress(FPA[0]) = T0_11;
MArgument_getMTensorAddress(FPA[1]) = T0_10;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
lab119:
MArgument_getMTensorAddress(FPA[0]) = T0_10;
MArgument_getMTensorAddress(FPA[1]) = T0_9;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
lab120:
MArgument_getMTensorAddress(FPA[0]) = T0_9;
MArgument_getMTensorAddress(FPA[1]) = T0_8;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
lab121:
MArgument_getMTensorAddress(FPA[0]) = T0_8;
MArgument_getMTensorAddress(FPA[1]) = T0_7;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
lab122:
MArgument_getMTensorAddress(FPA[0]) = T0_7;
MArgument_getMTensorAddress(FPA[1]) = T0_4;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
lab123:
MArgument_getMTensorAddress(FPA[0]) = T0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_7;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
goto lab219;
lab125:
B0_4 = I0_0 == I0_7;
if( !B0_4)
{
goto lab170;
}
B0_5 = I0_1 == I0_3;
if( !B0_5)
{
goto lab132;
}
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_6;
MArgument_getMTensorAddress(FPA[2]) = T0_9;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
MArgument_getMTensorAddress(FPA[0]) = T0_9;
MArgument_getMTensorAddress(FPA[1]) = T0_7;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
goto lab168;
lab132:
B0_6 = I0_1 == I0_2;
if( !B0_6)
{
goto lab139;
}
R0_3 = (mreal) I0_3;
R0_2 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_7, 3, 1, &S0);
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
P8[0] = R0_3;
P8[1] = R0_1;
P8[2] = R0_0;
P8[3] = R0_1;
P8[4] = R0_0;
P8[5] = R0_1;
P8[6] = R0_2;
P8[7] = R0_4;
P8[8] = R0_0;
P8[9] = R0_1;
P8[10] = R0_0;
P8[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_7;
MArgument_getMTensorAddress(FPA[1]) = T0_8;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
goto lab167;
lab139:
B0_7 = I0_1 == I0_5;
if( !B0_7)
{
goto lab147;
}
R0_3 = R0_6 * R0_0;
R0_2 = (mreal) I0_3;
R0_7 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_8, 3, 1, &S0);
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
P9[0] = R0_2;
P9[1] = R0_1;
P9[2] = R0_0;
P9[3] = R0_1;
P9[4] = R0_0;
P9[5] = R0_1;
P9[6] = R0_7;
P9[7] = R0_4;
P9[8] = R0_3;
P9[9] = R0_1;
P9[10] = R0_0;
P9[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_8;
MArgument_getMTensorAddress(FPA[1]) = T0_9;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
goto lab166;
lab147:
B0_8 = I0_1 == I0_4;
if( !B0_8)
{
goto lab155;
}
R0_3 = R0_5 * R0_0;
R0_2 = (mreal) I0_3;
R0_7 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_9, 3, 1, &S0);
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
P10[0] = R0_2;
P10[1] = R0_1;
P10[2] = R0_0;
P10[3] = R0_1;
P10[4] = R0_0;
P10[5] = R0_1;
P10[6] = R0_7;
P10[7] = R0_4;
P10[8] = R0_3;
P10[9] = R0_1;
P10[10] = R0_3;
P10[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_9;
MArgument_getMTensorAddress(FPA[1]) = T0_10;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
goto lab165;
lab155:
B0_9 = I0_1 == I0_6;
if( !B0_9)
{
goto lab162;
}
R0_2 = (mreal) I0_3;
R0_7 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_10, 3, 1, &S0);
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
P11[0] = R0_2;
P11[1] = R0_1;
P11[2] = R0_0;
P11[3] = R0_1;
P11[4] = R0_0;
P11[5] = R0_1;
P11[6] = R0_7;
P11[7] = R0_1;
P11[8] = R0_0;
P11[9] = R0_1;
P11[10] = R0_0;
P11[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_10;
MArgument_getMTensorAddress(FPA[1]) = T0_11;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P12 = MTensor_getRealDataMacro(*T0_11);
goto lab164;
lab162:
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_2;
MArgument_getMTensorAddress(FPA[2]) = T0_12;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
MArgument_getMTensorAddress(FPA[0]) = T0_12;
MArgument_getMTensorAddress(FPA[1]) = T0_11;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P12 = MTensor_getRealDataMacro(*T0_11);
lab164:
MArgument_getMTensorAddress(FPA[0]) = T0_11;
MArgument_getMTensorAddress(FPA[1]) = T0_10;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
lab165:
MArgument_getMTensorAddress(FPA[0]) = T0_10;
MArgument_getMTensorAddress(FPA[1]) = T0_9;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
lab166:
MArgument_getMTensorAddress(FPA[0]) = T0_9;
MArgument_getMTensorAddress(FPA[1]) = T0_8;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
lab167:
MArgument_getMTensorAddress(FPA[0]) = T0_8;
MArgument_getMTensorAddress(FPA[1]) = T0_7;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
lab168:
MArgument_getMTensorAddress(FPA[0]) = T0_7;
MArgument_getMTensorAddress(FPA[1]) = T0_8;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
goto lab218;
lab170:
B0_5 = I0_0 == I0_8;
if( !B0_5)
{
goto lab215;
}
B0_6 = I0_1 == I0_3;
if( !B0_6)
{
goto lab177;
}
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_6;
MArgument_getMTensorAddress(FPA[2]) = T0_10;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
MArgument_getMTensorAddress(FPA[0]) = T0_10;
MArgument_getMTensorAddress(FPA[1]) = T0_8;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
goto lab213;
lab177:
B0_7 = I0_1 == I0_2;
if( !B0_7)
{
goto lab184;
}
R0_2 = (mreal) I0_3;
R0_7 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_8, 3, 1, &S0);
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
P9[0] = R0_2;
P9[1] = R0_1;
P9[2] = R0_0;
P9[3] = R0_1;
P9[4] = R0_0;
P9[5] = R0_1;
P9[6] = R0_7;
P9[7] = R0_4;
P9[8] = R0_0;
P9[9] = R0_1;
P9[10] = R0_0;
P9[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_8;
MArgument_getMTensorAddress(FPA[1]) = T0_9;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
goto lab212;
lab184:
B0_8 = I0_1 == I0_5;
if( !B0_8)
{
goto lab192;
}
R0_2 = R0_6 * R0_0;
R0_7 = (mreal) I0_3;
R0_8 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_9, 3, 1, &S0);
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
P10[0] = R0_7;
P10[1] = R0_1;
P10[2] = R0_2;
P10[3] = R0_1;
P10[4] = R0_0;
P10[5] = R0_4;
P10[6] = R0_8;
P10[7] = R0_4;
P10[8] = R0_2;
P10[9] = R0_1;
P10[10] = R0_0;
P10[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_9;
MArgument_getMTensorAddress(FPA[1]) = T0_10;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
goto lab211;
lab192:
B0_9 = I0_1 == I0_4;
if( !B0_9)
{
goto lab200;
}
R0_7 = R0_5 * R0_0;
R0_8 = (mreal) I0_3;
R0_9 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_10, 3, 1, &S0);
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
P11[0] = R0_8;
P11[1] = R0_1;
P11[2] = R0_7;
P11[3] = R0_1;
P11[4] = R0_0;
P11[5] = R0_4;
P11[6] = R0_9;
P11[7] = R0_4;
P11[8] = R0_7;
P11[9] = R0_1;
P11[10] = R0_0;
P11[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_10;
MArgument_getMTensorAddress(FPA[1]) = T0_11;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P12 = MTensor_getRealDataMacro(*T0_11);
goto lab210;
lab200:
B0_10 = I0_1 == I0_6;
if( !B0_10)
{
goto lab207;
}
R0_8 = (mreal) I0_3;
R0_9 = (mreal) I0_3;
{
mint S0 = 12;
err = funStructCompile->MTensor_allocate(T0_11, 3, 1, &S0);
if( err)
{
goto error_label;
}
P12 = MTensor_getRealDataMacro(*T0_11);
P12[0] = R0_8;
P12[1] = R0_4;
P12[2] = R0_0;
P12[3] = R0_4;
P12[4] = R0_0;
P12[5] = R0_4;
P12[6] = R0_9;
P12[7] = R0_1;
P12[8] = R0_0;
P12[9] = R0_1;
P12[10] = R0_0;
P12[11] = R0_1;
}
MArgument_getMTensorAddress(FPA[0]) = T0_11;
MArgument_getMTensorAddress(FPA[1]) = T0_12;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
goto lab209;
lab207:
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_2;
MArgument_getMTensorAddress(FPA[2]) = T0_13;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
MArgument_getMTensorAddress(FPA[0]) = T0_13;
MArgument_getMTensorAddress(FPA[1]) = T0_12;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
lab209:
MArgument_getMTensorAddress(FPA[0]) = T0_12;
MArgument_getMTensorAddress(FPA[1]) = T0_11;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P12 = MTensor_getRealDataMacro(*T0_11);
lab210:
MArgument_getMTensorAddress(FPA[0]) = T0_11;
MArgument_getMTensorAddress(FPA[1]) = T0_10;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
lab211:
MArgument_getMTensorAddress(FPA[0]) = T0_10;
MArgument_getMTensorAddress(FPA[1]) = T0_9;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P10 = MTensor_getRealDataMacro(*T0_9);
lab212:
MArgument_getMTensorAddress(FPA[0]) = T0_9;
MArgument_getMTensorAddress(FPA[1]) = T0_8;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
lab213:
MArgument_getMTensorAddress(FPA[0]) = T0_8;
MArgument_getMTensorAddress(FPA[1]) = T0_10;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
goto lab217;
lab215:
MArgument_getIntegerAddress(FPA[0]) = &I0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_14;
MArgument_getMTensorAddress(FPA[2]) = T0_11;
err = FP0(libData, 2, FPA, FPA[2]);/*  CoerceTensor  */
if( err)
{
goto error_label;
}
P12 = MTensor_getRealDataMacro(*T0_11);
MArgument_getMTensorAddress(FPA[0]) = T0_11;
MArgument_getMTensorAddress(FPA[1]) = T0_10;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P11 = MTensor_getRealDataMacro(*T0_10);
lab217:
MArgument_getMTensorAddress(FPA[0]) = T0_10;
MArgument_getMTensorAddress(FPA[1]) = T0_8;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P9 = MTensor_getRealDataMacro(*T0_8);
lab218:
MArgument_getMTensorAddress(FPA[0]) = T0_8;
MArgument_getMTensorAddress(FPA[1]) = T0_7;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P8 = MTensor_getRealDataMacro(*T0_7);
lab219:
MArgument_getMTensorAddress(FPA[0]) = T0_7;
MArgument_getMTensorAddress(FPA[1]) = T0_4;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P4 = MTensor_getRealDataMacro(*T0_4);
lab220:
MArgument_getMTensorAddress(FPA[0]) = T0_4;
MArgument_getMTensorAddress(FPA[1]) = T0_5;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P7 = MTensor_getRealDataMacro(*T0_5);
lab221:
MArgument_getMTensorAddress(FPA[0]) = T0_5;
MArgument_getMTensorAddress(FPA[1]) = T0_3;
err = FP1(libData, 1, FPA, FPA[1]);/*  CopyTensor  */
if( err)
{
goto error_label;
}
P6 = MTensor_getRealDataMacro(*T0_3);
lab222:
funStructCompile->MTensor_copy(Res, *T0_3);
error_label:
funStructCompile->ReleaseInitializedMTensors(Tinit);
funStructCompile->WolframLibraryData_cleanUp(libData, 1);
return err;
}

