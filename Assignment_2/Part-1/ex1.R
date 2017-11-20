install.packages("plotly")
install.packages("devtools")
devtools::install_github("ropensci/plotly")
install.packages("OIsurv")

library(plotly)
packageVersion('plotly')
library(OIsurv)
library(devtools)
library(plotly)
library(IRdisplay)
py <- plotly("shanice", "X1wKJOzL8E83Z9ct4NmF")
plotly:::verify("username")
data(tongue)
summary(tongue)
print(mean(tongue$time))
attach(tongue)
tongue.surv <- Surv(time[type==1], delta[type==1])
tongue.surv
surv.fit <- survfit(tongue.surv~1)
surv.fit
summary(surv.fit)
plot(surv.fit, main='Kaplan-Meier estimate with 95% confidence bounds',
     xlab='time', ylab='survival function')



ggsurv <- function(s, CI = 'def', plot.cens = T, surv.col = 'gg.def',
                   cens.col = 'red', lty.est = 1, lty.ci = 2,
                   cens.shape = 3, back.white = F, xlab = 'Time',
                   ylab = 'Survival', main = ''){
  
  library(ggplot2)
  strata <- ifelse(is.null(s$strata) ==T, 1, length(s$strata))
  stopifnot(length(surv.col) == 1 | length(surv.col) == strata)
  stopifnot(length(lty.est) == 1 | length(lty.est) == strata)
  
  ggsurv.s <- function(s, CI = 'def', plot.cens = T, surv.col = 'gg.def',
                       cens.col = 'red', lty.est = 1, lty.ci = 2,
                       cens.shape = 3, back.white = F, xlab = 'Time',
                       ylab = 'Survival', main = ''){
    
    dat <- data.frame(time = c(0, s$time),
                      surv = c(1, s$surv),
                      up = c(1, s$upper),
                      low = c(1, s$lower),
                      cens = c(0, s$n.censor))
    dat.cens <- subset(dat, cens != 0)
    
    col <- ifelse(surv.col == 'gg.def', 'black', surv.col)
    
    pl <- ggplot(dat, aes(x = time, y = surv)) +
      xlab(xlab) + ylab(ylab) + ggtitle(main) +
      geom_step(col = col, lty = lty.est)
    
    pl <- if(CI == T | CI == 'def') {
      pl + geom_step(aes(y = up), color = col, lty = lty.ci) +
        geom_step(aes(y = low), color = col, lty = lty.ci)
    } else (pl)
    
    pl <- if(plot.cens == T & length(dat.cens) > 0){
      pl + geom_point(data = dat.cens, aes(y = surv), shape = cens.shape,
                      col = cens.col)
    } else if (plot.cens == T & length(dat.cens) == 0){
      stop ('There are no censored observations')
    } else(pl)
    
    pl <- if(back.white == T) {pl + theme_bw()
    } else (pl)
    pl
  }
  
  ggsurv.m <- function(s, CI = 'def', plot.cens = T, surv.col = 'gg.def',
                       cens.col = 'red', lty.est = 1, lty.ci = 2,
                       cens.shape = 3, back.white = F, xlab = 'Time',
                       ylab = 'Survival', main = '') {
    n <- s$strata
    
    groups <- factor(unlist(strsplit(names
                                     (s$strata), '='))[seq(2, 2*strata, by = 2)])
    gr.name <-  unlist(strsplit(names(s$strata), '='))[1]
    gr.df <- vector('list', strata)
    ind <- vector('list', strata)
    n.ind <- c(0,n); n.ind <- cumsum(n.ind)
    for(i in 1:strata) ind[[i]] <- (n.ind[i]+1):n.ind[i+1]
    
    for(i in 1:strata){
      gr.df[[i]] <- data.frame(
        time = c(0, s$time[ ind[[i]] ]),
        surv = c(1, s$surv[ ind[[i]] ]),
        up = c(1, s$upper[ ind[[i]] ]),
        low = c(1, s$lower[ ind[[i]] ]),
        cens = c(0, s$n.censor[ ind[[i]] ]),
        group = rep(groups[i], n[i] + 1))
    }
    
    dat <- do.call(rbind, gr.df)
    dat.cens <- subset(dat, cens != 0)
    
    pl <- ggplot(dat, aes(x = time, y = surv, group = group)) +
      xlab(xlab) + ylab(ylab) + ggtitle(main) +
      geom_step(aes(col = group, lty = group))
    
    col <- if(length(surv.col == 1)){
      scale_colour_manual(name = gr.name, values = rep(surv.col, strata))
    } else{
      scale_colour_manual(name = gr.name, values = surv.col)
    }
    
    pl <- if(surv.col[1] != 'gg.def'){
      pl + col
    } else {pl + scale_colour_discrete(name = gr.name)}
    
    line <- if(length(lty.est) == 1){
      scale_linetype_manual(name = gr.name, values = rep(lty.est, strata))
    } else {scale_linetype_manual(name = gr.name, values = lty.est)}
    
    pl <- pl + line
    
    pl <- if(CI == T) {
      if(length(surv.col) > 1 && length(lty.est) > 1){
        stop('Either surv.col or lty.est should be of length 1 in order
             to plot 95% CI with multiple strata')
      }else if((length(surv.col) > 1 | surv.col == 'gg.def')[1]){
        pl + geom_step(aes(y = up, color = group), lty = lty.ci) +
          geom_step(aes(y = low, color = group), lty = lty.ci)
      } else{pl +  geom_step(aes(y = up, lty = group), col = surv.col) +
          geom_step(aes(y = low,lty = group), col = surv.col)}
    } else {pl}
    
    pl <- if(plot.cens == T & length(dat.cens) > 0){
      pl + geom_point(data = dat.cens, aes(y = surv), shape = cens.shape,
                      col = cens.col)
    } else if (plot.cens == T & length(dat.cens) == 0){
      stop ('There are no censored observations')
    } else(pl)
    
    pl <- if(back.white == T) {pl + theme_bw()
    } else (pl)
    pl
  }
  pl <- if(strata == 1) {ggsurv.s(s, CI , plot.cens, surv.col ,
                                  cens.col, lty.est, lty.ci,
                                  cens.shape, back.white, xlab,
                                  ylab, main)
  } else {ggsurv.m(s, CI, plot.cens, surv.col ,
                   cens.col, lty.est, lty.ci,
                   cens.shape, back.white, xlab,
                   ylab, main)}
  pl
}

p <- ggsurv(surv.fit) + theme_bw()
p
chart_link = api_create(p,filename="Kaplan-Meier Estimate")
chart_link


plot.ly <- function(url) {
  # Set width and height from options or default square
  w <- "750"
  h <- "600"
  html <- paste("<center><iframe height=\"", h, "\" id=\"igraph\" scrolling=\"no\" seamless=\"seamless\"\n\t\t\t\tsrc=\"", 
                url, "\" width=\"", w, "\" frameBorder=\"0\"></iframe></center>", sep="")
  return(html)
}

p <- plot.ly("https://plot.ly/~Shanice/9/")

surv.fit2 <- survfit( Surv(time, delta) ~ type)
p <- ggsurv(surv.fit2) + 
  ggtitle('Lifespans of different tumor DNA profile') + theme_bw()
p
chart_link1 = api_create(p,filename="lifespans-of-different")
chart_link1

p <- plot.ly("https://plot.ly/~Shanice/5")


survdiff(Surv(time, delta) ~ type)
haz <- Surv(time[type==1], delta[type==1])
haz.fit  <- summary(survfit(haz ~ 1), type='fh')

x <- c(haz.fit$time, 250)
y <- c(-log(haz.fit$surv), 1.474)
cum.haz <- data.frame(time=x, cumulative.hazard=y)

p <- ggplot(cum.haz, aes(time, cumulative.hazard)) + geom_step() + theme_bw() + 
  ggtitle('Nelson-Aalen Estimate')
p
chart_link2 = api_create(p,filename="Nelson-Aalen Estimate")
chart_link2

p <- plot.ly("https://plot.ly/~Shanice/7")



##select my data
data(hodg)
summary(hodg)
print(mean(hodg$time))
attach(hodg)
hodg.surv <- Surv(time[dtype==2], delta[dtype==2])
hodg.surv
surv.fit <- survfit(hodg.surv~1)
surv.fit
summary(surv.fit)
plot(surv.fit, main='hodg', xlab='time', ylab='survival function')

p <- ggsurv(surv.fit) +
  ggtitle('Hodgkins disease with time') + theme_bw()

chart_link3 = api_create(p,filename="Hodgkins disease with time")
chart_link3
p <- plot.ly("https://plot.ly/~Shanice/11")
