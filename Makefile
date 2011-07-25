# thesis code Makefile

CPPFLAGS = -g -I/Applications/Mathematica.app/SystemFiles/IncludeFiles/C

#LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64 -lWolframRTL_Static_Minimal
LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64 -lWolframRTL -L. 
#-lrunSimulation

# -lalps -lstdc++
#LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86 -lWolframRTL -L. -ltadpoleSolver


OBJS = bga.o ctrnn.o experiments.o export-c-code.o frog-simulation.o loadall.o tadpole_eqns4.o tadpole_eqns4_dotsolved.o runge-kutta.o runSimulation.o

all: $(OBJS) run-simulation

%.o : %.m
	mathload $< > $@

clean:
	$(RM) $(OBJS)

run-simulation: run-simulation.o runSimulation.o

run: run-simulation
	DYLD_LIBRARY_PATH=/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64:. ./run-simulation
