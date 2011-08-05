#ifndef _GENES_REAL_H_
#define _GENES_REAL_H_

#include <fstream>
#include <string>
using namespace std;

#include "alps/alps.h"
#include "alps/gen.h"
#include "alps/layer.h"
#include "alps/individ_real.h"
using namespace alps;

// ***********************************************************************
class Genes_Real : public Individ_Real  {
public:
    Genes_Real(int n = 0);
    Genes_Real(const Genes_Real& old);
    Genes_Real(const Individual* old);
    virtual ~Genes_Real();
    bool operator==(Genes_Real& old);
    void make_random() { Individ_Real::make_random(); };
    bool mutate();
    bool mutate(double scale);
    istream& read(istream &f) { return Individ_Real::read(f); };
    ostream& write(ostream &f) { return Individ_Real::write(f); };

    double mutate_prob;

private:
    void my_init();
};


#endif /* _GENES_REAL_H_ */
