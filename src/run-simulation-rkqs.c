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
  char *names[] = { "An", "Bn", "Ap", "Bp", "Ao", "Bo", "Bq" };
  int i, namesCount = 7;
  for (i = 0; i < namesCount; i++)
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


int frog_deriv(double t, double state[], double dqdt[], void *context) 
{
  // XXX Where do constants come from?  static?  Yeah.  
  int err;//, i;
  double *constants = (double *) context;
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

void process_collision(double *s)
{
  int i;
  for (i = 4; i <= 8; i++) {
    if ((s[i] >  M_PI_2 && s[i + QSTATE_COUNT] > 0.) || 
        (s[i] < -M_PI_2 && s[i + QSTATE_COUNT] < 0.))
      s[i + QSTATE_COUNT] *= -0.8;
  }
}

#ifdef COLLISIONS
/*
  The function detect_collision(s) = 0. when a collision has happened.
  Use it to check for a sign change.
 */
double detect_collision(double *s)
{
  double result;
  int i;
  result = 1.0;
  for (i = 4; i <= 8; i++)
    result *= ((s[Q_BEGIN(i)] - M_PI_2) * (s[Q_BEGIN(i)] + M_PI_2));
  return result;
}
#endif

int run_simulation(double *init_state, double step_size, 
                   double *constants_arg, double time, 
                   double *state_result, int (*continue_loop)(void))
{
  int    i, j, err = 0, ec = 0; /* ec = exit-code */
  double t, torig;
  double h, hnext, hmin, hmean, hmax;
  double constants[CONSTANTS_COUNT], dstatedt[STATE_COUNT], 
    temp_state_array[STATE_COUNT], *next_state, *state, hdid, *temp_state;
#ifdef RKQS
  double state_scale[STATE_COUNT]
#endif 
 
  assert(init_state != NULL);
  assert(constants_arg != NULL);
  assert(state_result != NULL);
  h = step_size;
  t = torig = init_state[0];
  state = state_result;
  next_state = temp_state_array;
  
  for (i = 0; i < STATE_COUNT; i++) 
    state[i] = init_state[i];

  for (i = 0; i < CONSTANTS_COUNT; i++)
    constants[i] = constants_arg[i];
  
  //j = 0;
  hmin = HUGE;
  hmax = -HUGE;
  hmean = 0.;
  //while((t - torig) < time) {
  for (j = 0; j < MAX_STEPS; j++) {
    err = frog_deriv(t, state, dstatedt, constants); 
    if (err)
      return (1 << 8 | err); 
#ifdef RKQS
    {
    for(i = 0; i < STATE_COUNT; i++) 
      state_scale[i] = fabs(state[i]) + fabs(dstatedt[i] * h) + TINY;

    err = rkqs(state, dstatedt, STATE_COUNT, &t, 
               h, 1.e-5, state_scale, &hdid, &hnext, next_state, 
               &frog_deriv, constants);

#ifdef COLLISIONS
    if (detect_collision(next_state) * detect_collision(state) < 0.0) {
      //printf("collision detected for hdid %f\n", hdid);
      if (hdid > step_size ) {
        // A collision has happened and the step size is too large.
        h = step_size;
        continue;
      }
    }
#endif //COLLISIONS
    hmean += hdid;
    hmin = fmin(hmin, hdid);
    hmax = fmax(hmax, hdid);
    }
#endif //RKQS
#ifdef RKCK
  {
    err = rkck(state, dstatedt, STATE_COUNT, t, 
               h, next_state, state_scale, &frog_deriv);
    hdid = hnext = h = 0.02;
  }
#endif //RKCK
#ifdef RK4
  {
    err = rk4(state, dstatedt, STATE_COUNT, t,
              h, next_state, &frog_deriv, constants);
    hdid = hnext = h = step_size;
  }
#endif // RK4
    // Swap next_state and state
    temp_state = state;
    state = next_state;
    next_state = temp_state;
#ifdef COLLISIONS
    process_collision(state);
#endif // COLLISIONS


    if (j % 1000) {
      //printf("t = %f, h = %f, hnext = %f, hdid = %f, s[0] = %f\n", t, h, hnext, hdid, state[0]);
    }
/*    if (fabs(hdid) < 1e-7)
      return 1;*/
    h = hnext;
    if (err)
      return (1 << 7 | err);
    t = state[0];
    if ((t+h-time)*(t+h-torig) > 0.0) 
      h = time - t; // If stepsize can overshoot, decrease.

    for(i = 0; i < STATE_COUNT; i++) {
      if (isnan(state[i])) {
        ec = 2;
        goto finish;
      }
    }

    if (continue_loop) {
      if ((*continue_loop)() != 0)
        return 3;
    }

    if ((t-time)*(time-torig) >= 0.0) {
      hmean /= (double) j;
      //printf("hmin = %f, hmean = %f, hmax = %f\n", hmin, hmean, hmax);
      //printf("result ");
      //printf("\n");
      ec = 0;
      goto finish;
    }
  }
  ec = 1;

finish:
  for (i = 0; i < STATE_COUNT; i++) 
    state_result[i] = state[i];

  return ec;
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

int gene_to_ctrnn(double *constants_arg, double *result)
{
  int err;
  struct M_TENSOR_STRUCT Tconstants; 
  Tconstants.dim = CONSTANTS_COUNT;
  Tconstants.data_pointer = constants_arg;
  struct M_TENSOR_STRUCT Tresult; 
  Tresult.dim = CONSTANTS_COUNT;
  Tresult.data_pointer = result;
  MTensor TTresult = &Tresult;

  err = geneToCTRNN(libData, &Tconstants, &TTresult);
  return err;
}

int physics_constants( double *physics_constants_result) 
{
  int err;
  struct M_TENSOR_STRUCT Tresult; 
  Tresult.dim = PHYS_COUNT;
  Tresult.data_pointer = physics_constants_result;
  MTensor TTresult = &Tresult;

  err = physicsConstants(libData, &TTresult);
  return err;
}

int period_constants(double *period_constants_result)
{
  int i;
  for (i = 0; i < PERIOD_COUNT; i++)
    period_constants_result[i] = 0.0;
  period_constants_result[PERIOD_COUNT - 1] = 1.0;
  return 0;
}
