# thesis code Makefile

OBJS = bga.o ctrnn.o experiments.o export-c-code.o frog-simulation.o loadall.o tadpole_eqns4.o tadpole_eqns4_dotsolved.o runge-kutta.o

all: $(OBJS)

%.o : %.m
	mathload $< > $@

clean:
	$(RM) $(OBJS)
