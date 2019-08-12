#include <Rcpp.h>
using namespace Rcpp;

// [[Rcpp::export]]
NumericVector distances_among_pairs_cpp(NumericVector v) {
    int nin = v.size();
    int nout = (nin * nin - nin) / 2; //length of the output vector
    NumericVector dists(nout); //preallocating output vector
    for (int i=0,k=0;i<nin-1;i++) {
        double a = v[i];
        for (int j=i+1;j<nin;j++,k++) {
            double b = v[j];
            dists[k] = abs(a-b);
        }
    }
    return dists;
}