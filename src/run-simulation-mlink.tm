/* To launch this program from within Mathematica use:
 *   In[1]:= link = Install["run-simulation-mlink"]
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
#include <stdlib.h>
#include <mathlink.h>
#include "run-simulation.h"

:Begin:
:Function:      run_simulation_mlink
:Pattern:       runSimulationMlink[ state:{___Real}, stepSize_Real, constants:{___Real}, time_Real]
:Arguments:     { state, stepSize, constants, time }
:ArgumentTypes: { RealList, Real, RealList, Real }
:ReturnType:    Manual
:End:

:Evaluate:      runSimulationMlink[ state:{___}, stepSize_, constants:{___}, time_] := runSimulationMlink[N[state], N[stepSize], N[constants], N[time]]

:Begin:
:Function:      run_simulation_mlink2
:Pattern:       runSimulationMlink2[ state:{___Real}, stepSize_Real, constants:{___Real}, time_Real]
:Arguments:     { state, stepSize, constants, time }
:ArgumentTypes: { RealList, Real, RealList, Real }
:ReturnType:    Manual
:End:

:Evaluate:      runSimulationMlink2[ state:{___}, stepSize_, constants:{___}, time_] := runSimulationMlink2[N[state], N[stepSize], N[constants], N[time]]


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

int was_aborted() {
  int code, param;
  //MLGetYieldFunction(stdlink)(stdlink, (MLYieldParameters)0 );
  if (MLMessageReady(stdlink) && MLGetMessage(stdlink, &code, &param)) {
    switch (code){
    case MLAbortMessage:
      MLPutFunction(stdlink, (char *) "Abort", 0);
      //MLEndPacket(stdlink);
      //MLFlush(stdlink);
      return 1;
/*    case MLInterruptMessage:
      MLPutSymbol(stdlink, (char *) "$Interrupted");
      break;*/
    case MLTerminateMessage:
      exit(1);
      return 2;
    }
  }
  return 0;
}



void run_simulation_mlink2( double *state, long stateLength, 
     double step_size, double *constants, long constantsLength, 
     double time) {
  long dims[1];
  long d = 1;
  double result[STATE_COUNT];
  int err;
  if (stateLength != STATE_COUNT) {
    failed_with_message0("runSimulationMlink::invstcnt");
    return;
  }
  if (constantsLength != CONSTANTS_COUNT) {
    failed_with_message0("runSimulationMlink::invcnstscnt");
    return;
  }

  /* err = gene_to_ctrnn(constants, constants2); */
  /* if (err) { */
  /*   failed_with_message0("runSimulationMlink::errg2c"); */
  /*   return; */
  /* } */
  dims[0] = STATE_COUNT;
  err = run_simulation(state, step_size, constants, state[0] + time, 
                       result, &was_aborted);
  if (err == 3) {
    // Aborted.
    return;
  }
  if (err) {
    failed_with_message0("runSimulationMlink::errsim");
    return;
  }

  MLPutDoubleArray(stdlink, result, dims, NULL /* header*/, d /* rank */);
}


void run_simulation_mlink( double *state, long stateLength, 
     double step_size, double *constants, long constantsLength, 
     double time) {
  int err;
  double constants2[CONSTANTS_COUNT];
  err = gene_to_ctrnn(constants, constants2);
  if (err) {
    failed_with_message0("runSimulationMlink::errg2c");
    return;
  }
  run_simulation_mlink2(state, stateLength, step_size, constants2, 
                        constantsLength, time);
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
