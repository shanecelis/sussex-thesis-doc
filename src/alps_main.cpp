
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
#include <stdlib.h>
}

#include "alps_frog.h"

int main(int argc, char **argv) {
  int c;
  int fitness_type = 0;
  int run_type = STANDARD_RUN;
  while ((c = getopt (argc, argv, "DT:F:")) != -1)
    switch (c)
    {
    case 'D':
      run_type = DEBUG_RUN;
      break;
    case 'T':
      run_type = atoi(optarg);
      break;
    case 'F':
      fitness_type = atoi(optarg);
    case '?':
      break;
    default:
      abort ();
    }
  
  // next argument at argv[optind]
  argc -= (optind - 1);
  argv += (optind - 1);
  

  if (argc != 5) {
    cerr << "usage: alps_frog [-D] [-T run-type] [-F fitness-type] <experiment-name> <task-index> <lobotomise> <population-save> " << endl;
    cerr << "experiment names: An, Bn, Ap, Bp, Ao, Bo" << endl;
    return 2;
  }

  register_signal_handlers();
  sim_init();
  int task_index = atoi(argv[2]) - 1;
  bool lobotomise = (atoi(argv[3]) == 1);
  
  int err = ea_engine(argv[1], task_index, lobotomise, argv[4], fitness_type, 
                      run_type);

  sim_uninit();
  return err;
}


