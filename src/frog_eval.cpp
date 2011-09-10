#include "alps/alps.h"
#include "alps/sstate.h"
#include "alps/gen.h"
#include "alps/layer.h"
#include "alps/individ_real.h"
using namespace alps;

#include <cmath>
#include <cstdio>
#include <string>
using namespace std;

extern "C" {
#include "run-simulation.h"
#include <stdlib.h>
#include <stdarg.h>
#include <math.h>
}

#include "alps_frog.h"



/*................................... PGETS ................................*/
void  pgets( FILE *Fp, double *x )
{
static long  lineNumber = 0;
char         line[256];

lineNumber++;
if( !fgets(line,256,Fp) )
{
   printf("error: Unable to read line %ld of input file.", lineNumber);
   exit(1);
}
if( !x ) return;
   char *endOfNumber;
   *x = strtod(line,&endOfNumber);
   while( isspace(*endOfNumber) )  endOfNumber++;
   if( !*endOfNumber ) return;
}

/*................................... READF ................................*/
void  readf( FILE *Fp, double *next, ... )
{
va_list args;                                    /* Variable argument list  */
for( va_start(args,next);  next;  next=va_arg(args,double *) )
  pgets(Fp,next);
va_end(args);                          /* Help function make normal return  */
pgets(Fp,NULL);                        /* Always get a newline at the end   */
}

int main(int argc, char **argv) {

  printf("%1.40lf\n", M_PI_2);

  if (argc < 3 || argc > 7) {
    cerr << "usage: eval_frog <individual.ind> <experiment-name> [phase] [target-index] [lobotomise] [fitness-type]" << endl;
    return 2;
  }
  int err = 0, i;
  const char *exp_name = argv[2];
  int phase = 1;
  bool lobotomise = false;
  int target_index = 0;
  int fitness_type = 0;
  Individ_Real *individ = new Individ_Real(GENE_COUNT);    
  vector<double> fitness;
  vector<double> genes;
  sim_init();

  if (!individ->read(argv[1])) {
    cerr << "warning: not a Individ_Real file type; trying to read gene as numbers." << endl;
    double x;
    FILE *in = fopen(argv[1], "r");

    genes.resize(GENE_COUNT);	
    for (i = 0; i < GENE_COUNT; i++) {
      pgets(in, &x);
      //cout << "got " << x << endl;
      genes[i] = x;
    }
    fclose(in);
  } else {
    genes = ((Individ_Real*)individ)->get_genes();
  }

  fitness.resize(1);

  if (argc >= 4) {
    phase = atoi(argv[3]);
  }
  if (argc >= 5) {
    target_index = atoi(argv[4]) - 1;
  }
  if (argc >= 6) {
    lobotomise = (atoi(argv[5]) == 1);
  }

  if (argc >= 7) {
    fitness_type = atoi(argv[6]);
  }

  if (evaluate_frog(fitness, 
                    genes,
                    exp_name,
                    phase,
                    target_index, 
                    lobotomise,
                    fitness_type)) {
    cout << "fitness: " << fitness[0] << endl;
  } else {
    err = 1;
  }
  sim_uninit();
  return err;
}


