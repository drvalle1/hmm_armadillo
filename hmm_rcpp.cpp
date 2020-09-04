#include <Rcpp.h>
#include <iostream>
#include <ctime>
#include <fstream>
using namespace Rcpp;

/***************************************************************************************************************************/
/*********************************                      UTILS          *****************************************************/
/***************************************************************************************************************************/

// This function helps with multinomial draws
// [[Rcpp::export]]
int whichLessDVPresence(double value, NumericVector prob) {
  int res=prob.length()-1;
  double probcum = 0;
  
  for (int i = 0; i < prob.length(); i++) {
    probcum = probcum + prob(i);
    if (value < probcum) {
      res = i;
      break;
    }
  }
  return res;
}

// [[Rcpp::export]]
IntegerVector SampleZ(NumericMatrix lprob, int nobs, IntegerVector zk,
                      int MaxGroup, NumericVector RandUnif,
                      NumericMatrix LogNewGr) {
  int ind;
  int MaxCurrent;
  // NumericVector denis(MaxGroup+1);
  NumericVector lprob1(MaxGroup+1);  
  
  for(int i=0; i<nobs; i++){ //loop over all observations
    lprob1=lprob(i,_);

    MaxCurrent=max(zk); //max index
    if (MaxCurrent<MaxGroup){
      ind=MaxCurrent+1;
      lprob1[ind]=LogNewGr(i,ind);
      if (ind<MaxGroup){
        for (int j=(ind+1); j<(MaxGroup+1); j++){
          lprob1[j]=-INFINITY;
        }
      }
    }

    // if (i==0){
    //   denis=clone(lprob1);
    // }
    
    lprob1=lprob1-max(lprob1);
    lprob1=exp(lprob1);
    lprob1=lprob1/sum(lprob1);
    
    zk[i]=whichLessDVPresence(RandUnif[i], lprob1);
  }
  
  return (zk);
}