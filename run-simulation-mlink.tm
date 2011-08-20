/* To launch this program from within Mathematica use:
 *   In[1]:= link = Install["sumalist"]
 *
 * Or, launch this program from a shell and establish a
 * peer-to-peer connection.  When given the prompt Create Link:
 * type a port name. ( On Unix platforms, a port name is a
 * number less than 65536.  On Mac or Windows platforms,
 * it's an arbitrary word.)
 * Then, from within Mathematica use:
 *   In[1]:= link = Install["portname", LinkMode->Connect]
 */

#include <stdio.h>
#include "mathlink.h"
#include "run-simulation.h"

/* void run_simulation_mlink P(( double *, long ,  */
/*      double , double *, long ,  */
/*      double )) */

:Begin:
:Function:      run_simulation_mlink
:Pattern:       runSimulationMlink[ state:{___Real}, stepSize_Real, constants:{___Real}, time_Real]
:Arguments:     { state, stepSize, constants, time }
:ArgumentTypes: { RealList, Real, RealList, Real }
:ReturnType:    Manual
:End:

:Evaluate:      runSimulationMlink[ state:{___}, stepSize_, constants:{___}, time_] := runSimulationMlink[N[state], N[stepSize], N[constants], N[time]]
//:Evaluate:      SumAList[ sequence___Integer]:= SumAList[ {sequence} ]

void failed_with_message0(char *msg) {
    char buf[255];
    MLClearError(stdlink); 
    MLNewPacket(stdlink); 
    snprintf(buf, 255, "Message[%s]", msg);
    MLEvaluate(stdlink, (char *) buf);
    MLNextPacket(stdlink); 
    MLNewPacket(stdlink); 
    MLPutSymbol(stdlink, (char *) "$Failed");
}

void run_simulation_mlink( double *state, long stateLength, 
     double step_size, double *constants, long constantsLength, 
     double time) {
  long dims[1];
  long d = 1;
  double result[STATE_COUNT];
  double constants2[CONSTANTS_COUNT];
  int err;
  if (stateLength != STATE_COUNT) {
    failed_with_message0("runSimulationMlink::invstcnt");
    return;
  }
  if (constantsLength != CONSTANTS_COUNT) {
    failed_with_message0("runSimulationMlink::invcnstscnt");
    return;
  }

  dims[0] = STATE_COUNT;
  err = gene_to_ctrnn(constants, constants2);
  if (err) {
    failed_with_message0("runSimulationMlink::errg2c");
    return;
  }
  err = run_simulation(state, step_size, constants2, state[0] + time, result);
  if (err) {
    failed_with_message0("runSimulationMlink::errsim");
    return;
  }
  MLPutDoubleArray(stdlink, result, dims, NULL, d);
}

int main(argc, argv)
	int argc; char* argv[];
{
  int err;
  err = sim_init();
  if (err)
    return err;
  err = MLMain(argc, argv);
  if (err)
    return err;
  err = sim_uninit();
  return err;
}
