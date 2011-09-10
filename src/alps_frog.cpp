/*
  alps_frog.cpp 
*/

#include <cmath>
#include <cstdio>
#include <string>
#include <signal.h>
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

#define STANDARD_TYPE 2
#define DEBUG_TYPE    3

static int    type = STANDARD_TYPE;

struct fitness_evaluator
{
  bool minimise;
  double (*evaluator)(double * result, double time_max);
  double goal_fitness;
};

double mean_distance_norm(double * result, double time_max);
double mean_speed(double * result, double time_max);

fitness_evaluator fitness_evals[] = {{true,  mean_distance_norm, 0.5},
                                     {false, mean_speed, 10000.0}};

int run_frog(const vector<double>& genes, 
             double time_max,
             double targetx, double targety, 
             const char *expName, 
             int phase, bool lobotomise, double* result)
{
  int err;
  double constants[CONSTANTS_COUNT], constants2[CONSTANTS_COUNT], state[STATE_COUNT];//, result[STATE_COUNT];

  for (int i = 0; i < GENE_COUNT; i++) {
    constants[i] = genes[i];
  }

  for (int i = 0; i < STATE_COUNT; i++) {
    state[i] = 0.0;
  }
  
  constants[TARGET_BEGIN] = targetx;
  constants[TARGET_BEGIN + 1] = targety; 
  experiment_points(expName, time_max, phase, constants + POINTS_BEGIN);

  experiment_init_state(constants + POINTS_BEGIN, 
                        state + TAILSTATE_BEGIN, 
                        state + TAILSTATE_BEGIN + 1);
  if (lobotomise) {
    lobotomise_brains(constants);
  }
  err = physics_constants(constants + PHYS_BEGIN);
  err = period_constants(constants + PERIOD_BEGIN);
  
  err = gene_to_ctrnn(constants, constants2);

  // printf(":m: constants -> { %lf", constants2[0]);
  // for (int i = 1; i < CONSTANTS_COUNT; i++)
  //   printf(", %1.31lf", constants2[i]);
  // printf("}\n");

  if (! err)
    err = run_simulation(state, STEP_SIZE, constants2, time_max, result, NULL);

  if (err) {
    //printf("ERROR!\n");
    evaluation_failed_count++;
    return err;
  } else {
    evaluation_succ_count++;
    return 0;
  }
}

double mean_distance_norm(double *result, double time_max)
{
  /* normalised average distance to target */
  double dist = result[RECORD_BEGIN]/result[0];
  return dist/target_distance;
}

double mean_speed(double *result, double time_max)
{
  // XXX assumes the initial time was not zero.
  return result[RECORD_BEGIN + 2]/result[0]; 
}

bool evaluate_frog(vector<double>& fitness, 
                   vector<double>& genes, 
                   //Individual* individ,
                   const char* expName, int phase, 
                   int target_index, bool lobotomise, int fitness_type)
{
  if (target_index < 0) {
    cerr << "error: target_index < 0" << endl;
    return false;
  }
  if (target_index >= targets_count) {
    cerr << "error: target_index >= targets_count" << endl;
    return false;
  }
  double time_max = TIME_MAX;
  double result[STATE_COUNT];
  int err = run_frog(genes,
    //((Individ_Real*)individ)->get_genes(), 
                     time_max,
                     targets[target_index][0] * target_distance, 
                     targets[target_index][1] * target_distance,
                     expName, phase, lobotomise, result);

  double (*fitfunc)(double *, double) = fitness_evals[fitness_type].evaluator;
  fitness[0] = (*fitfunc)(result, time_max);

  if (err || isnan(fitness[0])) {
    //cerr << "BAD fitness " << fitness[0] << " " << evaluation_failed_count << endl;
    return false;
  } else {
    //cerr << "fitness " << fitness[0] << " " << evaluation_succ_count << endl;
    return true;
  }
}


void setup_pop_gen(Individual* individ_config, AlpsSState* pop)
{
  (void) individ_config;
  AlpsLayer layer_def;
  //int type = 2;                 // standard
  //int type = 3;                 // debug
  int age_gap = 5;
  int age_scheme = ALPS_AGING_FIBONACCI1;
  int Number_Layers = -1;

  pop->set_max_evals(MAX_EVALS);

  if (type == 1) {
    // Configuration for a regular EA/GA:
    Number_Layers = 1;
    layer_def.set_select_type(ALPS_SELECT_TOURN);
    layer_def.set_size(10);
    layer_def.set_elitism(1);
    layer_def.set_tourn_size(2);
    pop->set_recomb_prob(0.5);
    pop->set_rec_rand2_prob(1.0); // 1.0
    //pop->set_print_results_rate(100); // 400

  } else if (type == 2) {
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

  } else if (type == 3) {

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
    cerr << "alps_frog :: setup_pop_gen() - error, invalid EA type:"
         << type << "\n";
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


char *save_genes_for_phase(vector<double>& genes, const char *pop_save_prefix, 
                           int phase)
{
  static char gene_save_name[255];
  sprintf(gene_save_name, "%s%d-genes.bin", pop_save_prefix, phase);

  double dgenes[GENE_COUNT];
  for (int i = 0; i < GENE_COUNT; i++) 
    dgenes[i] = genes[i];
  write_array(gene_save_name, GENE_COUNT, dgenes);
  return gene_save_name;
}

int ea_engine(const char *exp_name, int target_index, bool lobotomise, 
              const char *pop_save, int fitness_type)
{
  time_t begin = time(NULL);
  pid_t pid = getpid();
  seed_random((long) time(NULL) ^ pid);
  if (is_random_seed_set()) {
    cout << "random-seed-set " << get_random_seed() << endl;
  } else {
    cout << "random-seed-NOT-set " << get_random_seed() << endl;
  }
  cout << "fitness-type " << fitness_type << endl;

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
  setup_pop_gen(individ_config, (AlpsSState*)Population);

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
    fitness.resize(1);
    vector<double> genes = ((Individ_Real*)individ)->get_genes();
    int result = evaluate_frog(fitness, 
                               genes,
                               //individ, 
                               exp_name, phase, 
                               target_index, 
                               lobotomise,
                               fitness_type);

    if (result == false) {
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
        printf(":m: {expName -> %s, phase -> %d, tmax -> %lf, "
               "evalFailedCount -> %d, evalSuccCount -> %d, fitness -> %lf, "
               "bestGene -> { %lf", 
               exp_name, phase, TIME_MAX, evaluation_failed_count, 
               evaluation_succ_count, fitness[0], genes[0]);
        for (int i = 1; i < GENE_COUNT; i++) 
          printf(", %lf", genes[i]);
        printf("} }\n");

        save_genes_for_phase(genes, pop_save, phase);

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
