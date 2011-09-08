/* run-simulation.h */

#define METERS           1.0
#define TIME_MAX         10.0
#define BODY_RADIUS      (0.025 * METERS)

#define TARGET_DISTANCE  (0.25 * METERS) 

#define STEP_SIZE        0.01
#define MAX_STEPS        10000

#define MAX_EVALS        60000
//#define MAX_EVALS        10

// state info
#define TIME_COUNT       1
#define QSTATE_COUNT     8
#define USTATE_COUNT     8
#define NODE_COUNT       5
#define TAILSTATE_COUNT  2
#define RECORD_COUNT     4
#define STATE_COUNT      (TIME_COUNT + QSTATE_COUNT + USTATE_COUNT + NODE_COUNT + TAILSTATE_COUNT + RECORD_COUNT)

#define QSTATE_BEGIN     TIME_COUNT
#define USTATE_BEGIN     (TIME_COUNT + QSTATE_COUNT)
#define NODE_BEGIN       (TIME_COUNT + QSTATE_COUNT + USTATE_COUNT)
#define TAILSTATE_BEGIN  (TIME_COUNT + QSTATE_COUNT + USTATE_COUNT + NODE_COUNT)
#define RECORD_BEGIN     (TIME_COUNT + QSTATE_COUNT + USTATE_COUNT + NODE_COUNT + TAILSTATE_COUNT)
#define Q_BEGIN(n)       (QSTATE_BEGIN + (n - 1))
#define U_BEGIN(n)       (USTATE_BEGIN + (n - 1))

// constants info
#define GENE_COUNT       105
#define CTRNN_COUNT      105 // ctrnn parameter count
#define TARGET_COUNT     2
#define POINTS_COUNT     12
#define PHYS_COUNT       21 
#define PERIOD_COUNT     11

#define CONSTANTS_COUNT  (CTRNN_COUNT + TARGET_COUNT + POINTS_COUNT + PHYS_COUNT + PERIOD_COUNT)
#define TARGET_BEGIN     (CTRNN_COUNT)
#define POINTS_BEGIN     (CTRNN_COUNT + TARGET_COUNT)
#define PHYS_BEGIN       (CTRNN_COUNT + TARGET_COUNT + POINTS_COUNT)
#define PERIOD_BEGIN     (CTRNN_COUNT + TARGET_COUNT + POINTS_COUNT + PHYS_COUNT)

int sim_init();

int sim_uninit();

int experiment_phase_count(const char *expName, int *phase_count);

int experiment_points(const char *expName, double timeMax, 
                      int phase, double *pointsResult);

void experiment_init_state(double *points, double *t0, double *f0);

int run_simulation(double *stateArg, double stepSize, double *constantsArg, 
                   double timeArg, double *stateResult, 
                   int (*continue_loop)(void));

void lobotomise_brains(double *constants);

int physics_constants(double *physcons);

int gene_to_ctrnn(double *constants, double *result);

int period_constants(double *period_constants_result);
