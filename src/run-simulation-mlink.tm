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
#include <stdarg.h>
#include <mathlink.h>
#include "run-simulation.h"

:Begin:
:Function:      run_simulation_mlink
:Pattern:       runSimulationMlink[ state:{___Real}, stepSize_Real, constants:{___Real}, time_Real]
:Arguments:     { state, stepSize, constants, time }
:ArgumentTypes: { RealList, Real, RealList, Real }
:ReturnType:    Manual
:End:

:Evaluate:      runSimulationMlink[ state:{___?NumberQ}, stepSize_?NumberQ, constants:{___?NumberQ}, time_?NumberQ] := runSimulationMlink[N[state], N[stepSize], N[constants], N[time]]

:Begin:
:Function:      run_simulation_mlink_g2c
:Pattern:       runSimulationMlinkG2C[ state:{___Real}, stepSize_Real, constants:{___Real}, time_Real]
:Arguments:     { state, stepSize, constants, time }
:ArgumentTypes: { RealList, Real, RealList, Real }
:ReturnType:    Manual
:End:

:Evaluate:      runSimulationMlinkG2C[ state:{___}, stepSize_, constants:{___}, time_] := runSimulationMlinkG2C[N[state], N[stepSize], N[constants], N[time]]

:Evaluate: runSimulationMlink::errsim = "Simulation exited with err ``.";
:Evaluate: runSimulationMlink::invstcnt = "Invalid state count ``.";
:Evaluate: runSimulationMlink::invconscnt = "Invalid constants count ``.";
:Evaluate: runSimulationMlink::errnan = "Saw NaN at time ``.";
:Evaluate: runSimulationMlink::errmaxstep = "Reached max time step ``.";
:Evaluate: runSimulationMlink::errg2c = "Error converting genes to constants.";
:Evaluate: runSimulationMlink::aborted = "Aborted at time ``.";

int message(const char *fmt, ...)
{
  va_list ap;
  char buf[255];
  int len;
  len = sprintf(buf, "Message[");
  va_start(ap, fmt);
  len += vsnprintf(buf + len, 255 - len, fmt, ap);
  va_end(ap);
  len += sprintf(buf + len, "]");
  //printf("message = '%s'\n", buf);
  MLClearError(stdlink); 
  MLNewPacket(stdlink); 
  MLEvaluate(stdlink, (char *) buf);
  MLNextPacket(stdlink); 
  return len;
}

void failed() {
    MLNewPacket(stdlink); 
    MLPutSymbol(stdlink, (char *) "$Failed");
}


int was_aborted() {
  int code, param;
  if (stdyielder)
    stdyielder(stdlink, (MLYieldParameters)0);
  //MLGetYieldFunction(stdlink)(stdlink, (MLYieldParameters)0 );
  if (MLAbort || (MLMessageReady(stdlink) && MLGetMessage(stdlink, &code, &param))) {
    switch (code){
    case MLAbortMessage:
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



void run_simulation_mlink( double *state, long stateLength, 
     double step_size, double *constants, long constantsLength, 
     double time) {
  long dims[1];
  long d = 1;
  double result[STATE_COUNT];
  int err;
  if (stateLength != STATE_COUNT) {
    message("runSimulationMlink::invstcnt, %d", stateLength);
    failed();
    return;
  }
  if (constantsLength != CONSTANTS_COUNT) {
    message("runSimulationMlink::invconscnt, %d", constantsLength);
    failed();
    return;
  }

  dims[0] = STATE_COUNT;
  err = run_simulation(state, step_size, constants, state[0] + time, 
                       result, &was_aborted);
  if (err == 3 || MLAbort) {
    // Aborted.
    MLClearError(stdlink);
    MLNewPacket(stdlink);
    MLPutFunction(stdlink, (char *) "Abort", 0);
    //message("runSimulationMlink::aborted, %f", result[0]);
    return;
  }
  if (err == 2) {
    message("runSimulationMlink::errnan, %lf", result[0]);
  } else if (err == 1) {
    message("runSimulationMlink::errmaxstep, %d", MAX_STEPS);
  } else if (err) {
    message("runSimulationMlink::errsim, %d", err);
  }

  MLPutDoubleArray(stdlink, result, dims, NULL /* header*/, d /* rank */);
}


void run_simulation_mlink_g2c( double *state, long stateLength, 
     double step_size, double *constants, long constantsLength, 
     double time) {
  int err;
  double constants2[CONSTANTS_COUNT];
  err = gene_to_ctrnn(constants, constants2);
  if (err) {
    message("runSimulationMlink::errg2c");
    failed();
    return;
  }
  run_simulation_mlink(state, stateLength, step_size, constants2, 
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
