/* alps-like.c */	

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <strings.h>
#include <string.h>
#include <time.h>
#include <unistd.h>
#include <assert.h>
#include <stdarg.h>
#include <sys/stat.h>

#include "run-simulation.h"										
#include "alps-like.h"
#include "pareto_front.h"
#include "alps_frog.h"

#define rand           drand48

#define MUT_PROB       0.01     // mutation probability
#define MAX_OPT_STEPS  100000   // max optimisation steps
#define LAYER_COUNT    20
#define POP_PER_LAYER  10
#define POP            (LAYER_COUNT * POP_PER_LAYER)
#define MAX_LAYER      (LAYER_COUNT - 1)
#define BAD_FITNESS    666.0
#define RESET_FREQ     (POP * 2)
#define DISPLAY_FREQ   300
#define MAX_SECONDS    (30 * 60)
// 30 minutes maximum.

#define LAYER_OF_INDIV(i)    ((i) / POP_PER_LAYER)

/* INDEX = Index of individual */
/* LINDEX = Layer Index (layer, index of individual within layer) */
#define FITNESS_INDEX(i)      ((i) * FITNESS_COUNT)
#define LAYER_BEGINS(l)       (POP_PER_LAYER * (l))
#define INDIV_LINDEX(l, li)   (LAYER_BEGINS(l) + (li))
#define FITNESS_LINDEX(l, li) (INDIV_LINDEX(l, li) * FITNESS_COUNT)


double genes[POP][GENE_COUNT];   // Genotypes of the population.
double age[POP];
double fitness_matrix[POP * FITNESS_COUNT];
int    pareto_front[POP];
int    t;                       /* optimisation step or time */
int    max_age[LAYER_COUNT] = {1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 
                               377, 610, 987, 1597, 2584, 4181, 6765, 10946}; 

int    goal_indiv;
int    phase;
int    run_type = STANDARD_RUN;
long   random_seed;
int    eval_succ_count = 0;
int    eval_fail_count = 0;
time_t begin;
FILE  *mfile;
FILE  *table;
FILE  *script;
double goal_fitness = 0.5;

//    experiment parameters
char  *exp_name;
int   task_index;
int   lobotomise;
int   fitness_type;
int   phase_count;
char  *save_prefix;


int mprintf(int add_prefix, const char *fmt, ...);

void init_population() {
  int i;
  for (i = 0; i < POP; i++)
    init_gene(genes[i]);
}

void init_gene(double *gene) {
  int i;
  for(i = 0; i < GENE_COUNT; i++)
    gene[i] = rand(); // [0, 1)
  //gene[i] = rand() + 0.5; // [0, 1)
}

void mutate(double *gene) {
  int i;
  for(i = 0; i < GENE_COUNT; i++)
    if (rand() < MUT_PROB)
      gene[i] = rand();
      //gene[i] += rand() * 2. - 1. ;
}

void copy(double *src, double *dest) {
  memcpy(dest, src, sizeof(double) * GENE_COUNT);
}

int  evaluate(double *gene, double *fitness)
{
  int i, err;
  err = evaluate_frog(fitness, gene, exp_name, phase, task_index, 
                      lobotomise, fitness_type);
  if (err) {
    for (i = 0; i < FITNESS_COUNT; i++)
      fitness[i] = BAD_FITNESS;
    eval_fail_count++;
  } else {
    eval_succ_count++;
  }
  return err;
}

/* Does a dominate b? Return true iff f(a)_i < f(b)_i for all i.*/
int is_dominated(double *fitness_a, double *fitness_b)
{
  int i;
  for (i = 0; i < FITNESS_COUNT; i++) {
    if (fitness_a[i] >= fitness_b[i])
      return 0;
  }
  return 1;
}

/*
  Returns i >= 0 where i is the index of the gene that it dislodged
  itself to.  i < 0 indicates it did not dislodge any gene.
 */
int try_dislodge(double *attempter, double *fitness, int into_layer)
{
  int i, k = into_layer;
  if (k > MAX_LAYER) {
    // Sorry. No layer above to dislodge oneself into.
    return -1;
  }
  for (i = 0; i < POP_PER_LAYER; i++) {
    double *fitness_b = fitness_matrix + FITNESS_LINDEX(k, i);
    if (is_dominated(fitness, fitness_b)
        || age[INDIV_LINDEX(k, i)] > max_age[k]) {
      // New genome dominates current one, or the current one is too old.
      try_dislodge(genes[INDIV_LINDEX(k, i)],
                   fitness_b,
                   k + 1);
            
      copy(attempter, genes[INDIV_LINDEX(k, i)]);
      memcpy(fitness_b, fitness, sizeof(double) * FITNESS_COUNT);
      age[INDIV_LINDEX(k, i)] = t/POP;
      return INDIV_LINDEX(k, i);
    }
  }
  return -2;
}

void print_fitness(double *fitness) {
  int i;
  for (i = 0; i < FITNESS_COUNT; i++)
    printf("%f ", fitness[i]);
  printf("\n");
}

int is_goal_fitness(double *fitness) {
  int i;
  for (i = 0; i < FITNESS_COUNT; i++) {
    if (!(fitness[i] < goal_fitness))
    //if (!(fitness[i] < -5.0))
      return 0;
  }
  return 1;
}

void start_phase(int phase) {
  printf("Starting phase %d (at %d steps)!\n", phase, t);
  fprintf(table, "%d %d %d\n", phase, eval_fail_count, eval_succ_count);
}

void add_to_script(char *filename, int phase, double *fitness) {
  int i;

  fprintf(script, "frog_eval %s %s %d %d %d %d; ",
          filename, exp_name, phase, task_index + 1, lobotomise, 
          fitness_type);
  fprintf(script, "echo recorded fitness: ");
  for (i = 0; i < FITNESS_COUNT; i++)
    fprintf(script, "%f ", fitness[i]);
  fprintf(script, "; echo\n");


}


char *save_gene_for_phase_and_front(double *gene, double *fitness, 
                                     const char *save_prefix, 
                                     int phase, int front_index)
{
  static char gene_save_name[255];
  sprintf(gene_save_name, "p%d-f%dgene.bin", phase, front_index);
  add_to_script(gene_save_name, phase, fitness);
  sprintf(gene_save_name, "%s/p%d-f%dgene.bin", save_prefix, phase, front_index);
  mprintf(1, "individOnFront[{phase -> %d, frontIndex -> %d}] -> \n", phase, front_index + 1);

  assert(FITNESS_COUNT == 2);
  mprintf(1, "\t{fitness -> {%lf, %lf}, geneFilename -> \"%s\" ",
          fitness[0], fitness[1], gene_save_name);

#ifdef PRINT_GENE_CHAR
  mprintf(1, ", gene -> { %lf" , gene[0]);
  int i;
  for (i = 1; i < GENE_COUNT; i++) 
    mprintf(0, ", %lf", gene[i]);
  mprintf(0, "} ");
#endif
  mprintf(0, "}\n");

  write_array(gene_save_name, GENE_COUNT, gene);
  return gene_save_name;
}

void end_phase(int phase) {
  int i, fi, full_front[POP];

  pareto_front_rowmajor(full_front, fitness_matrix, POP, FITNESS_COUNT);
  mprintf(1, "phaseEnd -> {phase -> %d, evalFailedCount -> %d, evalSuccCount -> %d }\n", phase, eval_fail_count, eval_succ_count);
  for (i = fi = 0; i < POP; i++) {
    if (full_front[i] 
        /*&& is_goal_fitness(fitness_matrix + FITNESS_INDEX(i))*/) {
      save_gene_for_phase_and_front(genes[i], 
                                     fitness_matrix + FITNESS_INDEX(i), 
                                     save_prefix, phase, ++fi);
    }
  }
}


int mprintf(int add_prefix, const char *fmt, ...)
{
  va_list ap;
  int len;
  if (mfile) {
    va_start(ap, fmt);
    len = vfprintf(mfile, fmt, ap);
    va_end(ap);
  } 

  char buf[512];
  if (add_prefix) {
    sprintf(buf, ":m: %s", fmt);
  } else {
    sprintf(buf, "%s", fmt);
  }
  va_start(ap, fmt);
  len += vprintf(buf, ap);
  va_end(ap);
  return len;
}

long elapsed_seconds() {
  time_t now = time(NULL);
  return now - begin;
}

int run_alps(int *steps)
{
  int i,j,k,p;
  double temp_fitness[FITNESS_COUNT];
  double temp_gene[GENE_COUNT];
  int pareto_front[POP];
  int pareto_count;  

  begin = time(NULL);
  init_population();            // Initialise population.
  t = 0;
  goal_indiv = -1;

  mprintf(1, "preamble -> {expName -> %s, phaseCount -> %d, lobotomise -> %s, task -> %d, \n", exp_name, phase_count, lobotomise ? "True" : "False", task_index + 1);
  mprintf(1, "\ttmax -> %.2lf, fitnessType -> %d, runType -> %d, randomSeed -> %ld }\n", TIME_MAX, fitness_type, run_type, random_seed);
  fflush(stdout);

  for (p = 0, phase = 1; p < phase_count; p++, phase = p + 1) {
    if (p != 0) end_phase(p);
    start_phase(phase);
    for (i = 0; i < POP; i++) {
      // Evaluate every gene.
      evaluate(genes[i], fitness_matrix + FITNESS_INDEX(i));
      age[i] = t/POP;
    }
    int met_goal = 0;
    for (j = 0; j < POP; j++) {
      if (is_goal_fitness(fitness_matrix + FITNESS_INDEX(j))) {
        met_goal = 1;
        goal_indiv = j;
        /* handle_goal_indiv(genes[goal_indiv],  */
        /*                   fitness_matrix + FITNESS_INDEX(goal_indiv), */
        /*                   phase); */
      }
    }
    if (met_goal) 
      continue;
    
    for (; t < MAX_OPT_STEPS && elapsed_seconds() < MAX_SECONDS; t++) { 
      // Evaluate the pareto front for each layer.
      for (k = 0; k < LAYER_COUNT; k++) 
        pareto_front_rowmajor(pareto_front + k * POP_PER_LAYER, 
                              fitness_matrix 
                              + k * FITNESS_COUNT * POP_PER_LAYER,
                              POP_PER_LAYER,
                              FITNESS_COUNT);

      // Grab a non-dominated individual.
      int a;
      //do { a = POP*rand(); } while (! pareto_front[a]);

      // O(n) single pass to count and grab a random individual
      // that's on the pareto front.
      pareto_count=0;
      for (i = 0; i < POP; i++) 
        if (pareto_front[i] && (rand() < 1./(double)++pareto_count))
            a = i;
      k = LAYER_OF_INDIV(a);

      if (t % DISPLAY_FREQ == 0) {
        int n = FITNESS_INDEX(a);
        printf("t = %d, a = %d, k = %d, N(pareto) = %d, f(a) = {%f, %f}, efc = %d, epc = %d, es = %ld\n", t, a, k, pareto_count, fitness_matrix[n],
               fitness_matrix[n + 1], eval_fail_count, eval_succ_count, elapsed_seconds());
        //print_expr();
      }

      if (t % RESET_FREQ == 0) {
        // Reset the bottom layer.
        for (i = 0; i < POP_PER_LAYER; i++) {
          // Try to dislogde in the layer above.
          try_dislodge(genes[i], fitness_matrix + FITNESS_LINDEX(0, i), 1);

          init_gene(genes[i]);
        }
      }

      copy(genes[a], temp_gene);
      mutate(temp_gene);
      evaluate(temp_gene, temp_fitness);
      int new_i = try_dislodge(temp_gene, temp_fitness, k);
      if (is_goal_fitness(temp_fitness)) {
        goal_indiv = new_i;
        /* handle_goal_indiv(genes[goal_indiv],  */
        /*                   fitness_matrix + FITNESS_INDEX(goal_indiv), */
        /*                   phase); */
        break;                  /* Goto next phase */
      }
    }
  }
  end_phase(phase - 1);
  if (steps)
    *steps = t;
  if (t == MAX_OPT_STEPS) 
    return ALPS_FAIL;
  else
    return ALPS_SUCC;
}

int main(int argc, char **argv) { 

  // Which random number generator am I going to use?
  //srand48(atoi(argv[1]));
  int c;
int  argco = argc;
char **argvo = argv;
  fitness_type = FITNESS_MEAN_LIGHTSENSOR;
  int run_type = STANDARD_RUN;
  pid_t pid = getpid();
  random_seed = (long) time(NULL) ^ pid;

  int force = 0;
  while ((c = getopt (argc, argv, "DT:F:s:f")) != -1)
    switch (c)
    {
    case 'D':
      run_type = DEBUG_RUN;
      break;
    case 'T':
      run_type = atoi(optarg);
      break;
    case 'F':
      fitness_type = atoi(optarg);
      break;
    case 's':
      random_seed = atol(optarg);
      break;
    case 'f':
      force = 1;
      break;
    case '?':
      break;
    default:
      abort ();
    }
  // next argument at argv[optind]
  argc -= (optind - 1);
  argv += (optind - 1);
  srand48(random_seed);
  
  if (run_type == DEBUG_RUN) {
    goal_fitness = 0.9;
  }
  

  if (argc != 5) {
    fprintf(stderr, "usage: alps-like [-fD] [-T run-type] [-F fitness-type] <experiment-name> <task-index> <lobotomise> <save-dir> \n");
    fprintf(stderr, "experiment names: An, Bn, Ap, Bp, Ao, Bo\n");
    return 2;
  }

  //register_signal_handlers();
  sim_init();
  exp_name = argv[1];
  task_index = atoi(argv[2]) - 1;
  lobotomise = (atoi(argv[3]) == 1);
  save_prefix = argv[4];

  if (mkdir(save_prefix, 0777)) {
    perror(save_prefix);
    if (force) {
      fprintf(stderr, "warning: ignoring that directory exists due to -f.\n");
    }  else {
      return 4;
    }
  }

  char filename[255];
  sprintf(filename, "%s/results.m", save_prefix);
  mfile = fopen(filename, "w");

  sprintf(filename, "%s/table.txt", save_prefix);
  table = fopen(filename, "w");

  sprintf(filename, "%s/run_again.sh", save_prefix);
  FILE *run_again = fopen(filename, "w");
  fprintf(run_again, "#!/bin/bash\n");
  int i;
  mprintf(1, "commandLine -> \"");
  for (i = 0; i < argco; i++) {
    fprintf(run_again, "%s ", argvo[i]);
    mprintf(0, "%s ", argvo[i]);
  }
  mprintf(0, "\"\n");
  fprintf(run_again, "\n");
  fclose(run_again);

  int err;
  err = experiment_phase_count(exp_name, &phase_count);
  if (err) {
    fprintf(stderr, "error: cannot get phase count for experiment '%s'.\n", 
            exp_name);
    err = 1;
    goto finish;
  }

  sprintf(filename, "%s/eval.sh", save_prefix);
  script = fopen(filename, "w");

  fprintf(script, 
          "#!/bin/bash\n"
          "cd $(dirname $0)\n");

  int steps;
  err = run_alps(&steps);
    /*ea_engine(argv[1], task_index, lobotomise, argv[4], fitness_type, run_type);*/
  if (err)
    fprintf(stderr, "error: alps-like did not find an adequate solution.\n");

finish:
  printf("alps-like: Finished.  Files at %s\n", save_prefix);
  sim_uninit();

  if (mfile) fclose(mfile);

  if (table) fclose(table);

  if (script) fclose(script);
  return err;
}
