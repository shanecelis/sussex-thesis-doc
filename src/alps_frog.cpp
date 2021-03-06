/*
  alps_frog.cpp 
*/

#include <cmath>
#include <cstdio>
#include <string>
#include <signal.h>
#include <assert.h>
using namespace std;

#include "alps/alps.h"
#include "alps/sstate.h"
#include "alps/gen.h"
#include "alps/layer.h"
#include "alps/individ_real.h"
#include "alps/random_mt.h"
using namespace alps;
using namespace alps_random;

#include "alps_frog.h" 

extern "C" {

#include "run-simulation.h"
#include <unistd.h>
}
#include "genes_real.h"

static int    evaluation_succ_count = 0;
static int    evaluation_failed_count = 0;
static bool   asked_to_terminate = false;

const int     targets_count = 4;
const double  targets[4][2] = {{0., 1.},                  /* north */
                               {-1./M_SQRT2, 1./M_SQRT2}, /* north-west */
                               {-1., 0.},                 /* west */
                               {0., -1.}};                /* south */
const double  target_distance = TARGET_DISTANCE;

const int     task_count = 4;
const double  current_direction[4][2] = {{0.,  0.},   /* none */
                                         {1.,  0.},   /* east */
                                         {0., -1.},   /* south */
                                         {0.,  1.}};  /* current direciton: north */
const double  current_speed = CURRENT_SPEED;

struct fitness_evaluator
{
  bool minimise;
  double (*evaluator)(double * result);
  double goal_fitness;
};

double mean_distance_norm(double * result);
double mean_speed(double * result);

fitness_evaluator fitness_evals[] = {{true,  mean_distance_norm, 0.5},
                                     {false, mean_speed, 10000.0}};

int run_frog(double* genes, 
             double time_max,
             double targetx, double targety, 
             const char *expName, 
             int phase, 
             int lobotomise, 
             int task_index, 
             double* result)
{
  int err;
  double constants[CONSTANTS_COUNT], constants2[CONSTANTS_COUNT], 
    state[STATE_COUNT];

  for (int i = 0; i < GENE_COUNT; i++) {
    constants[i] = genes[i];
  }

  for (int i = 0; i < STATE_COUNT; i++) {
    state[i] = 0.0;
  }

  state[Q_BEGIN(3)] = M_PI;
  constants[TARGET_BEGIN] = targetx;
  constants[TARGET_BEGIN + 1] = targety; 
  experiment_points(expName, time_max, phase, constants + POINTS_BEGIN);

  experiment_init_state(constants + POINTS_BEGIN, 
                        state + TAILSTATE_BEGIN, 
                        state + TAILSTATE_BEGIN + 1);
  err = physics_constants(constants + PHYS_BEGIN); 
  constants[CURRENT_BEGIN] = current_direction[task_index][0] * current_speed;
  constants[CURRENT_BEGIN + 1] = current_direction[task_index][1] * current_speed;
  err = period_constants(constants + PERIOD_BEGIN);
  
  err = gene_to_ctrnn(constants, constants2);

  if (lobotomise) {
    lobotomise_brains(constants2);
  }

  // printf(":m: constants -> { %lf", constants2[0]);
  // for (int i = 1; i < CONSTANTS_COUNT; i++)
  //   printf(", %1.31lf", constants2[i]);
  // printf("}\n");

  if (! err)
    err = run_simulation(state, STEP_SIZE, constants2, time_max, result, NULL);

  if (err) {
    printf("ERROR! err = %d\n", err);
    evaluation_failed_count++;
    return err;
  } else {
    evaluation_succ_count++;
    return 0;
  }
}

double mean_distance_norm(double *result)
{
  /* normalised average distance to target */
  double dist = result[RECORD_BEGIN]/result[0];
  return dist/target_distance;
}

double mean_speed(double *result)
{
  // XXX assumes the initial time was not zero.
  return result[RECORD_BEGIN + 2]/result[0]; 
}

void mean_photosensors(double *result, double *fitness)
{
  fitness[0] = result[RECORD_BEGIN + 4]/(result[0] * TARGET_DISTANCE);
  fitness[1] = result[RECORD_BEGIN + 5]/(result[0] * TARGET_DISTANCE);
}


int evaluate_frog(double* fitness, 
                   double* genes, 
                   //Individual* individ,
                   const char* expName, int phase, 
                   int task_index, int lobotomise, int fitness_type) 
{
  if (task_index < 0) {
    cerr << "error: task_index < 0" << endl;
    return 1;
  }
  if (task_index >= task_count) {
    cerr << "error: task_index >= task_count" << endl;
    return 2;
  }
  double time_max = TIME_MAX;
  double result[STATE_COUNT];
  int target_index = 0;
  int err = run_frog(genes,
                     time_max,
                     targets[target_index][0] * target_distance, 
                     targets[target_index][1] * target_distance,
                     expName, phase, lobotomise, task_index, result);

  // double (*fitfunc)(double *) = fitness_evals[fitness_type].evaluator;
  // fitness[0] = (*fitfunc)(result);
  assert(fitness_type == FITNESS_MEAN_LIGHTSENSOR);
  mean_photosensors(result, fitness);

  if (err || isnan(fitness[0])) {
    //cerr << "BAD err = " << err << "fitness " << fitness[0] << " " << evaluation_failed_count << endl;
    return 3;
  } else {
    //cerr << "fitness " << fitness[0] << " " << evaluation_succ_count << endl;
    return 0;
  }
}


void setup_pop_gen(Individual* individ_config, AlpsSState* pop, int run_type)
{
  (void) individ_config;
  AlpsLayer layer_def;
  //int type = 2;                 // standard
  //int type = 3;                 // debug
  int age_gap = 5;
  int age_scheme = ALPS_AGING_FIBONACCI1;
  int Number_Layers = -1;

  pop->set_max_evals(MAX_EVALS);

    if (run_type == 0 /* 2 */ ) {
    Number_Layers = 16;
    age_gap = 10; //4
    //age_scheme = ALPS_AGING_EXP3;
    layer_def.set_select_type(ALPS_SELECT_TOURN);
    //    layer_def.set_select_type(ALPS_SELECT_DC);
    layer_def.set_size(5);
    layer_def.set_elitism(1);
    layer_def.set_tourn_size(2);
    layer_def.set_prob_select_prev(0.2);
    pop->set_recomb_prob(0.5);
    pop->set_rec_rand2_prob(1.0);
    pop->set_print_gen_stats(true);
    pop->set_print_results_rate(1000);

  } else if (run_type == 1/*3*/) {

    // For debug purposes.
    Number_Layers = 3;
    age_gap = 1; 
    layer_def.set_select_type(ALPS_SELECT_TOURN);
    layer_def.set_size(5);
    layer_def.set_elitism(0);
    layer_def.set_tourn_size(2);
    layer_def.set_prob_select_prev(0.2);
    pop->set_recomb_prob(0.5);
    pop->set_rec_rand2_prob(1.0);
    pop->set_print_results_rate(9);
    pop->set_max_evals(1000);
    fitness_evals[0].goal_fitness = 0.9;
    pop->set_print_gen_stats(true);
  } else {
    cerr << "alps_frog :: setup_pop_gen() - error, invalid EA run_type:"
         << run_type << "\n";
    return;
  }

  pop->config_layers_same(age_scheme, age_gap,
                          Number_Layers, layer_def);
  pop->set_num_runs(1);
}


char *save_population(Alps* pop, const char *pop_save_prefix, const char *suffix)
{
  static char pop_save_name[255];
  sprintf(pop_save_name, "%s%s.pop", 
          pop_save_prefix,
          suffix);
  pop->write(pop_save_name);
  return pop_save_name;
}

char *save_population_for_phase(Alps* pop, const char *pop_save_prefix, int phase)
{
  char suffix[255];
  const char *good_prefix = "";
  const char *bad_prefix = "BAD"; /* early terminated */
  sprintf(suffix, "%s%d", 
          phase < 0 ? bad_prefix : good_prefix, 
          phase);
  return save_population(pop, pop_save_prefix, suffix);
}

int write_array(const char *filename, int n, double *array) {
  FILE *in = fopen(filename, "w");
  int fd = fileno(in);
  write(fd, &n, sizeof(int));
  write(fd, array, sizeof(double) * n);
  fclose(in);
  return 0;
}

int read_array(const char *filename, int *n, double *array) {
  FILE *in = fopen(filename, "r");
  int fd = fileno(in);
  read(fd, n, sizeof(int));
  read(fd, array, sizeof(double) * *n);
  fclose(in);
  return 0;
}

char *save_genes_for_phase(double *genes, const char *save_prefix, 
                           int phase)
{
  static char gene_save_name[255];
  sprintf(gene_save_name, "%s/phase%d-genes.bin", save_prefix, phase);

  write_array(gene_save_name, GENE_COUNT, genes);
  return gene_save_name;
}

int ea_engine(const char *exp_name, int task_index, int lobotomise, 
              const char *pop_save, int fitness_type, int run_type)
{
  time_t begin = time(NULL);
  pid_t pid = getpid();
  seed_random((long) time(NULL) ^ pid);
  long random_seed = get_random_seed();
  if (is_random_seed_set()) { 
    cout << "random-seed-set " << random_seed << endl;
  } else {
    cout << "random-seed-NOT-set " << random_seed << endl;
  }

  int Number_Genes = GENE_COUNT; // minus the size of the target
  //const char *exp_name = "Ap";
  int phase = 1;
  int phase_count;
  int err = 0;
  err = experiment_phase_count(exp_name, &phase_count);
  if (err) {
    cerr << "error: phase count failed (" << err << ")" << endl;
    return err;
  }

  printf(":m: (* Preamble *)\n");
  printf(":m: {expName -> %s, phaseCount -> %d, lobotomise -> %s, task -> %d, "
         "tmax -> %.2lf, fitnessType -> %d, runType -> %d, randomSeed -> %ld }\n",
         exp_name, phase_count, lobotomise ? "True" : "False", task_index + 1, 
         TIME_MAX, fitness_type, run_type, random_seed);
  fflush(stdout);

  /*Genes_Real *individ_config = new Genes_Real(Number_Genes);
    individ_config->mutate_prob = 0.05;*/
  Individ_Real *individ_config = new Individ_Real(Number_Genes);

  individ_config->set_init_minmax(0.0, 1.0);
  individ_config->set_minmax(0.0, 1.0);

  // cout <<  "individ_config " << individ_config << endl;
  // individ_config->write(cout);

  vector<double> fitness;
  fitness.resize(1); 

  // Configure a generational ALPS population:
  Alps *Population = new AlpsSState("frog", individ_config);
  setup_pop_gen(individ_config, (AlpsSState*)Population, run_type);

  //Population->set_print_debug(true);
  //Population->write_header(cout);
  bool expected_termination = false;
  fitness_evaluator fit_eval = fitness_evals[fitness_type];
  
  if (fit_eval.minimise) {
    Population->set_minimize();
  } else {
    Population->set_maximize();
  }
  
  while (!Population->is_finished()) {
    int index;
    Individual* individ;
    int res = Population->get_next_individ(index, individ);
    if (res == -1) {
      continue; // Get another index / Try again.

    } else if (res == -2) {
      // Evolution is over.
      break;
    }

    vector<double> fitness;
    fitness.resize(FITNESS_COUNT);
    vector<double> genes = ((Individ_Real*)individ)->get_genes();
    double cgenes[GENE_COUNT], cfitness[FITNESS_COUNT];
    int i;
    for (i = 0; i < GENE_COUNT; i++)
      cgenes[i] = genes[i];
    int err = evaluate_frog(cfitness, 
                               cgenes,
                               //individ, 
                               exp_name, phase, 
                               task_index, 
                               lobotomise,
                               fitness_type);
    for (i = 0; i < FITNESS_COUNT; i++)
      fitness[i] = cfitness[i];
    if (err) {
      // Error evaluating this individual.
      Population->evaluate_error(index, individ);
    } else {
      // Evaluated successfully.
      Population->insert_evaluated(fitness, index, individ, 0);
      if ((fit_eval.minimise && fitness[0] < fit_eval.goal_fitness) ||
          (!fit_eval.minimise && fitness[0] > fit_eval.goal_fitness)) {
        // Finished with this stage possibly complete.

        save_population_for_phase(Population, pop_save, phase);

        cout << phase << " " << evaluation_failed_count << " "<< evaluation_succ_count << endl;
        vector<double> genes = ((Individ_Real*)individ)->get_genes();
        for (i = 0; i < GENE_COUNT; i++)
          cgenes[i] = genes[i];
        char *gene_bin = save_genes_for_phase(cgenes, pop_save, phase);

        printf(":m:\n");
        printf(":m: (* End of phase %d *)\n", phase);
        printf(":m: {expName -> %s, phaseCount -> %d, lobotomise -> %s, task -> %d, "
               "tmax -> %.2lf, fitnessType -> %d, runType -> %d, randomSeed -> %ld, \n"
               ":m:  phase   -> %d, evalFailedCount -> %d, evalSuccCount -> %d, fitness -> %lf, "
               "bestGeneFilename -> \"%s\", \n"
               ":m:  bestGene -> { %lf", 
               exp_name, phase_count, lobotomise ? "True" : "False", task_index + 1, 
               TIME_MAX, fitness_type, run_type, random_seed, 
               phase, evaluation_failed_count, evaluation_succ_count, 
               fitness[0], gene_bin, genes[0]);
        for (int i = 1; i < GENE_COUNT; i++) 
          printf(", %lf", genes[i]);
        printf("} }\n");



        phase++;
        if (phase > phase_count) {
          expected_termination = true;
          break;
        }
      }
    }
    if (asked_to_terminate) {
      char *filename = save_population(Population, pop_save, "KILLED");
      cerr << "warning: killed; writing population to '" << filename << "'." << endl;
      cout << "CTRL-C KILLED" << endl;
      break;
    }
    // Add a timeout.
  }
  if (! expected_termination) {
    if (! asked_to_terminate) {
      cout << (-phase) << " " << evaluation_failed_count << " "<< evaluation_succ_count << endl;
      save_population_for_phase(Population, pop_save, -phase);
      err = 1;    
    } else {
      err = 3;
    }
  } else {
    save_population(Population, pop_save, "FINAL");
  }
  time_t end = time(NULL);
  cout << "seconds-elapsed " << (end - begin) << endl;
  return err;
}

void register_signal_handlers()
{
  (void) signal(SIGINT, signal_func);
}

void signal_func(int sig)
{
  asked_to_terminate = true;
}
