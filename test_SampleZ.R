set.seed(1)
RandUnif=runif(nobs)

z.k.orig=z.k=sample(1:max.group,size=nobs,replace=T)

for (i in 1:nobs){
  max.current=max(z.k)
  # print(max.current)
  lprob1=lprob[i,1:max.current]
  if (max.current<max.group){
    ind=max.current+1
    tmp=LogNewGr[i,ind]
    lprob1=c(lprob1,tmp)
  }
  lprob1=lprob1-max(lprob1)
  prob=exp(lprob1)
  prob=prob/sum(prob)
  ind=whichLessDVPresence(RandUnif[i], prob=prob)
  z.k[i]=ind
}

fim=data.frame(cpp=z.k,r=z.k.orig)
table(fim)
#-------------------------------------------------------
cpp1=SampleZ(lprob=lprob,nobs=nobs,zk=z.k.orig-1,MaxGroup=max.group-1,RandUnif=RandUnif,
             LogNewGr=LogNewGr)  
cpp1
#---------------
#compare

fim=data.frame(cpp=cpp1,r=z.k.orig)
table(fim)

fim=data.frame(cpp=cpp1,r=z.k)
table(fim)

