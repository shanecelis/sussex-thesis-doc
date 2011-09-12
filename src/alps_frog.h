/* alps_frog.h */
#ifndef _ALPS_FROG_H_
#define _ALPS_FROG_H_

#define       STANDARD_RUN  0
#define       DEBUG_RUN     1

#define       FITNESS_MEAN_DISTANCE    0
#define       FITNESS_MEAN_SPEED       1
#define       FITNESS_MEAN_LIGHTSENSOR 2

#ifdef __cplusplus
extern "C" {
#endif
int ea_engine(const char *exp_name, int task_index, int lotobotomise, 
              const char *pop_save, int fitness_type, int run_type);

int evaluate_frog(double* fitness, double* genes, 
                  const char *expName, int phase, int task_index, 
                  int lobotomise, int fitness_type);

char *save_genes_for_phase(double *genes, const char *pop_save_prefix, 
                           int phase);

void register_signal_handlers();
int read_array(const char *filename, int *n, double *array);
int write_array(const char *filename, int n, double *array);
void signal_func(int sig);
#ifdef __cplusplus
}
#endif
#endif /* _ALPS_FROG_H_ */
