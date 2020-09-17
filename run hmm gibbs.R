rm(list=ls(all=TRUE))
library('Rcpp')
set.seed(3)

#import data
setwd('U:\\GIT_models\\hmm_armadillo')
sourceCpp('hmm_rcpp.cpp')
source('gibbs hmm aux functions.R')
source('gibbs hmm main function.R')
dat=read.csv('fake data.csv',as.is=T)
nobs=nrow(dat)

#priors
var.mu=1000

#prior for precision (if sig2.a=sig2.b=0.1, then this generates very high sig2 in the absence of data = very hard to propose new groups)
sig2.a=sig2.b=0.1

#initialize parameters
max.group=15

# breaks1=seq(from=min(dat$log.SL),to=max(dat$log.SL),length.out=max.group*5)
# hist(dat$log.SL,breaks=breaks1,main=max.group)

#MCMC stuff
ngibbs=3000
nburn=ngibbs/2

mod=hmm.main.function(dat=dat,var.mu=var.mu,sig2.a=sig2.a,sig2.b=sig2.b,
                      max.group=max.group,ngibbs=ngibbs,nburn=nburn)
