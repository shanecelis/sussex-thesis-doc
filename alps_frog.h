/* alps_frog.h */
#ifndef _ALPS_FROG_H_
#define _ALPS_FROG_H_

int ea_engine(const char *exp_name, int target_index, bool lotobotomise, 
              const char *pop_save);

bool evaluate_frog(vector<double>& fitness, Individual* individ, 
                   const char *expName, int phase, int target_index, bool lobotomise);
#endif /* _ALPS_FROG_H_ */
