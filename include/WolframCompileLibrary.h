/*************************************************************************
                        Mathematica source file

        Copyright 1986 through 2000 by Wolfram Research Inc.

This material contains trade secrets and may be registered with the
U.S. Copyright Office as an unpublished work, pursuant to Title 17,
U.S. Code, Section 408.  Unauthorized copying, adaptation, distribution
or display is prohibited.

$Id: WolframCompileLibrary.h,v 1.20 2010/09/24 18:43:40 rknapp Exp $

*************************************************************************/

/*
  WARNING,  the definitions in this file are not guaranteed to work from 
  one version of Mathematica to another.  Do not use these functions directly.
*/



#ifndef WOLFRAMCOMPILELIBRARY_H
#define WOLFRAMCOMPILELIBRARY_H

#define WolframCompileLibraryVersion 1

#if !(defined(MATHEMATICA_KERNEL) || defined(MATHEMATICA_RUNTIME))

#include <stddef.h>

typedef struct TENSOR_DETAIL_DATA_STRUCT *TensorDetail;

typedef struct TENSOR_PROPERTY_DATA_STRUCT
{
	TensorDetail detail;
	mint *dims;
	mint rank;
	int type;
} *TensorProperty;

typedef struct M_TENSOR_DATA_STRUCT 
{
	void *data_pointer;   
	size_t bs; 
	mint rc;   
} *MTensorData;

/* Incomplete type in WolframLibrary.h */
/* struct M_TENSOR_STRUCT */
/* { */
/* 	MTensorData data; */
/* 	TensorProperty properties; */
/* 	mint flattened_length;  */
/* }; */

struct M_TENSOR_STRUCT
{
    void *data_pointer;
    mint dim;
};

//#define MTensor_getDimensionsMacro(mt)		((mt)->properties->dims)
#define MTensor_getDimensionsMacro(mt)		(&((mt)->dim))

//#define MTensor_getIntegerDataMacro(mt)		((mint *) ((mt)->data->data_pointer))
#define MTensor_getRealDataMacro(mt)		((mreal *) ((mt)->data_pointer))
//#define MTensor_getComplexDataMacro(mt)		((mcomplex *) ((mt)->data->data_pointer))

//#define MTensor_getFlattenedLengthMacro(mt) ((mt)->flattened_length)

#endif

typedef struct M_TENSOR_INITIALIZATION_DATA_STRUCT
{
	MTensor *tensors;
	mint n;
	int in_use;
} *MTensorInitializationData;

#ifndef _MATHLINK_H
typedef struct MLINK_STRUCT* MLINK;
#endif

#define MTensorInitializationData_getTensor(data, i)		(&((data)->tensors[(i)]))

typedef struct st_WolframRuntimeData* WolframRuntimeData;

typedef int (*LibraryFunctionPointer)(WolframLibraryData, mint, MArgument *, MArgument);
typedef mint (*UnaryMathFunctionPointer)(void *, const void *, const mint, const mint *, const unsigned int);
typedef mint (*BinaryMathFunctionPointer)(void *, const void *, const void *, const mint, const mint *, const unsigned int);

typedef struct st_WolframCompileLibrary_Functions
	{
/*	mint VersionNumber; */
	MTensorInitializationData (*GetInitializedMTensors)(struct st_WolframLibraryData*, mint);
	void (*ReleaseInitializedMTensors)(MTensorInitializationData);
	void (*WolframLibraryData_cleanUp)(struct st_WolframLibraryData*, int);
/*
	MTensor (*MTensor_init)( void);
*/
	int (*MTensor_allocate)(MTensor *, int, mint, mint*);
	void (*MTensor_copy)(MTensor *, MTensor);
/*
	int (*MTensor_copyUnique)(MTensor *, MTensor);
	int (*MTensor_insertMTensor)( MTensor, MTensor, mint *);
	int (*MTensor_getMTensorInitialized)(MTensor *, MTensor, mint *, mint);
	int (*MTensor_getPart)(MTensor *, MTensor, mint, int *, void **);
	int (*MTensor_setPart)(MTensor *, MTensor, mint, int *, void **);
	UnaryMathFunctionPointer (*getUnaryMathFunction)(int, int);
	int (*Math_T_T)(int, const unsigned int, MTensor, int, MTensor *); // is it a T .* T?
	int (*Math_V_V)(int, const unsigned int, int, void *, int, void *);
	BinaryMathFunctionPointer (*getBinaryMathFunction)(int, int, int);
	int (*Math_TT_T)(int, const unsigned int, MTensor, MTensor, int, MTensor *);
	int (*Math_VV_V)(int, const unsigned int, int, void *, int, void *, int, void *);*/
	mbool (*Compare_R)(int, mreal, mint, mreal *);
/*	mbool (*Compare_C)(int, mreal, mint, mcomplex *);
	void *(*getExpressionFunctionPointer)(struct st_WolframLibraryData*, const char *);
	int (*evaluateFunctionExpression)(struct st_WolframLibraryData*, void *, mint, mint, mint, int *, void **, int, mint, void *);
	void **(*getArgumentSpace)(struct st_WolframLibraryData*, mint);

	LibraryFunctionPointer (*getLibraryFunctionPointer)(char *, char *);
*/
	LibraryFunctionPointer (*getFunctionCallPointer)(const char *);
/*
	mbool (*checkFloatingPointException)(void *, int, const unsigned int);
	MTensor (*getRankZeroMTensor)(void *, int, mint);*/
	}* WolframCompileLibrary_Functions;

#endif
