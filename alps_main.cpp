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

  if (argc != 5) {
    cerr << "usage: alps_frog <experiment-name> <target-index> <lobotomise> <population-save>" << endl;
    cerr << "experiment names: 0, 1, Ap, Ao, Bp, Bo" << endl;
    return 2;
  }
    
  sim_init();
  int target_index = atoi(argv[2]) - 1;
  bool lobotomise = (atoi(argv[3]) == 1);

  int err = ea_engine(argv[1], target_index, lobotomise, argv[4]);

  sim_uninit();
  return err;
}


