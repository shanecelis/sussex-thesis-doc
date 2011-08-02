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

  if (argc != 3) {
    cerr << "usage: alps_frog <experiment-name> <population-save>" << endl;
    cerr << "experiment names: 0, 1, Ap, Ao, Bp, Bo" << endl;
    return 2;
  }
    
  sim_init();

  int err = ea_engine(argv[1], argv[2]);
  // if (argc == 2) {
  //    Individ_Real *individ = new Individ_Real(10);    
  //   individ->read(argv[1]);
  //   vector<double> fitness;
  //   fitness.resize(5);
  //   // evaluate_individ(fitness, individ);
  //   cout << "fitness: " << fitness[0] << endl;
  // } else {
  //   ea_engine(0);
  // }
  sim_uninit();
  return err;
}


