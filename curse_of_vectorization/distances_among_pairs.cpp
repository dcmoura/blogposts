/*
 * Copyright (c) 2019 Daniel Moura
 * https://towardsdatascience.com/freeing-the-data-scientist-mind-from-the-curse-of-vectorization-11634c370107?source=friends_link&sk=e7b0086f3678261cb64b6dbb43744613
 * linkedin.com/in/dmoura
 * twitter.com/daniel_c_moura
 */

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