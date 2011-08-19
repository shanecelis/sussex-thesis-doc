/*
  run-simulation-rkqs.c
*/
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <string.h>
#include <WolframRTL.h>
#include "frogRHS.h"
#include "rkqs.h"
#include "run-simulation.h"

//static MTensor state, constants, results, points;
static WolframLibraryData libData = 0;
static double constants[CONSTANTS_COUNT];

int sim_init()
{

  int err = 0;

  libData = WolframLibraryData_new(WolframLibraryVersion);   

  err = Initialize_frogRHS(libData);

  return err;

}

int sim_uninit()
{

  int err = 0;

  Uninitialize_frogRHS(libData);

  WolframLibraryData_free(libData);

  return err;
}

int experiment_name(const char *name) 
{
  /* Names must be in the same order as experimentNames in experiments.m. */
  char *names[] = { "An", "Bn", "Ap", "Bp", "Ao", "Bo" };
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
  *f0 = points[2 * 3 + 1];  // or (POINTS_COUNT/2 + 1)
}

int experiment_phase_count(const char *expName, int *phase_count)
{
  double results[POINTS_COUNT]; 
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
  int err;
  struct M_TENSOR_STRUCT Tpoints; 
  Tpoints.dim = POINTS_COUNT;
  Tpoints.data_pointer = pointsResult;
  MTensor TTpoints = &Tpoints;
  int exp_no = experiment_name(expName);

  assert(exp_no != 0);
  err = experiments(libData, exp_no, timeMax, phase, &TTpoints);
  return err;
}
int frog_deriv_dummy(double t, double state[], double dqdt[])
{
  printf("FROG_DERIV BEGIN\n");
  int i;
  for (i = 0; i < STATE_COUNT; i++)
    dqdt[i] = 0.01;
  printf("FROG_DERIV END\n");
  return 0;
}


int frog_deriv(double t, double state[], double dqdt[])
{
  // XXX Where do constants come from?  static?  Yeah.  
  int err;//, i;
  struct M_TENSOR_STRUCT Tstate, Tconstants, Tresult;
  Tstate.dim = STATE_COUNT;
  Tstate.data_pointer = state;
  Tconstants.dim = CONSTANTS_COUNT;
  Tconstants.data_pointer = constants;
  Tresult.dim = STATE_COUNT;
  Tresult.data_pointer = dqdt;
  MTensor TTresult = &Tresult;
  
  err = frogRHS(libData, &Tstate, &Tconstants, &TTresult);
  /* printf("deriv "); */
  /* for (i = 0; i < STATE_COUNT; i++) */
  /*   printf("%f ", dqdt[i]); */
  /* printf("\n"); */
  return err;
}

int run_simulation(double *init_state, double stepSize, double *constantsArg, 
                   double time, double *state)
{
  int    i, j, err = 0;
  double t, torig;
  double h, hnext, hdid, hmin, hmean, hmax;
  double dstatedt[STATE_COUNT], state_scale[STATE_COUNT];

  assert(init_state != NULL);
  assert(constantsArg != NULL);
  h = stepSize;
  t = torig = init_state[0];
  
  for (i = 0; i < STATE_COUNT; i++)
    state[i] = init_state[i];

  for (i = 0; i < CONSTANTS_COUNT; i++)
    constants[i] = constantsArg[i];
  
  j = 0;
  hmin = HUGE;
  hmax = -HUGE;
  hmean = 0.;
  while((t - torig) < time) {
    err = frog_deriv(t, state, dstatedt);
    if (err)
      return err; 
    for(i = 0; i < STATE_COUNT; i++)
      state_scale[i] = fabs(state[i]) + fabs(dstatedt[i] * h) + TINY;
    err = rkqs(state, dstatedt, STATE_COUNT, &t, 
               h, 1., state_scale, &hdid, &hnext, frog_deriv);
    hmean += hdid;
    hmin = fmin(hmin, hdid);
    hmax = fmax(hmax, hdid);
    if (j % 1000) {
      //printf("t = %f, h = %f, hnext = %f, hdid = %f, s[0] = %f\n", t, h, hnext, hdid, state[0]);
    }
/*    if (fabs(hdid) < 1e-7)
      return 1;*/
    h = hnext;
    if (err)
      return err;
    t = state[0];
    j++;
  }
  hmean /= (double) j;

  printf("hmin = %f, hmean = %f, hmax = %f\n", hmin, hmean, hmax);
  return 0;
}



/*
  Given the constants array, it places zeros such that the tail brain
  and feet brain will operate independently.
 */
void lobotomise_brains(double *constants)
{
  /* These indexes were found in 'Lobotomise NNs.nb'. */
     
  int indexes[] = {1, 2, 3, 4, 5, 10, 15, 20, 53, 54, 67, 68, 81, 82, 
                   95, 96, 41, 42, 43, 44, 45, 46, 47, 48};
  int i, index_count = 24;

  for (i = 0; i < index_count; i++) {
    constants[indexes[i]] = 0.0;
  }
}
