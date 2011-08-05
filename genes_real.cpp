#include "genes_real.h"
#include "math.h"

#include "alps/random_mt.h"
using namespace alps_random;

Genes_Real::Genes_Real(int n) : Individ_Real(n) {
    my_init();
}

Genes_Real::Genes_Real(const Genes_Real& old) : Individ_Real(1) {
    duplicate((Individ_Real*) &old);
    my_init();
}
Genes_Real::Genes_Real(const Individual* oldy) : Individ_Real(1) {
    Genes_Real* old = (Genes_Real *) oldy;
    duplicate((Individ_Real*) old);
    my_init();
}

bool equalish(double a, double b) {
    return fabs(a - b) < 0.0001;
}

bool Genes_Real::operator==(Genes_Real& other) {
  const std::vector<double> gene_vec = get_genes();
  const std::vector<double> other_gene_vec = other.get_genes();

  return (get_num_genes() == other.get_num_genes()
          && equal(gene_vec.begin(), gene_vec.end(), other_gene_vec.begin(), equalish));
}

Genes_Real::~Genes_Real() {
}

void Genes_Real::my_init() {  
  // if (get_num_genes() == 0) {
  //   set_num_genes(8);
  // }
    set_minmax(0.0, 1.0);
    mutate_prob = 0.0;
    initialize();
}

bool Genes_Real :: mutate(double scale)
{
  return mutate();
}

bool Genes_Real :: mutate()
{
  int mutated = false;

  Individual::mutate();
  //const std::vector<double> gene_vec = get_genes();

  int n = get_num_genes();
  for (int i = 0; i < n; i++) {
    if (random_double() < mutate_prob) {
      gene_vec_[i] = random_double();

      cerr << "got mutated to " << gene_vec_[i] << endl;
    }
  }
}
