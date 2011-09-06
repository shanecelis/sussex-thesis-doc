#include <stdio.h>
#include "run-simulation.h"

int main(int argc, char **argv)
{
  int i, err;
  double state[STATE_COUNT], constants[CONSTANTS_COUNT], result[STATE_COUNT];
  sim_init();

  for (i = 0; i < STATE_COUNT; i++) {
    state[i] = 0.01;
  }
  for (i = 0; i < CONSTANTS_COUNT; i++) {
    constants[i] = 0.001;
  }
  double tmax = 10.01;

  constants[TARGET_BEGIN] = 0.;
  constants[TARGET_BEGIN + 1] = TARGET_DISTANCE; 
  err = experiment_points("An", tmax, 1, constants + POINTS_BEGIN);
  experiment_init_state(constants + POINTS_BEGIN, 
                        state + TAILSTATE_BEGIN, 
                        state + TAILSTATE_BEGIN + 1);
  err = physics_constants(constants + PHYS_BEGIN);
  err = period_constants(constants + PERIOD_BEGIN);

  //err = gene_to_ctrnn(constants, constants2);

  if (err) {
    fprintf(stderr, "error: experiments  %d\n", err);
    return err;
  }
    
  err = run_simulation(state, STEP_SIZE, constants, tmax, result, NULL); 

  if (err) {
    fprintf(stderr, "error: %d\n", err);
    return err;
  }

  for(i = 0; i < STATE_COUNT; i++) {
    printf("%f ", result[i]);
  }
  printf("\n");

  sim_uninit();
  return 0;
}
