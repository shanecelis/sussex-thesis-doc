/* alpsish.c */	

#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include <float.h>
#include <strings.h>

#include "run-simulation.h"										
#include "alps.h"
#include "pareto_front.h"

#define rand                 drand48

#define MUT_PROB       0.05     // mutation probability
#define MAX_OPT_STEPS 10000    // max optimisation steps
#define LAYER_COUNT    10
#define FITNESS_COUNT  2
#define POP_PER_LAYER  10
#define POP            (LAYER_COUNT * POP_PER_LAYER)
#define MAX_LAYER      (LAYER_COUNT - 1)

#define LAYER_OF_INDIV(i)    ((i) / POP_PER_LAYER)
/* INDEX = Index of individual */
/* LINDEX = Layer Index (layer, index of individual within layer) */

#define FITNESS_INDEX(i)      ((i) * FITNESS_COUNT)
#define LAYER_BEGINS(l)       (POP_PER_LAYER * (l))
#define INDIV_LINDEX(l, li)   (LAYER_BEGINS(l) + (li))
#define FITNESS_LINDEX(l, li) (INDIV_LINDEX(l, li) * FITNESS_COUNT)


double gene[POP][GENE_COUNT];   // Genotypes of the population.
double age[POP];
double fitness_matrix[POP * FITNESS_COUNT];
int    pareto_front[POP];
int    t;                       /* optimisation step or time */
int    max_age[LAYER_COUNT] = {1,3,5,6,9,
                               29,30,31,60,80};

void init_population() {
  int i;
  for (i=0;i<POP;i++)
    init_gene(gene[i]);
}

void init_gene(double *gene) {
  int i;
  for(i = 0; i < GENE_COUNT; i++)
    gene[i] = rand() * .2; // [0, 1)
}

void mutate(double *gene) {
  int i;
  for(i = 0; i < GENE_COUNT; i++)
    if (rand() < MUT_PROB)
      gene[i] = rand();
}

void copy(double *src, double *dest) {
  memcpy(dest, src, sizeof(double) * GENE_COUNT);
}

int  evaluate(double *gene, double *fitness)
{
  int i;
  for (i = 0; i < FITNESS_COUNT; i++)
    fitness[i] = gene[i];
  return 0;
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
      try_dislodge(gene[INDIV_LINDEX(k, i)],
                   fitness_b,
                   k + 1);
            
      copy(attempter, gene[INDIV_LINDEX(k, i)]);
      memcpy(fitness_b, fitness, sizeof(double) * FITNESS_COUNT);
      age[INDIV_LINDEX(k, i)] = t/POP;
      return INDIV_LINDEX(k, i);
    }
  }
  return -2;
}

int is_goal_fitness(double *fitness) {
  int i;
  for (i = 0; i < FITNESS_COUNT; i++) {
    if (fitness[i] > 0.5)
      return 0;
  }
  return 1;
}

void run_alps(int phase_count)
{
  int i,j,k,p;
  double temp_fitness[FITNESS_COUNT];
  double temp_gene[GENE_COUNT];
  int pareto_front[POP];
  init_population();            // Initialise population.
  t = 0;
  
  for (p = 0; p < phase_count; p++) {
    for (i = 0; i < POP; i++) {
      // Evaluate every gene.
      evaluate(gene[i], fitness_matrix + FITNESS_COUNT * i);
      age[i] = t/POP;
    }
    int met_goal = 0;
    for (j = 0; j < POP; j++) {
      if (is_goal_fitness(fitness_matrix + FITNESS_COUNT * j)) 
        met_goal = 1;
    }
    if (met_goal)
      continue;

    // Evaluate the pareto front for each layer.
    for (k = 0; k < LAYER_COUNT; k++) 
      pareto_front_rowmajor(pareto_front, 
                            fitness_matrix + k * FITNESS_COUNT * POP_PER_LAYER,
                            POP_PER_LAYER,
                            FITNESS_COUNT);
    
    for (;t<MAX_OPT_STEPS;t++) { 
      // Grab a non-dominated individual.
      int a = POP*rand();
      if (! pareto_front[a])
        continue; /* Keep looking for non-dominated genomes. */
      copy(gene[a], temp_gene);
      mutate(temp_gene);
      evaluate(temp_gene, temp_fitness);
      k = LAYER_OF_INDIV(a);
      try_dislodge(temp_gene, temp_fitness, k);
      if (is_goal_fitness(temp_fitness)) {
        printf("met goal!\n");
        break;                  /* Goto next phase */
      }
    }
  }
}

int main(int argc, char **argv) { 
  if (argc == 2) {
    srand48(atoi(argv[1]));
  } else {
    //srand48(time(0));          //Use different random seed for each run
  }
  run_alps(2);
  return 0;
}
