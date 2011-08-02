/*
  alps_frog.cpp 
*/

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
}

static int evaluation_count = 0;

double run_frog(const vector<double>& genes, 
                double targetx, double targety, 
                const char *expName, 
                int phase)
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
  
  // const char *expName = "Ao";
  // int phase = 1;

  constants[TARGET_BEGIN] = targetx;
  constants[TARGET_BEGIN + 1] = targety;
  experiment_points(expName, timeMax, phase, constants + POINTS_BEGIN);
  experiment_init_state(constants + POINTS_BEGIN, 
                        state + TAILSTATE_BEGIN, 
                        state + TAILSTATE_BEGIN + 1);

  err = run_simulation(state, timeMax, constants, result);

  if (err) {
    return 666.6;
  } else {
    return result[RECORD_BEGIN]/timeMax;
  }
}

bool evaluate_frog(vector<double>& fitness, 
                   const vector<double>& genes, 
                   const char* expName, int phase)
{
  double dist = 0.0;
  dist = max(dist, run_frog(genes, 0.0, 0.1 * METERS, 
                            expName, phase));
  // dist = max(dist, run_frog(genes, -0.1 * METERS, 0.0));
  // dist = max(dist, run_frog(genes, 0.0, -0.1 * METERS));
  // dist = max(dist, run_frog(genes, 0.1 * METERS, 0.0));

  fitness[0] = dist/(0.1 * METERS);

  //cout <<  "fitness " << fitness[0] << endl;
  return true;
}

// bool evaluate_frog_multi(vector<double>& fitness, const vector<double>& genes)
// {
//   fitness[0] = 3. + 0. * run_frog(genes, 1.0, 1.0);
//   fitness[1] = 2. + 0. *run_frog(genes, 1.0, 0.0);
//   fitness[2] = run_frog(genes, 0.0, 1.0);
//   fitness[3] = run_frog(genes, -1.0, 0.0);
//   fitness[4] = run_frog(genes, 0.0, -1.0);

//   return true;
// }


bool evaluate_individ(vector<double>& fitness, Individual* individ, 
                      const char *expName, int phase)
{
  if (individ == NULL) {
    cerr << "evo_real :: evaluate_individ() - error, null individ sent.\n";
    while (1) ;
    return false;
  }

  bool res = evaluate_frog(fitness, ((Individ_Real*)individ)->get_genes(), 
                           expName, phase);
  evaluation_count++;

  return res;
}

void setup_pop_gen(Individual* individ_config, AlpsSState* pop)
{
  (void) individ_config;
  //pop->set_save_best(true);
  AlpsLayer layer_def;
  int type = 2;
  int age_gap = 5;
  int age_scheme = ALPS_AGING_FIBONACCI1;
  int Number_Layers = -1;
  if (type == 1) {
    // Configuration for a regular EA/GA:
    Number_Layers = 1;
    layer_def.set_select_type(ALPS_SELECT_TOURN);
    layer_def.set_size(10);
    layer_def.set_elitism(1);
    layer_def.set_tourn_size(2);
    pop->set_recomb_prob(0.5);
    pop->set_rec_rand2_prob(1.0); // 1.0
    pop->set_print_results_rate(100); // 400

  } else if (type == 2) {
    Number_Layers = 5;
    age_gap = 3; //4
    //age_scheme = ALPS_AGING_EXP3;
    layer_def.set_select_type(ALPS_SELECT_TOURN);
    //    layer_def.set_select_type(ALPS_SELECT_DC);
    layer_def.set_size(10);
    layer_def.set_elitism(1);
    layer_def.set_tourn_size(2);
    layer_def.set_prob_select_prev(0.2);
    pop->set_recomb_prob(0.5);
    pop->set_rec_rand2_prob(1.0);
    //pop->set_print_results_rate(10);

  } else if (type == 3) {
    Number_Layers = 10;
    age_gap = 3; //4
    age_scheme = ALPS_AGING_EXP3;
    //    layer_def.set_select_type(ALPS_SELECT_TOURN);
    layer_def.set_select_type(ALPS_SELECT_DC);
    layer_def.set_size(40);
    layer_def.set_elitism(0);
    layer_def.set_tourn_size(5);
    layer_def.set_prob_select_prev(0.25);
    pop->set_recomb_prob(0.5);
    pop->set_rec_rand2_prob(1.0);
    pop->set_print_results_rate(400);

  } else {
    cerr << "evo_real_barebones :: setup_pop_gen() - error, invalid EA type:"
         << type << "\n";
    return;
  }

  pop->config_layers_same(age_scheme, age_gap,
                          Number_Layers, layer_def);
  //pop->print_layers();
  pop->set_num_runs(1);
  pop->set_max_gen(2500);
  //pop->set_max_gen(100);
  //pop->set_max_gen(1);
}

int ea_engine(const char *exp_name, const char *pop_save)
{
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

  Individ_Real *individ_config = new Individ_Real(Number_Genes);
  individ_config->set_init_minmax(0.0, 1.0);
  individ_config->set_minmax(0.0, 1.0);

  // cout <<  "individ_config " << individ_config << endl;
  // individ_config->write(cout);

  vector<double> fitness;
  fitness.resize(1); 

  // Configure a generational ALPS population:
  //Alps *Population = new AlpsGen("frog", individ_config);
  Alps *Population = new AlpsSState("frog", individ_config);
  setup_pop_gen(individ_config, (AlpsSState*)Population);

  // Population->set_print_debug(true);
  Population->set_minimize();
  //Population->set_maximize();
  //Population->write_header(cout);
  
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
    int result = evaluate_individ(fitness, individ, exp_name, phase);
    if (result == false) {
      // Error evaluating this individual.
      Population->evaluate_error(index, individ);
    } else {
      // Evaluated successfully.
      Population->insert_evaluated(fitness, index, individ, 0);
      if (fitness[0] < 0.5) {
        // Finished with this stage possibly complete.
        cerr << "XXX End of phase " << phase << " evaluation count " << evaluation_count << endl;
        cout << phase << " " << evaluation_count << endl;
        phase++;
        if (phase > phase_count)
          break;
      }
    }
  }
  //cout << "Best individual:" << endl;
  //cout << "XXX Final evaluation count " << evaluation_count << endl;
  //Population->write_best_individ();
  Population->write(pop_save);

  //printf("EA engine ended.\n");

  return 0;
}
