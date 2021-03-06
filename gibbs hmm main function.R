hmm.main.function=function(dat,var.mu,sig2.a,sig2.b,max.group,ngibbs,nburn){
  nobs=nrow(dat)  
  
  #initialize parameters
  mu.sk=mu.ak=rep(0,max.group)
  sig2.ak=sig2.sk=rep(100,max.group)
  z.k=sample(1:max.group,size=nobs,replace=T)
  theta=rep(1/max.group,max.group)
  n.k=get.nk(z.k=z.k,max.group=max.group)
  gamma.possib=seq(from=0.1,to=1,by=0.05) #possible gamma values
  gamma1=gamma.possib[length(gamma.possib)]
  
  #MCMC stuff
  store.mu.ak=store.mu.sk=store.sig2.ak=store.sig2.sk=
    store.theta=matrix(NA,ngibbs,max.group)
  store.llk=matrix(NA,ngibbs,1)
  store.gamma=matrix(NA,ngibbs,1)
  max.llk=-Inf
  
  for (i in 1:ngibbs){
    print(i)
    mu.ak=sample.mu.ak(TA=dat$logit.TA,sig2.ak=sig2.ak,n.k=n.k,
                       z.k=z.k,max.group=max.group,var.mu=var.mu)
    mu.sk=sample.mu.sk(SL=dat$log.SL,sig2.sk=sig2.sk,n.k=n.k,
                       z.k=z.k,max.group=max.group,var.mu=var.mu)
    sig2.ak=sample.sig2.ak(TA=dat$logit.TA,n.k=n.k,sig2.a=sig2.a,sig2.b=sig2.b,
                           mu.ak=mu.ak,max.group=max.group,z.k=z.k)
    sig2.sk=sample.sig2.sk(SL=dat$log.SL,n.k=n.k,sig2.a=sig2.a,sig2.b=sig2.b,
                           mu.sk=mu.sk,max.group=max.group,z.k=z.k)
    z.k=sample.z(TA=dat$logit.TA,SL=dat$log.SL,ltheta=log(theta),
                 mu.ak=mu.ak,mu.sk=mu.sk,sig2.ak=sig2.ak,sig2.sk=sig2.sk,
                 z.k=z.k,max.group=max.group,nobs=nobs,var.mu=var.mu)
    n.k=get.nk(z.k=z.k,max.group=max.group)
    tmp=sample.theta(n.k=n.k,gamma1=gamma1,max.group=max.group)
    theta=tmp$theta
    v.k=tmp$v.k
    gamma1=sample.gamma(v=v.k,ngroups=max.group,gamma.possib=gamma.possib)
    
    #re-order stuff from time to time
    if (i%%50==0 & i<nburn){
      ind=order(theta,decreasing=T)
      theta=theta[ind]
      mu.ak=mu.ak[ind]
      mu.sk=mu.sk[ind]
      sig2.sk=sig2.sk[ind]
      sig2.ak=sig2.ak[ind]
      ztmp=z.k
      for (jj in 1:max.group){
        cond=z.k==ind[jj]
        ztmp[cond]=jj
      }
      z.k=ztmp
      n.k=get.nk(z.k=z.k,max.group=max.group)
    }
    
    #get log.likel
    llk=calc.llk(TA=dat$logit.TA,SL=dat$log.SL,z.k=z.k,
                 mu.sk=mu.sk,mu.ak=mu.ak,sig2.ak=sig2.ak,
                 sig2.sk=sig2.sk,max.group=max.group)
    
    #store results
    store.mu.ak[i,]=mu.ak
    store.mu.sk[i,]=mu.sk
    store.sig2.ak[i,]=sig2.ak
    store.sig2.sk[i,]=sig2.sk
    store.theta[i,]=theta
    store.llk[i]=sum(llk)
    store.gamma[i]=gamma1
    
    #get MAP for z.k
    if (i>nburn & max.llk<store.llk[i]){
      max.llk=store.llk[i]
      store.z=z.k
    }
  }  
  list(mu.ak=store.mu.ak,mu.sk=store.mu.sk,
       sig2.ak=store.sig2.ak,sig2.sk=store.sig2.sk,
       theta=store.theta,llk=store.llk,max.llk=max.llk,z.k=store.z,
       gamma1=store.gamma)
}
