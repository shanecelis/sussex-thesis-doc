/* alps_frog.h */
#ifndef _ALPS_FROG_H_
#define _ALPS_FROG_H_

int ea_engine(const char *exp_name, int target_index, bool lotobotomise, 
              const char *pop_save, int fitness_type);

bool evaluate_frog(vector<double>& fitness, vector<double>& genes, //Individual* individ, 
                   const char *expName, int phase, int target_index, bool lobotomise, int fitness_type);

void register_signal_handlers();
extern "C" void signal_func(int sig);
#endif /* _ALPS_FROG_H_ */
