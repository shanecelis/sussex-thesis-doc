/*
  alps_frog.cpp 
*/

#include "alps/alps.h"
#include "alps/sstate.h"
#include "alps/gen.h"
#include "alps/layer.h"
#include "alps/individ_real.h"
#include "alps/random_mt.h"
using namespace alps;
using namespace alps_random;

#include <cmath>
#include <cstdio>
#include <string>
using namespace std;

extern "C" {
#include "run-simulation.h"
}
#include "genes_real.h"

static int evaluation_succ_count = 0;
static int evaluation_failed_count = 0;
static double goal_fitness = 0.5;

const int target_count = 4;
const double targets[4][2] = {{0., 1.},                  /* north */
                              {-1./M_SQRT2, 1./M_SQRT2}, /* north-west */
                              {-1., 0.},                 /* west */
                              {0., -1.}};                /* south */
const double target_distance = TARGET_DISTANCE;

double run_frog(const vector<double>& genes, 
                double targetx, double targety, 
                const char *expName, 
                int phase, bool lobotomise)
{
  int err;
  double constants[CONSTANTS_COUNT], state[STATE_COUNT], result[STATE_COUNT];

  double timeMax = 10.;

  for (int i = 0; i < GENE_COUNT; i++) {
    constants[i] = genes[i];
  }

  for (int i = 0; i < STATE_COUNT; i++) {
    state[i] = 0.0;
  }
  state[0] = 0.0;
  state[RECORD_BEGIN] = 0.0;
  
  constants[TARGET_BEGIN] = targetx;
  constants[TARGET_BEGIN + 1] = targety;
  experiment_points(expName, timeMax, phase, constants + POINTS_BEGIN);
  experiment_init_state(constants + POINTS_BEGIN, 
                        state + TAILSTATE_BEGIN, 
                        state + TAILSTATE_BEGIN + 1);
  if (lobotomise) {
    lobotomise_brains(constants);
  }

  err = run_simulation(state, timeMax, constants, result);

  if (err) {
    evaluation_failed_count++;
    return 666.6;
  } else {
    evaluation_succ_count++;
    return result[RECORD_BEGIN]/timeMax;
  }
}

bool evaluate_frog(vector<double>& fitness, 
                   Individual* individ,
                   const char* expName, int phase, 
                   int target_index, bool lobotomise)
{
  if (target_index >= target_count) {
    cerr << "error: target_index >= target_count" << endl;
    return false;
  }
  double dist = run_frog(((Individ_Real*)individ)->get_genes(), 
                         targets[target_index][0] * target_distance, 
                         targets[target_index][1] * target_distance, 
                         expName, phase, lobotomise);

  fitness[0] = dist/target_distance;

  return true;
}

void setup_pop_gen(Individual* individ_config, AlpsSState* pop)
{
  (void) individ_config;
  //pop->set_save_best(true);
  AlpsLayer layer_def;
  int type = 3;
  int age_gap = 5;
  int age_scheme = ALPS_AGING_FIBONACCI1;
  int Number_Layers = -1;

  pop->set_max_evals(1000);

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
    Number_Layers = 5;
    age_gap = 3; //4
    //age_scheme = ALPS_AGING_EXP3;
    layer_def.set_select_type(ALPS_SELECT_TOURN);
    //    layer_def.set_select_type(ALPS_SELECT_DC);
    layer_def.set_size(10);
    layer_def.set_elitism(0);
    layer_def.set_tourn_size(2);
    layer_def.set_prob_select_prev(0.2);
    pop->set_recomb_prob(0.5);
    pop->set_rec_rand2_prob(1.0);
    pop->set_print_results_rate(1000);

  } else if (type == 3) {

    // For debug purposes.
    Number_Layers = 3;
    age_gap = 3; //4
    //age_scheme = ALPS_AGING_EXP3;
    layer_def.set_select_type(ALPS_SELECT_TOURN);
    //    layer_def.set_select_type(ALPS_SELECT_DC);
    layer_def.set_size(5);
    layer_def.set_elitism(0);
    layer_def.set_tourn_size(2);
    layer_def.set_prob_select_prev(0.2);
    pop->set_recomb_prob(0.5);
    pop->set_rec_rand2_prob(1.0);
    pop->set_print_results_rate(100);

    pop->set_max_evals(100);
    goal_fitness = 0.9;
  } else {
    cerr << "evo_real_barebones :: setup_pop_gen() - error, invalid EA type:"
         << type << "\n";
    return;
  }

  pop->config_layers_same(age_scheme, age_gap,
                          Number_Layers, layer_def);
  pop->set_num_runs(1);
}

int ea_engine(const char *exp_name, int target_index, bool lobotomise, 
              const char *pop_save)
{
  
  seed_random((long) time(NULL));
  if (is_random_seed_set()) {
    cout << "random-seed-set " << get_random_seed() << endl;
  } else {
    cout << "random-seed-NOT-set " << get_random_seed() << endl;
  }

  int Number_Genes = GENE_COUNT; // minus the size of the target
  //const char *exp_name = "Ap";
  int phase = 1;
  int phase_count;
  int err;
  err = experiment_phase_count(exp_name, &phase_count);
  if (err) {
    cerr << "error: phase count failed (" << err << ")" << endl;
    err;
  }

  Genes_Real *individ_config = new Genes_Real(Number_Genes);
  individ_config->mutate_prob = 0.05;
  //Individ_Real *individ_config = new Individ_Real(Number_Genes);

  individ_config->set_init_minmax(0.0, 1.0);
  individ_config->set_minmax(0.0, 1.0);

  // cout <<  "individ_config " << individ_config << endl;
  // individ_config->write(cout);

  vector<double> fitness;
  fitness.resize(1); 

  // Configure a generational ALPS population:
  Alps *Population = new AlpsSState("frog", individ_config);
  setup_pop_gen(individ_config, (AlpsSState*)Population);

  // Population->set_print_debug(true);
  Population->set_minimize();
  //Population->set_maximize();
  //Population->write_header(cout);
  bool expected_termination = false;
  
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
    fitness.resize(5);
    int result = evaluate_frog(fitness, individ, 
                               exp_name, phase, 
                               target_index, 
                               lobotomise);
    if (result == false) {
      // Error evaluating this individual.
      Population->evaluate_error(index, individ);
    } else {
      // Evaluated successfully.
      Population->insert_evaluated(fitness, index, individ, 0);
      if (fitness[0] < goal_fitness) {
        // Finished with this stage possibly complete.
        char pop_save_name[255];
        sprintf(pop_save_name, "%s-%d.pop", pop_save, phase);
        Population->write(pop_save_name);

        cout << phase << " " << evaluation_failed_count << " "<< evaluation_succ_count << endl;
        phase++;
        if (phase > phase_count) {
          expected_termination = true;
          break;
        }
      }
    }
  }
  if (! expected_termination) {
    cout << "-1 " << evaluation_failed_count << " "<< evaluation_succ_count << endl;
    char pop_save_name[255];
    sprintf(pop_save_name, "%s--1.pop", pop_save);
    Population->write(pop_save_name);
    return 1;    
  }

  return 0;
}
