/* run-simulation.h */

#define METERS           1.0

#define TARGET_DISTANCE  (0.1 * METERS)

#define STEP_SIZE        0.02

// state info
#define STATE_COUNT      26
#define QSTATE_BEGIN     1
#define USTATE_BEGIN     9
#define TAILSTATE_BEGIN  22
#define RECORD_BEGIN     24
#define RECORD_COUNT     2
#define Q_BEGIN(n)       (QSTATE_BEGIN + (n - 1))
#define U_BEGIN(n)       (USTATE_BEGIN + (n - 1))

// constants info
#define GENE_COUNT       105
#define TARGET_COUNT     2
#define POINTS_COUNT     12
#define CONSTANTS_COUNT  (GENE_COUNT + TARGET_COUNT + POINTS_COUNT)
#define TARGET_BEGIN     (GENE_COUNT)
#define POINTS_BEGIN     (GENE_COUNT + TARGET_COUNT)

//#define runSimulation runSimulationAdaptive
//#define Initialize_runSimulation Initialize_runSimulationAdaptive
//#define Uninitialize_runSimulation Uninitialize_runSimulationAdaptive

int sim_init();

int sim_uninit();

int experiment_phase_count(const char *expName, int *phase_count);

int experiment_points(const char *expName, double timeMax, 
                      int phase, double *pointsResult);

void experiment_init_state(double *points, double *t0, double *f0);

int run_simulation(double *stateArg, double stepSize, double *constantsArg, 
                   double timeArg, double *stateResult);

void lobotomise_brains(double *constants);
