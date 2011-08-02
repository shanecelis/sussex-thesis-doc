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
}

#include "alps_frog.h"

int main(int argc, char **argv) {

  if (argc != 4) {
    cerr << "usage: eval_frog <individual.ind> <experiment-name> <phase>" << endl;
    return 2;
  }
    
  sim_init();

  Individ_Real *individ = new Individ_Real(GENE_COUNT);    
  individ->read(argv[1]);
  vector<double> fitness;
  fitness.resize(1);
  int err = 0;
  if (evaluate_individ(fitness, individ, argv[2], atoi(argv[3]))) {
    cout << "fitness: " << fitness[0] << endl;
  } else {
    err = 1;
  }
  sim_uninit();
  return err;
}


