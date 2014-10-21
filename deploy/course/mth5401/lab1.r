######## Definition of conversion functions

#Define math_floor function which has expected behavior from class
math_floor <- function(x){
	x[which(floor(x)==x)]=x[which(floor(x)==x)]-1
	x=floor(x)
	return(x)
} #End math_floor
########

#Define function which converts uniform to geometric RV
unif_to_geom<- function(s,theta){
	s=(log(1-s)/log(1-theta))
	s=math_floor(s)
	return(s)
} #End unif_to_geom
########

#Define function which converts Uniform[0,1] to Uniform[a,b]
unif_to_unif_mod<-function(s,a,b){
	return(a+s*(b-a))
} #End unif_to_unif_mod
########


#Define function which converts Uniform[0,1] to Binomial[n,theta]
unif_to_binom<-function(s,n,theta){
	probs=sapply(0:n,(function(k) choose(n,k)*(theta**k)*((1-theta)**(n-k))))
#	probs=dbinom(0:n,n,theta)
#	print(max(abs(probs-dbinom(0:n,n,theta))))
#	probs=pbinom(0:n,n,theta)
	probs=cumsum(probs)
	samplespace=0:n
	s=sapply(s,(function(x) samplespace[min(which(probs>=x))]))
	return(s)
#	print(probs)
	
} #End unif_to_binom
########

#Define function which converts Uniform[0,1] to Bernoulli[theta]
unif_to_bernoulli<-function(s,theta){
	return(unif_to_binom(s,1,theta))
}

#Define function which converts Uniform[0,1] to Exponential(lambda)
unif_to_exp<-function(s,lambda){
	return(-log(s)/lambda)
} #End unif_to_exp
########

#Define function which converts two samples of Uniform[0,1] to N[0,1]
unif_to_stdnorm<-function(s1,s2=NULL){
	if(is.null(s2)){
		if(length(s1)%%2==0){
			s2=s1[(length(s1)/2):length(s1)]
			s1=s1[1:length(s1)]
		} else {
			stop()			
		}
	}
	
	return(sqrt(2*log(1/s1))*cos(2*pi*s2))
} #End unif_to_stdnorm
########

#Define function which converts two samples of Uniform[0,1] to N[mu,sd^2]
unif_to_norm<-function(s1,s2=NULL,mu,sigma){
	if(is.null(s2)){
		if(length(s1)%%2==0){
			s2=s1[(length(s1)/2):length(s1)]
			s1=s1[1:length(s1)]
		} else {
			stop()			
		}
	}
	return(sigma*unif_to_stdnorm(s1,s2)+mu)
} #End unif_to_norm

######## End function definitions

########
#Problem 2.10.10a
#Generate n samples from Uniform[0,1]
n<-1000
s_uniform<-runif(n)
# print(s_uniform)
########

########
#Problem 2.10.10b
#Convert to samples from Uniform[a,b] distribution
# a<-5
# b<-8
# s_unifo_ab<-unif_to_unif_mod(s_uniform,a,b)
########

########
#Problem 2.10.10d
#Convert to samples from Binomial(12,1/3) distribution
# s_binom<-unif_to_binom(s_uniform,12,1/3)
#Use the built-in quantile function
# s_binom_compare<-qbinom(s_uniform,12,1/3)
# print(s_binom)
# print(s_binom_compare)
# print(s_binom-s_binom_compare)
########

########
#Problem 2.10.10e
#Convert to samples from Geometric(0.2) distribution
#s_geom<-unif_to_geom(s_uniform,0.2)
#print(s_geom-qgeom(s_uniform,0.2))
########

########
#Problem 2.10.10f
#Convert to samples from Exponential(1) distribution
#s_exp<-unif_to_exp(s_uniform,1)

#Make histogram of values
#hist(s_exp,breaks=100,freq=FALSE)

#Print sample mean and variance for comparison
#print(mean(s_exp))
#print(var(s_exp))
########

########
#Problem 2.10.10d
#Convert to samples from Binomial(12,1/3) distribution
# s_binom<-unif_to_binom(s_uniform,12,1/3)
########

########
#Problem 2.10.10h
#Convert to samples from N(0,1) distribution
#s_uniform2<-runif(n)
#s_stdnorm<-unif_to_stdnorm(s_uniform,s_uniform2)
#print(mean(s_stdnorm))
#print(sd(s_stdnorm))
########

########
#Problem 2.10.10i
#Convert to samples from N(5,9) distribution
#s_uniform2<-runif(n)
#s_stdnorm<-unif_to_norm(s_uniform,s_uniform2,5,9)
#print(mean(s_stdnorm))
#print(sd(s_stdnorm))
########