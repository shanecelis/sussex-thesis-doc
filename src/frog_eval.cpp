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
#include <assert.h>
#include <string.h>
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

int has_suffix(char *filename, const char *suffix) {
  char *dot;
  dot = strrchr(filename, '.');
  if (dot)
    return strcmp(dot, suffix) == 0;
  else
    return 0;
}

int main(int argc, char **argv) {

  if (argc < 3 || argc > 7) {
    cerr << "usage: eval_frog <individual.ind|gene.bin> <experiment-name> [phase] [target-index] [lobotomise] [fitness-type]" << endl;
    return 2;
  }
  int err = 0, i;
  const char *exp_name = argv[2];
  int phase = 1;
  bool lobotomise = false;
  int task_index = 0;
  int fitness_type = 0;
  Individ_Real *individ = new Individ_Real(GENE_COUNT);    
  double fitness[FITNESS_COUNT];
  vector<double> genes;
  double cgenes[GENE_COUNT];
  sim_init();

  if (has_suffix(argv[1], ".bin")) {
    // double x;
    // FILE *in = fopen(argv[1], "r");

    // for (i = 0; i < GENE_COUNT; i++) {
    //   pgets(in, &x);
    //   //cout << "got " << x << endl;
    //   genes[i] = x;
    // }
    // fclose(in);
    int n;
    read_array(argv[1], &n, cgenes);
    assert(n == GENE_COUNT);
  } else if (has_suffix(argv[1], ".ind")) {
    if (! individ->read(argv[1])) {
      cerr << "error: cannot read .ind file" << endl;
      return 3;
    }
    genes = ((Individ_Real*)individ)->get_genes();
    for (i = 0; i < GENE_COUNT; i++) cgenes[i] = genes[i];
  } else {
    cerr << "error: cannot determine file type for '" << argv[1] << "'" << endl;
    return 1;
  }

  if (argc >= 4) {
    phase = atoi(argv[3]);
  }
  if (argc >= 5) {
    task_index = atoi(argv[4]) - 1;
  }
  if (argc >= 6) {
    lobotomise = (atoi(argv[5]) == 1);
  }

  if (argc >= 7) {
    fitness_type = atoi(argv[6]);
  }
  err = evaluate_frog(fitness, 
                      cgenes, 
                      exp_name,
                      phase,
                      task_index, 
                      lobotomise,
                      fitness_type);

  if (! err) {
    printf("%-16s: ", argv[1]);
    //cout << argv[1] << ": ";
    for (i = 0; i < FITNESS_COUNT; i++)
      cout << fitness[i] << " " ;
    cout << endl;
  } else {
    cerr << "error: evaluate_frog() (err = " << err << ") on file " << argv[1] << "." << endl;
    //for (i = 0; i < STATE_COUNT; i++) printf("%f ", results[i]);
    //printf("\n");
  }

                                      
  sim_uninit();
  return err;
}


