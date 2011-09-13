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

#define MUT_PROB       0.05     // mutation probability
#define MAX_OPT_STEPS  100000   // max optimisation steps
#define LAYER_COUNT    15
#define POP_PER_LAYER  10
#define POP            (LAYER_COUNT * POP_PER_LAYER)
#define MAX_LAYER      (LAYER_COUNT - 1)
#define BAD_FITNESS    666.0
#define RESET_FREQ     (POP * 2)
#define DISPLAY_FREQ   300
#define MAX_SECONDS    (20 * 60) // 20 minutes maximum.

#define LAYER_OF_INDIV(i)    ((i) / POP_PER_LAYER)

/* INDEX = Index of individual */
/* LINDEX = Layer Index (layer, index of individual within layer) */
#define FITNESS_INDEX(i)      ((i) * FITNESS_COUNT)
#define LAYER_BEGINS(l)       (POP_PER_LAYER * (l))
#define INDIV_LINDEX(l, li)   (LAYER_BEGINS(l) + (li))
#define FITNESS_LINDEX(l, li) (INDIV_LINDEX(l, li) * FITNESS_COUNT)


double genes[POP][GENE_COUNT];   // Genotypes of the population.
int    ages[POP];
double fitness_matrix[POP * FITNESS_COUNT];
int    pareto_front[POP];
int    t;                       /* optimisation step or time */
int    max_age[LAYER_COUNT] = {1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144, 233, 
                               377, 610, 987, /*1597, 2584, 4181, 6765, 10946*/}; 

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
int    quiet;
double mut_prob = MUT_PROB;
int    reset_freq = RESET_FREQ;

//    experiment parameters
char  *exp_name;
int   task_index;
int   lobotomise;
int   fitness_type;
int   phase_count;
char  *save_prefix;


int mprintf(int add_prefix, const char *fmt, ...);
long elapsed_seconds();

void init_population() {
  int i;
  for (i = 0; i < POP; i++) {
    init_gene(genes[i]);
    ages[i] = i/POP; // or zero
  }
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
    if (rand() < mut_prob)
      gene[i] = rand();
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
int try_dislodge(double *attempter, double *fitness, int age, int into_layer)
{
  int i, k = into_layer;
  if (k > MAX_LAYER) {
    // Sorry. No layer above to dislodge oneself to.
    return -1;
  }
  // start_search helps distribute the dislodge search evenly.
  int start_search = rand() * POP_PER_LAYER;
  for (i = 0; i < POP_PER_LAYER; i++) {
    int li = (start_search + i) % POP_PER_LAYER;
    int pi = INDIV_LINDEX(k, li);
    double *fitness_b = fitness_matrix + FITNESS_LINDEX(k, li);
    if (is_dominated(fitness, fitness_b)
        || ages[pi] > max_age[k]) {
      // New genome dominates current one, or the current one is too old.
      try_dislodge(genes[pi],
                   fitness_b,
                   ages[pi],
                   k + 1);
            
      copy(attempter, genes[pi]);
      memcpy(fitness_b, fitness, sizeof(double) * FITNESS_COUNT);
      ages[pi] = age;
      return pi;
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
  if (! quiet)
    printf("alps-like: Starting phase %d on step %d.\n", phase, t);
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


char *save_gene_for_phase_and_front(int pi /* population index */, const char *save_prefix, 
                                     int phase, int front_index)
{
  static char gene_save_name[255];
  double *gene = genes[pi];
  double *fitness = fitness_matrix + FITNESS_INDEX(pi);
  sprintf(gene_save_name, "p%d-f%dgene.bin", phase, front_index);
  add_to_script(gene_save_name, phase, fitness);
  sprintf(gene_save_name, "%s/p%d-f%dgene.bin", save_prefix, phase, front_index);
  mprintf(1, "individOnFront[{phase -> %d, frontIndex -> %d}] -> \n", phase, front_index + 1);

  assert(FITNESS_COUNT == 2);
  mprintf(1, "\t{fitness -> {%lf, %lf}, age -> %d, layer -> %d, meetsGoal -> %s, geneFilename -> \"%s\"",
          fitness[0], fitness[1], ages[pi], LAYER_OF_INDIV(pi), is_goal_fitness(fitness) ? "True" : "False",
          gene_save_name);

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
  int i, fi, full_front[POP], age_max;

  fprintf(table, "%d %d %d\n", phase, eval_fail_count, eval_succ_count);

  pareto_front_rowmajor(full_front, fitness_matrix, POP, FITNESS_COUNT);
  age_max = 0;
  for (i = fi = 0; i < POP; i++) {
    age_max = fmax(age_max, ages[i]);
    if (full_front[i] 
        /*&& is_goal_fitness(fitness_matrix + FITNESS_INDEX(i))*/) {
      save_gene_for_phase_and_front(i, save_prefix, phase, ++fi);
    }
  }
  mprintf(1, "phaseEnd -> {phase -> %d, ageMax -> %d, evalFailedCount -> %d, evalSuccCount -> %d, OptStepsCount -> %d, seconds -> %d }\n", phase, age_max, eval_fail_count, eval_succ_count, t, elapsed_seconds());
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

  if (! quiet) {
    char buf[512];
    if (add_prefix) {
      sprintf(buf, ":m: %s", fmt);
    } else {
      sprintf(buf, "%s", fmt);
    }
    va_start(ap, fmt);
    vprintf(buf, ap);
    va_end(ap);
  }
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

  mprintf(1, "alpsParams -> { layerCount -> %d, popPerLayer -> %d, "
          "popCount -> %d, mutProbability -> %.3f, maxSeconds -> %d }\n",
          LAYER_COUNT, POP_PER_LAYER, POP, mut_prob, MAX_SECONDS);
  fflush(stdout);

  for (p = 0, phase = 1; p < phase_count; p++, phase = p + 1) {
    if (p != 0) end_phase(p);
    start_phase(phase);
    for (i = 0; i < POP; i++) {
      // Evaluate every gene.
      evaluate(genes[i], fitness_matrix + FITNESS_INDEX(i));
    }
    int met_goal = 0;
    for (j = 0; j < POP; j++) {
      if (is_goal_fitness(fitness_matrix + FITNESS_INDEX(j))) {
        met_goal = 1;
        goal_indiv = j;
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
      // O(n) single pass to count and grab a random individual
      // that's on the pareto front.
      pareto_count=0;
      for (i = 0; i < POP; i++) 
        if (pareto_front[i] && (rand() < 1./(double)++pareto_count))
            a = i;
      k = LAYER_OF_INDIV(a);

      if (t % DISPLAY_FREQ == 0) {
        int n = FITNESS_INDEX(a);
        if (! quiet)
        printf("t = %5d, pi = %3d, a = %2d, k = %2d, N(PF) = %2d, f(a) = {%f, %f}, "
               "efail = %3d, esucc = %5d, secs = %4ld\n", t, a, ages[a], k, 
               pareto_count, fitness_matrix[n], fitness_matrix[n + 1], 
               eval_fail_count, eval_succ_count, elapsed_seconds());

        fflush(stdout);
      }

      if (t % reset_freq == 0) {
        // Reset the bottom layer.
        for (i = 0; i < POP_PER_LAYER; i++) {
          // Try to dislogde in the layer above if it's in the pareto front.
          if (pareto_front[i])
            try_dislodge(genes[i], fitness_matrix + FITNESS_LINDEX(0, i), ages[i], 1);

          init_gene(genes[i]);
          ages[i] = 0;
        }
        for (i = 0; i < POP_PER_LAYER; i++)
          evaluate(genes[i], fitness_matrix + FITNESS_INDEX(i));
        pareto_front_rowmajor(pareto_front, fitness_matrix, POP_PER_LAYER,
                              FITNESS_COUNT);
      }

      copy(genes[a], temp_gene);
      mutate(temp_gene);
      int age = t/POP;
      evaluate(temp_gene, temp_fitness);
      int new_i = try_dislodge(temp_gene, temp_fitness, age, k);
      if (is_goal_fitness(temp_fitness)) {
        if (new_i < 0) {
          printf("warning: goal individual not able to dislodge anyone in layer %d and up.\n", k);
        }
        goal_indiv = new_i;
        break;                  /* Goto next phase */
      }
    }
  }
  end_phase(phase - 1);
  if (steps)
    *steps = t;
  if (t == MAX_OPT_STEPS || elapsed_seconds() > MAX_SECONDS) 
    return ALPS_FAIL;
  else
    return ALPS_SUCC;
}

int main(int argc, char **argv) { 

  int c;
  int argco = argc;
  char **argvo = argv;
  fitness_type = FITNESS_MEAN_LIGHTSENSOR;
  int run_type = STANDARD_RUN;
  pid_t pid = getpid();
  random_seed = (long) time(NULL) ^ pid;
  save_prefix = ".";

  quiet = 0;
  int force = 0;
  while ((c = getopt (argc, argv, "DT:F:s:fqM:d:R:")) != -1) 
    switch (c)
    {
    case 'D':
      run_type = DEBUG_RUN;        break;
    case 'T':
      run_type = atoi(optarg);     break;
    case 'F':
      fitness_type = atoi(optarg); break;
    case 's':
      random_seed = atol(optarg);  break;
    case 'f':
      force = 1;                   break;
    case 'q':
      quiet = 1;                   break;
    case 'M':
      mut_prob = atof(optarg);     break;
    case 'd':
      save_prefix = optarg;        break;
    case 'R':
      reset_freq = atoi(optarg);   break;
    case '?':
      break;
    default:
      abort ();
    }
  // next argument at argv[optind]
  argc -= (optind - 1);
  argv += (optind - 1);
  srand48(random_seed);

  if (! quiet)
    printf("alps-like: Started!\n");
  
  if (run_type == DEBUG_RUN) {
    goal_fitness = 0.9;
  } else if (run_type == EASY_RUN) {
    goal_fitness = 0.8;
  }
  

  if (argc != 4) {
    fprintf(stderr, "usage: alps-like [-fDq] [-M mutP] [-R resetF] [-T run-type] [-F fitness-type] [-d save-dir] <experiment-name> <task-index> <lobotomise> \n");
    fprintf(stderr, "experiment names: An, Bn, Ap, Bp, Ao, Bo\n");
    return 2;
  }

  //register_signal_handlers();
  sim_init();
  exp_name = argv[1];
  task_index = atoi(argv[2]) - 1;
  lobotomise = (atoi(argv[3]) == 1);

  //if (mkdir(save_prefix, 0777)) {
  char cmd[255];
  sprintf(cmd, "mkdir -p %s", save_prefix);
  if (system(cmd)) {
    fprintf(stderr, "error: cannot create directory '%s'.\n", save_prefix);
    return 4;
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

  mprintf(1, "directory -> \"%s\"\n", save_prefix);

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

  if (err) {
    fprintf(stderr, "error: alps-like did not find an adequate solution.\n");
  }
  mprintf(1, "{ success -> %s, exitCode -> %d }\n", err == 0 ? "True" : "False", 
          err);
  
  sprintf(filename, "%s/FAILURE", save_prefix);
  if (err) {
    FILE* fail = fopen(filename, "w");
    fprintf(fail, "%d\n", steps);
    fprintf(fail, "%d\n", err);
    fclose(fail);
  } else {
    unlink(filename);
  }
  sprintf(filename, "%s/SUCCESS", save_prefix);
  if (err) {
    unlink(filename);
  } else {
    FILE* suc = fopen(filename, "w");
    fprintf(suc, "%d\n", steps);
    fclose(suc);
  }
finish:
  if (! quiet)
    printf("alps-like: Finished.  Logs: \n\n\t%s\n", save_prefix);
  sim_uninit();

  if (mfile) fclose(mfile);

  if (table) fclose(table);

  if (script) fclose(script);
  return err;
}
