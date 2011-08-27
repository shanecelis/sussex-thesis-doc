#include <stdio.h>
#include "run-simulation.h"

int main(int argc, char **argv)
{
  int i, err;
  double state[STATE_COUNT], constants[CONSTANTS_COUNT], result[STATE_COUNT];
  sim_init();

  for (i = 0; i <STATE_COUNT; i++) {
    state[i] = 0.01;
  }
  for (i = 0; i <CONSTANTS_COUNT; i++) {
    constants[i] = 1.0;
  }
  double tmax = 10.01;

  err = experiment_points("An", tmax, 1, constants + POINTS_BEGIN);
  experiment_init_state(constants + POINTS_BEGIN, 
                        state + TAILSTATE_BEGIN, 
                        state + TAILSTATE_BEGIN + 1);
  if (err) {
    fprintf(stderr, "error: experiments  %d\n", err);
    return err;
  }

  err = run_simulation(state, 0.01, constants, tmax, result);

  if (err) {
    fprintf(stderr, "error: %d\n", err);
  }

  for(i = 0; i < STATE_COUNT; i++) {
    printf("%f ", result[i]);
  }
  printf("\n");

  sim_uninit();
  return 0;
}
