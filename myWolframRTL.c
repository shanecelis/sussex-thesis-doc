#include <WolframRTL.h>
#include <stdlib.h>
#include <stdio.h>
#include <assert.h>


void WolframLibraryData_free(WolframLibraryData libData)
{
  free(libData->compileLibraryFunctions);
  free(libData);
}

/* 
   Only handle one dimensional vectors.
 */
int myMTensor_new(mint type, mint rank, mint const* dims, MTensor *result)
{
  //printf("myMTensor_new rank %d dims %d\n", rank, dims[0]);
  
  // All of these will be rank 1 real vectors.  Will not account for other types.
  return myMTensor_allocate(result, type, rank, dims);

  /* (*result)->data = (MTensorData) malloc(sizeof(struct M_TENSOR_DATA_STRUCT)); */
  /* (*result)->properties = (TensorProperty) malloc(sizeof(struct TENSOR_PROPERTY_DATA_STRUCT)); */
  /* (*result)->properties->dims = (mint *) malloc(sizeof(mint)); */
  /* (*result)->properties->dims[0] = dims[0]; */
  /* (*result)->data->data_pointer = malloc(sizeof(double) * dims[0]); */
  /* (*result)->flattened_length = dims[0]; */
}

void myMTensor_free( MTensor a)
{
  assert(a != NULL);
  free(a->data_pointer);
  free(a);
}

MTensorInitializationData myGetInitializedMTensors(struct st_WolframLibraryData* libdata , mint num)
{
  MTensorInitializationData res;
  res = (MTensorInitializationData) malloc(sizeof(struct M_TENSOR_INITIALIZATION_DATA_STRUCT));
  res->tensors = malloc(sizeof (MTensor) * num);
  res->n = num;
  res->in_use = 1;
  mint i;
  for (i = 0; i < num; i++) {
    res->tensors[i] = NULL;
  }
  return res;
}

mbool myCompare_R(int op, mreal unknown, mint len, mreal * vector)
{
  switch(op) {
  case 3:
    return (vector[0] < vector[1]);
  case 4:
    return (vector[0] <= vector[1]);
  case 5:
    return (vector[0] == vector[1]);
  case 6:
    return (vector[0] >= vector[1]);
  case 7:
    return (vector[0] > vector[1]);
  default:
    fprintf(stderr, "error: myCompare_R got op %d\n", op);
    return 0;
  }
}

int myMTensor_allocate(MTensor *result, int type,  mint rank, mint* dims)
{
  assert(rank == 1);
  assert(type == 3);
  *result = (MTensor) malloc(sizeof(struct M_TENSOR_STRUCT));
  (*result)->data_pointer = malloc(sizeof(double) * dims[0]); 
  (*result)->dim = dims[0]; 
  return 0;
}

void myMTensor_copy(MTensor *Tdest, MTensor Tsrc)
{
  mreal *dest     = MTensor_getRealDataMacro(*Tdest);
  mint *dest_dims = MTensor_getDimensionsMacro(*Tdest);
  mreal *src      = MTensor_getRealDataMacro(Tsrc);
  mint *src_dims  = MTensor_getDimensionsMacro(Tsrc);
  mint i;
  for (i = 0; i < dest_dims[0]; i++)
    dest[i] = src[i];
}

/* return true if successful; zero otherwise. */
mbool myCopyTensor(WolframLibraryData libData, mint rank, MTensor src, MTensor *dest)
{
  assert(rank == 1);
  myMTensor_copy(dest, src);
  return 1;
}

void myNOOP()
{
  
}

void myReleaseInitializedMTensors(MTensorInitializationData a)
{
  mint i;
  for (i = 0; i < a->n; i++)
    myMTensor_free(a->tensors[i]);
  free(a);
}

void myWolframLibraryData_cleanUp(WolframLibraryData libData, int b)
{

}

mreal* myMTensor_getRealData( MTensor Tdest)
{
  return MTensor_getRealDataMacro(Tdest);
}

// FP0 = funStructCompile->getBinaryMathFunction(263, 2, 3);/*  Power  */
BinaryMathFunctionPointer mygetBinaryMathFunction(int a, int b, int c)
{

}

LibraryFunctionPointer mygetFunctionCallPointer(const char *name)
{
  if (strcmp(name, "CopyTensor") == 0)
    return myCopyTensor;
  else {
    fprintf(stderr, "error: no function '%s' available.\n", name);
    return NULL;
  }
}

WolframLibraryData WolframLibraryData_new(mint version)
{
  WolframLibraryData libData;
  libData = (WolframLibraryData) malloc(sizeof(struct st_WolframLibraryData));
  libData->compileLibraryFunctions = (WolframCompileLibrary_Functions) malloc(sizeof(struct st_WolframCompileLibrary_Functions));
  libData->compileLibraryFunctions->GetInitializedMTensors = myGetInitializedMTensors;
  libData->compileLibraryFunctions->Compare_R = myCompare_R;
  libData->compileLibraryFunctions->MTensor_allocate = myMTensor_allocate;
  libData->compileLibraryFunctions->MTensor_copy = myMTensor_copy;
  libData->compileLibraryFunctions->ReleaseInitializedMTensors = myReleaseInitializedMTensors;
  libData->compileLibraryFunctions->WolframLibraryData_cleanUp = myWolframLibraryData_cleanUp;
  libData->compileLibraryFunctions->getFunctionCallPointer = mygetFunctionCallPointer;
  //libData->compileLibraryFunctions->NOOP = myNOOP;
  libData->MTensor_new = myMTensor_new;
  libData->MTensor_free = myMTensor_free;
  libData->MTensor_getRealData = myMTensor_getRealData;
  return libData;
}
