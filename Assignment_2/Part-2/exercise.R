mm <- matrix(1:16,nrow=4,ncol=4)
mm

##exercise
mm[c(3,4),c(1,2)]

college <- read.csv("../data/College.csv")
df <- college[270:299,]

##exercise
dfx <- group_by(df,Private)
dfx <- summarise(dfx, max(Outstate),min(Outstate))
dfx

##exercise
dfx <- group_by(college,Private)
dfx <- summarise(dfx,max(Outstate),min(Outstate))
dfx

##exercise
head(select(arrange(df,desc(Grad.Rate)),X,Grad.Rate), n=9L)
##or
filter(select(arrange(df,desc(Grad.Rate)),X,Grad.Rate),Grad.Rate>=80)
