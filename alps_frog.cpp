/*
  alps_frog.cpp 
*/

#include "alps/alps.h"
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

double run_frog(const vector<double>& genes, double targetx, double targety)
{
  int err;
  double constants[CONSTANTS_COUNT], state[STATE_COUNT], result[STATE_COUNT];

  double timeMax = 20.;

  for (int i = 0; i < GENE_COUNT; i++) {
    constants[i] = genes[i];
  }

  for (int i = 0; i < STATE_COUNT; i++) {
    state[i] = 0.01;
  }
  state[RECORD_BEGIN] = 0.0;

  constants[TARGET_BEGIN] = targetx;
  constants[TARGET_BEGIN + 1] = targety;
  experiment_points("Ao", timeMax, 1, constants + POINTS_BEGIN);
  experiment_init(constants + POINTS_BEGIN, 
                  state + TAILSTATE_BEGIN, 
                  state + TAILSTATE_BEGIN + 1);

  err = run_simulation(state, timeMax, constants, result);

  if (err) {
    return -1.;
  } else {
    return result[RECORD_BEGIN]/timeMax;
  }
}

bool evaluate_frog(vector<double>& fitness, const vector<double>& genes)
{
  double dist = 0.0;
  dist = max(dist, run_frog(genes, 0.0, 1.0 * METERS));
  dist = max(dist, run_frog(genes, -1.0 * METERS, 0.0));
  dist = max(dist, run_frog(genes, 0.0, -1.0 * METERS));
  dist = max(dist, run_frog(genes, 1.0 * METERS, 0.0));

  fitness[0] = dist/(1 * METERS);

  cout <<  "fitness " << fitness[0] << endl;
  return true;
}

bool evaluate_frog_multi(vector<double>& fitness, const vector<double>& genes)
{
  fitness[0] = 3. + 0. * run_frog(genes, 1.0, 1.0);
  fitness[1] = 2. + 0. *run_frog(genes, 1.0, 0.0);
  fitness[2] = run_frog(genes, 0.0, 1.0);
  fitness[3] = run_frog(genes, -1.0, 0.0);
  fitness[4] = run_frog(genes, 0.0, -1.0);

  return true;
}


bool evaluate_individ(vector<double>& fitness, Individual* individ)
{
  if (individ == NULL) {
    cerr << "evo_real :: evaluate_individ() - error, null individ sent.\n";
    while (1) ;
    return false;
  }

  bool res = evaluate_frog(fitness, ((Individ_Real*)individ)->get_genes());

  return res;
}

void setup_pop_gen(Individual* individ_config, AlpsGen* pop)
{
  (void) individ_config;
  pop->set_save_best(true);
  AlpsLayer layer_def;
  int type = 1;
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
    pop->set_print_results_rate(400); // 400

  } else if (type == 2) {
    Number_Layers = 5;
    age_gap = 3; //4
    age_scheme = ALPS_AGING_EXP3;
    layer_def.set_select_type(ALPS_SELECT_TOURN);
    //    layer_def.set_select_type(ALPS_SELECT_DC);
    layer_def.set_size(40);
    layer_def.set_elitism(1);
    layer_def.set_tourn_size(2);
    layer_def.set_prob_select_prev(0.2);
    pop->set_recomb_prob(0.5);
    pop->set_rec_rand2_prob(1.0);
    pop->set_print_results_rate(10);

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
  pop->print_layers();
  pop->set_num_runs(1);
//pop->set_max_gen(2525);
  //pop->set_max_gen(100);
  pop->set_max_gen(1);
}

void *ea_engine(void *arg1)
{
  (void) arg1; // getting rid of unused parameter warning.
  cout << "EA engine started.\n";

  int Number_Genes = GENE_COUNT; // minus the size of the target
  
  Individ_Real *individ_config = new Individ_Real(Number_Genes);
  individ_config->set_init_minmax(0.0, 1.0);
  individ_config->set_minmax(0.0, 1.0);

  cout <<  "individ_config " << individ_config << endl;
  individ_config->write(cout);

  vector<double> fitness;
  fitness.resize(5); // multi objective

  // Configure a generational ALPS population:
  Alps *Population = new AlpsGen("frog", individ_config);
  setup_pop_gen(individ_config, (AlpsGen*)Population);

  // Population->set_print_debug(true);
  Population->set_minimize();
  //Population->set_maximize();
  Population->write_header(cout);

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
    int result = evaluate_individ(fitness, individ);
    if (result == false) {
      // Error evaluating this individual.
      Population->evaluate_error(index, individ);
    } else {
      // Evaluated successfully.
      Population->insert_evaluated(fitness, index, individ, 0);
    }
  }
  //cout << "Best individual:" << endl;

  //Population->write_best_individ();
  Population->write("last-population.txt");

  printf("EA engine ended.\n");

  return 0;
}

int main(int argc, char **argv) {
    
  (void) argc;
  (void) argv;
  if (argc == 2) {
    Individ_Real *individ = new Individ_Real(10);    
    individ->read(argv[1]);
    vector<double> fitness;
    fitness.resize(5);
    evaluate_individ(fitness, individ);
    cout << "fitness: " << fitness[0] << endl;
  } else {
    ea_engine(0);
  }
  return 0;
}


