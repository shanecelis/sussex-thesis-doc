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

  int err = ea_engine(argv[1], 0, false, argv[2]);

  sim_uninit();
  return err;
}


