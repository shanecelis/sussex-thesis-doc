
#include <cmath>
#include <cstdio>
#include <string>
using namespace std;

#include "alps/alps.h"
#include "alps/sstate.h"
#include "alps/gen.h"
#include "alps/layer.h"
#include "alps/individ_real.h"
using namespace alps;


extern "C" {
#include "run-simulation.h"
}

#include "alps_frog.h"

int main(int argc, char **argv) {

  if (argc != 5 && argc != 6) {
    cerr << "usage: alps_frog <experiment-name> <target-index> <lobotomise> <population-save> [fitness-type]" << endl;
    cerr << "experiment names: An, Bn, Ap, Bp, Ao, Bo" << endl;
    return 2;
  }

  register_signal_handlers();
  sim_init();
  int target_index = atoi(argv[2]) - 1;
  bool lobotomise = (atoi(argv[3]) == 1);
  
  int fitness_type = 0;
  if (argc == 6)
    fitness_type = atoi(argv[5]);

  int err = ea_engine(argv[1], target_index, lobotomise, argv[4], fitness_type);

  sim_uninit();
  return err;
}


