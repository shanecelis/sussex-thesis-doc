# thesis code Makefile

CPPFLAGS = -g -I/Applications/Mathematica.app/SystemFiles/IncludeFiles/C

#LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64 -lWolframRTL_Static_Minimal
LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64 -lWolframRTL -L. -lalps -lstdc++
#-lrunSimulation

# 
#LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86 -lWolframRTL -L. -ltadpoleSolver


OBJS = bga.mo ctrnn.mo experiments.mo export-c-code.mo frog-simulation.mo loadall.mo tadpole_eqns4.mo tadpole_eqns4_dotsolved.mo runge-kutta.mo runSimulation.o frog-ga.mo

all: $(OBJS) run-sim-main alps_main frog_eval

%.mo : %.m
	mathload $< > $@


clean:
	$(RM) $(OBJS)

run-simulation.o: run-simulation.c run-simulation.h

run-sim-main: run-sim-main.o run-simulation.o runSimulation.o experiments.o

alps_main: alps_main.o alps_frog.o run-simulation.o runSimulation.o experiments.o

frog_eval: frog_eval.o alps_frog.o run-simulation.o runSimulation.o experiments.o

run: run-sim-main
	DYLD_LIBRARY_PATH=/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64:. ./run-sim-main


debug: run-sim-main
	DYLD_LIBRARY_PATH=/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64:. gdb --args ./run-sim-main

runalps: alps_frog
	DYLD_LIBRARY_PATH=/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64:. ./alps_frog


debugalps: alps_frog
	DYLD_LIBRARY_PATH=/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64:. gdb --args ./alps_frog
