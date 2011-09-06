#include "alps/alps.h"
#include "alps/sstate.h"
#include "alps/gen.h"
#include "alps/layer.h"
#include "alps/individ_real.h"
using namespace alps;

#include <cmath>
#include <cstdio>
#include <string>
using namespace std;

extern "C" {
#include "run-simulation.h"
#include <stdlib.h>
}

#include "alps_frog.h"

int main(int argc, char **argv) {

  if (argc < 3 || argc > 7) {
    cerr << "usage: eval_frog <individual.ind> <experiment-name> [phase] [target-index] [lobotomise] [fitness-type]" << endl;
    return 2;
  }
  int err = 0;
  const char *exp_name = argv[2];
  int phase = 1;
  bool lobotomise = false;
  int target_index = 0;
  int fitness_type = 0;
  Individ_Real *individ = new Individ_Real(GENE_COUNT);    
  vector<double> fitness;

  sim_init();

  individ->read(argv[1]);
  fitness.resize(1);

  if (argc >= 4) {
    phase = atoi(argv[3]);
  }
  if (argc >= 5) {
    target_index = atoi(argv[4]) - 1;
  }
  if (argc >= 6) {
    lobotomise = (atoi(argv[5]) == 1);
  }

  if (argc >= 7) {
    fitness_type = atoi(argv[6]);
  }
  if (evaluate_frog(fitness, 
                    individ, 
                    exp_name,
                    phase,
                    target_index, 
                    lobotomise,
                    fitness_type)) {
    cout << "fitness: " << fitness[0] << endl;
  } else {
    err = 1;
  }
  sim_uninit();
  return err;
}


