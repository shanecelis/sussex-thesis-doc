# thesis code Makefile

#CPPFLAGS = -g -I/Applications/Mathematica.app/SystemFiles/IncludeFiles/C
CPPFLAGS = -g -Iinclude -Wall

LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64 -lWolframRTL_Static_Minimal -lalps -lstdc++
#LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64 -lWolframRTL -L. -lalps -lstdc++


# Attempt to compile without WolframRTL library.
#LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64 -L. -lalps -lstdc++
#CPPFLAGS = -g -Iinclude
SIM_OBJS = rkqs.o frogRHS.o run-simulation-rkqs.o myWolframRTL.o

#SIM_OBJS = runSimulation.o run-simulation.o experiments.o 
#SIM_OBJS = runSimulationAdaptive.o run-simulation.o experiments.o 

OBJS = bga.mo ctrnn.mo frog-ga.mo frog-simulation.mo runge-kutta.mo export-c-code.mo experiments.mo genes_real.o $(SIM_OBJS)

BINARIES = run-sim-main alps_main frog_eval

all: $(OBJS) $(BINARIES)

%.mo : %.m
	mathload $< > $@

clean:
	$(RM) $(OBJS) $(BINARIES)

run-simulation.o: run-simulation.c run-simulation.h

run-sim-main: run-sim-main.o $(SIM_OBJS)

alps_main: alps_main.o alps_frog.o genes_real.o $(SIM_OBJS)

frog_eval: frog_eval.o alps_frog.o genes_real.o $(SIM_OBJS)

# These aren't really necessary anymore since I'm linking to the static library.
run: run-sim-main
	DYLD_LIBRARY_PATH=/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64:. ./run-sim-main


debug: run-sim-main
	DYLD_LIBRARY_PATH=/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64:. gdb --args ./run-sim-main

runalps: alps_frog
	DYLD_LIBRARY_PATH=/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64:. ./alps_frog

debugalps: alps_frog
	DYLD_LIBRARY_PATH=/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64:. gdb --args ./alps_frog
