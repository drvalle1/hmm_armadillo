get.nk=function(z.k,max.group){
  tmp=table(z.k)
  nk=rep(0,max.group)
  nk[as.numeric(names(tmp))]=tmp
  nk
}
sample.mu.sk=function(SL,sig2.sk,n.k,z.k,max.group,var.mu){
  prec=(n.k/sig2.sk)+(1/var.mu)
  var1=1/prec
  mu.sk=rnorm(max.group,mean=0,sd=sqrt(var.mu))
  ind=which(n.k>0)
  max.group1=max(ind)
  for (i in 1:max.group1){
    pmedia=(1/sig2.sk[i])*sum(SL[z.k==i])
    mu.sk[i]=rnorm(1,mean=var1[i]*pmedia,sd=sqrt(var1[i]))
  }
  mu.sk
}
sample.mu.ak=function(TA,sig2.ak,n.k,z.k,max.group,var.mu){
  prec=(n.k/sig2.ak)+(1/var.mu)
  var1=1/prec
  mu.ak=rnorm(max.group,mean=0,sd=sqrt(var.mu))
  ind=which(n.k>0)
  max.group1=max(ind)
  for (i in 1:max.group1){
    pmedia=(1/sig2.ak[i])*sum(TA[z.k==i])
    mu.ak[i]=rnorm(1,mean=var1[i]*pmedia,sd=sqrt(var1[i]))
  }
  mu.ak
}
sample.sig2.ak=function(n.k,sig2.a,sig2.b,TA,mu.ak,max.group,z.k){
  a1=(n.k+2*sig2.a)/2
  sig2.ak=1/rgamma(max.group,sig2.a,sig2.b)
  ind=which(n.k>0)
  max.group1=max(ind)
  for (i in 1:max.group1){
    cond=z.k==i
    err2=(TA[cond]-mu.ak[i])^2
    b1=(sum(err2)/2)+sig2.b
    sig2.ak[i]=1/rgamma(1,a1[i],b1)
  }
  sig2.ak
}
sample.sig2.sk=function(n.k,sig2.a,sig2.b,SL,mu.sk,max.group,z.k){
  a1=(n.k+2*sig2.a)/2
  sig2.sk=1/rgamma(max.group,sig2.a,sig2.b)
  ind=which(n.k>0)
  max.group1=max(ind)
  for (i in 1:max.group1){
    cond=z.k==i
    err2=(SL[cond]-mu.sk[i])^2
    b1=(sum(err2)/2)+sig2.b
    sig2.sk[i]=1/rgamma(1,a1[i],b1)
  }
  sig2.sk
}
sample.z=function(TA,SL,mu.ak,mu.sk,sig2.ak,sig2.sk,ltheta,z.k,
                  max.group,nobs,var.mu){
  sd.ak=sqrt(sig2.ak)
  sd.sk=sqrt(sig2.sk)
  
  #convert into matrices
  mu.ak.mat=matrix(mu.ak,nobs,max.group,byrow=T)
  mu.sk.mat=matrix(mu.sk,nobs,max.group,byrow=T)
  sd.ak.mat=matrix(sd.ak,nobs,max.group,byrow=T)
  sd.sk.mat=matrix(sd.sk,nobs,max.group,byrow=T)
  TA.mat=matrix(TA,nobs,max.group)
  SL.mat=matrix(SL,nobs,max.group)
  ltheta.mat=matrix(ltheta,nobs,max.group,byrow=T)
  
  #calculate lprob 
  lprob=dnorm(TA.mat,mean=mu.ak.mat,sd=sd.ak.mat,log=T)+
        dnorm(SL.mat,mean=mu.sk.mat,sd=sd.sk.mat,log=T)+ltheta.mat
  
  #calculate logNewGr
  LogNewGr=dnorm(TA.mat,mean=0,sd=sqrt((sd.ak.mat^2)+var.mu),log=T)+
           dnorm(SL.mat,mean=0,sd=sqrt((sd.sk.mat^2)+var.mu),log=T)+ltheta.mat

  tmp=SampleZ(lprob=lprob,nobs=nobs,zk=z.k-1,MaxGroup=max.group-1,RandUnif=runif(nobs),
               LogNewGr=LogNewGr)    
  tmp+1
}
sample.theta=function(n.k,gamma1,max.group){
  v.k=rep(NA,max.group-1)
  v.k[max.group]=1
  theta=rep(NA,max.group)
  tmp=1
  for (i in 1:(max.group-1)){
    a1=n.k[i]+1
    b1=sum(n.k[(i+1):max.group]+gamma1)
    v.k[i]=rbeta(1,a1,b1)
    theta[i]=v.k[i]*tmp
    tmp=tmp*(1-v.k[i])
  }
  theta[max.group]=v.k[max.group]*tmp
  list(theta=theta,v.k=v.k)
}
calc.llk=function(TA,SL,z.k,mu.sk,mu.ak,sig2.ak,sig2.sk,max.group){
  llk=rep(NA,max.group)
  for (i in 1:max.group){
    cond=z.k==i
    llk[i]=sum(dnorm(TA[cond],mean=mu.ak[i],sd=sqrt(sig2.ak[i]),log=T))+
      sum(dnorm(SL[cond],mean=mu.sk[i],sd=sqrt(sig2.sk[i]),log=T))
  } 
  llk
}
sample.gamma=function(v,ngroups,gamma.possib){
  #calculate the log probability for each possible gamma value
  soma=sum(log(1-v[-ngroups]))
  k=(ngroups-1)*(lgamma(1+gamma.possib)-lgamma(gamma.possib))
  res=k+(gamma.possib-1)*soma
  #to check code: sum(dbeta(v[-ngroups],1,gamma.possib[5],log=T))
  
  #exponentiate and normalize probabilities
  res=res-max(res)
  res1=exp(res)
  res2=res1/sum(res1)
  
  #sample from categorical distribution
  tmp=rmultinom(1,size=1,prob=res2)
  ind=which(tmp==1)
  gamma.possib[ind]
}