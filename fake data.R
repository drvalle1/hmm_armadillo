rm(list=ls(all=TRUE))
set.seed(1)

#parameters
nobs=10000
ngroup=10
seq1=-2+cumsum(rep(0.5,ngroup));  
mu.SL.true=mu.SL=sample(seq1,size=ngroup)
mu.TA.true=mu.TA=sample(seq1,size=ngroup)
sd.TA=sd.SL=rep(diff(seq1)[1]/6,ngroup)
sd.TA.true=sd.TA
sd.SL.true=sd.SL

#get group assignments
tmp=rmultinom(nobs,size=1,prob=rep(1/ngroup,ngroup))
ind=rep(NA,nobs)
for (i in 1:nobs){
  ind[i]=which(tmp[,i]==1)
}

#get SL
fim=data.frame(log.SL=rep(NA,nobs),
               logit.TA=rep(NA,nobs))
fim$log.SL=rnorm(nobs,mean=mu.SL[ind],sd=sd.SL[ind])

#look at SL
par(mfrow=c(5,2),mar=rep(1,4))
rango=range(exp(fim$log.SL))
for (i in 1:ngroup) hist(exp(fim$log.SL[ind==i]),xlim=rango)

#get TA
fim$logit.TA=rnorm(nobs,mean=mu.TA[ind],sd=sd.TA[ind])

#look at TA
tmp=exp(fim$logit.TA)
prob=tmp/(1+tmp)
par(mfrow=c(5,2),mar=rep(1,4))
rango=c(0,1)
for (i in 1:ngroup) hist(prob[ind==i],xlim=rango)

#plug in NA's in TA
# ind=rbinom(nobs,size=1,prob=0.002); sum(ind==1)
# fim[ind==1,2]=NA

#export results
setwd('U:\\GIT_models\\hmm_armadillo')
write.csv(fim,'fake data.csv',row.names=F)