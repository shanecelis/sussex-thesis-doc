#include <stdio.h>
#include "run-simulation.h"

int main(int argc, char **argv)
{
  int i, err;
  double state[STATE_COUNT], result[STATE_COUNT];
  sim_init();

  for (i = 0; i <STATE_COUNT; i++) {
    state[i] = 0.01;
  }
  err = run_simulation(state, 0.01, 0, 10.0, result);

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
