#include <stdio.h>
#include "runSimulation.h"
#include "WolframRTL.h"
#include "run-simulation.h"

static MTensor state, constants, results, points;
static WolframLibraryData libData = 0;


int sim_init()
{

  int err = 0;
  mint type, rank, dims[1];

  type = MType_Real;
  rank = 1;

  libData = WolframLibraryData_new(WolframLibraryVersion);   

  dims[0] = STATE_COUNT;
  err = (*(libData->MTensor_new))(type, rank, dims, &state);
  if (err) goto clean_state;

  dims[0] = STATE_COUNT;
  err = (*(libData->MTensor_new))(type, rank, dims, &results);
  if (err) goto clean_results;

  dims[0] = CONSTANTS_COUNT;
  err = (*(libData->MTensor_new))(type, rank, dims, &constants);
  if (err) goto clean_constants;

  dims[0] = POINTS_COUNT;
  err = (*(libData->MTensor_new))(type, rank, dims, &points);
  if (err) goto clean_points;


  err = Initialize_runSimulation(libData);
  if (err) goto clean_init;

  Initialize_experiments(libData);
  if (err) goto clean_init;


  goto no_error;

clean_init:
clean_points:
  libData->MTensor_free(points);
clean_constants:
  libData->MTensor_free(constants);
clean_results:
  libData->MTensor_free(results);    
clean_state: 
  libData->MTensor_free(state);

no_error:
  return err;

}

int sim_uninit()
{

  int err = 0;

  Uninitialize_experiments(libData);

  Uninitialize_runSimulation(libData);



clean_init:
clean_constants:
  libData->MTensor_free(constants);
clean_results:
  libData->MTensor_free(results);    
clean_state: 
  libData->MTensor_free(state);

  return err;
}

int experiment_name(const char *name)
{
  char *names[] = { "0", "1", "Ap", "Bp", "Ao", "Bo" };
  int i, nameCount = 6;
  for (i = 0; i < nameCount; i++)
  {
    if (strcmp(name, names[i]) == 0)
      return i + 1;
  }
  return 0;
}

/* 
   Return the beginning state of the tail and feet length.
*/
void experiment_init_state(double *points, double *t0, double *f0)
{
  *t0 = points[1];
  *f0 = points[2 * 3 + 1];
}

int experiment_phase_count(const char *expName, int *phase_count)
{
  double results[POINTS_COUNT]; // XXX this is a bit off.  
  int err;
  err = experiment_points(expName, 0.0, 0, results);
  if (err) {
    return err;
  } else {
    *phase_count = (int) results[0];
    return 0;
  }
}

int experiment_points(const char *expName, double timeMax, 
                      int phase, double *pointsResult) 
{
  double *pointsData;
  int i, err;

  err = experiments(libData, experiment_name(expName), timeMax, phase, &points);
  pointsData = libData->MTensor_getRealData( points );
  for (i = 0; i < POINTS_COUNT; i++) {
    pointsResult[i] = pointsData[i];

  }

  return err;
}

int run_simulation(double *stateArg, double timeArg, double *constantsArg, 
                   double *stateResult)
{
  int err = 0, i;
  double *data, *stateData, *result;
  double pointsData[POINTS_COUNT];

  stateData = libData->MTensor_getRealData( state );

  if (stateArg) {
    for(i = 0; i < STATE_COUNT; i++)
      stateData[i] = stateArg[i];
  } else {
    for(i = 0; i < STATE_COUNT; i++)
      stateData[i] = 0.01;
  }
    
  stateData[22] = 1.0; // tail length
  stateData[23] = 0.1; // feet length
  stateData[24] = 0.0; // recording variable

  data = libData->MTensor_getRealData( constants );
  if (constantsArg) {
    for(i = 0; i < CONSTANTS_COUNT; i++)
      data[i] = constantsArg[i];
  } else {
    for(i = 0; i < CONSTANTS_COUNT; i++)
      data[i] = 0.1;

  }
    
//libData = WolframLibraryData_new(WolframLibraryVersion);   
  // Some set up has to happen before I can initialize the tadpoleSolver.
  //
  // http://www.wolfram.com/mathematica/new-in-8/integrated-c-workflow/create-standalone-executables-using-compiled-funct.html
  //
  // http://rcabreral.blogspot.com/2011/04/mathematica-as-c-code-generator.html

  char *expName = "Bo";
  mint phase = 3;
  mreal time = 20.0;

  experiment_points(expName, time, phase, pointsData);
  for (i = 0; i < POINTS_COUNT; i++) {
    data[CONSTANTS_COUNT - POINTS_COUNT + i] = pointsData[i];
  }

  experiment_init_state(pointsData, 
                        stateData + TAILSTATE_BEGIN, 
                        stateData + TAILSTATE_BEGIN + 1);


  // Copy this points data into the constants array.

  err = runSimulation(libData, state, time, constants, &results);

  data = libData->MTensor_getRealData( results );
  for(i = 0; i < STATE_COUNT; i++) {
    stateResult[i] = data[i];
  }


  return err;
}
