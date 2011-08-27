# Makefile 
# thesis code

OS=$(shell uname -s)
MATHEMATICA=1

#CPPFLAGS = -g -I/Applications/Mathematica.app/SystemFiles/IncludeFiles/C
CPPFLAGS = -g -Iinclude -Wall -Werror

ifeq ($(MATHEMATICA),1)

# Mathematica binaries
MLINKDIR = /Applications/Mathematica.app/SystemFiles/Links/MathLink/DeveloperKit
CADDSDIR = ${MLINKDIR}/CompilerAdditions

INCDIR = ${CADDSDIR}
LIBDIR = ${CADDSDIR}

MPREP = ${CADDSDIR}/mprep
EXTRA_LIBS = -lstdc++ -framework Foundation

LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64 -lWolframRTL_Static_Minimal 
CPPFLAGS += -I $(INCDIR)

MOBJS = bga.mo ctrnn.mo frog-ga.mo frog-simulation.mo runge-kutta.mo export-c-code.mo experiments.mo
endif

LDFLAGS += -lalps -lstdc++
#LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64 -lWolframRTL -L. -lalps -lstdc++


# Attempt to compile without WolframRTL library.
#LDFLAGS = -L/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64 -L. -lalps -lstdc++
#CPPFLAGS = -g -Iinclude
SIM_OBJS = rkqs.o frogRHS-fixed.o run-simulation-rkqs.o myWolframRTL.o

#SIM_OBJS = runSimulation.o run-simulation.o experiments.o 
#SIM_OBJS = runSimulationAdaptive.o run-simulation.o experiments.o 
OBJS = $(MOBJS) genes_real.o $(SIM_OBJS)

BINARIES = run-sim-main alps_main frog_eval 

ifeq ($(MATHEMATICA),1)
	BINARIES += run-simulation-mlink 
endif

all: $(OBJS) $(BINARIES) frog_eqns.m frog_eqns_dotsolved.m

ifeq ($(MATHEMATICA),1)
%.mo : %.m
	mathload $< > $@
endif

clean:
	$(RM) $(OBJS) $(BINARIES) frogq.al parenparser.hi parenparser

run-simulation.o: run-simulation.c run-simulation.h

$(SIM_OBJS): run-simulation.h

run-sim-main: run-sim-main.o $(SIM_OBJS)

alps_main: alps_main.o alps_frog.o genes_real.o $(SIM_OBJS)

frog_eval: frog_eval.o alps_frog.o genes_real.o $(SIM_OBJS)

# These aren't really necessary anymore since I'm linking to the
# static library.

run: run-sim-main
	DYLD_LIBRARY_PATH=/Applications/Mathematica.app/SystemFiles/Libraries/MacOSX-x86-64:. ./run-sim-main

ifeq ($(MATHEMATICA),1)

run-simulation-mlinktm.c : run-simulation-mlink.tm
	${MPREP} $? -o $@

run-simulation-mlink : run-simulation-mlinktm.o $(SIM_OBJS)
	${CC} -I${INCDIR} $(SIM_OBJS) run-simulation-mlinktm.o -L${LIBDIR} -lMLi3 ${EXTRA_LIBS} -o $@

endif

frog_eqns.txt: frog.al
	(cat frog.al; echo "quit") > frogq.al
	(echo "! rhseqns = "; yes | al frogq.al | grep Result) > frog_eqns.txt

ifeq ($(MATHEMATICA),1)
frog_eqns.m: frog_eqns.txt parenparser mr.pl
	cat frog_eqns.txt | ./parenparser /dev/stdin | ./mr.pl > frog_eqns.m

frog_eqns_dotsolved.m: frog_eqns.m make-frog_eqns_dotsolved.m
	mathload make-frog_eqns_dotsolved.m

frogRHS.c frogRHS.h: frog_eqns_dotsolved.m make-frogRHSC.m
	mathload make-frogRHSC.m 

endif

parenparser: parenparser.hs
	ghc -o parenparser parenparser.hs

frogRHS-fixed.c: frogRHS.c frogRHS.patch
	patch -i frogRHS.patch frogRHS.c -o frogRHS-fixed.c
