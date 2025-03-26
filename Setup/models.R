### Setup ######################################################################

  source("Setup/parameters.R")

### Empty list for models ######################################################

  models <- list()


### Fully Markovian [DGP 1] ####################################################

  models[[length(models)+1]] <-   list(time_steps = 0:5,
                                       transient  = c("A","B"),
                                       absorbing  = "X",
                                       probs      = list(A=c(A=even2,B=even2,X=death),
                                                         B=c(A=even2,B=even2,X=death)),
                                       gen_duration=F,
                                       gen_age = F,
                                       sample_size=100,
                                       replications=replications,
                                       initial_distr=c(0.5,0.5))


### Moderate violation (switch 1) [DGP 3b] #####################################

  models[[length(models)+1]] <- list(time_steps = 0:5,
                                     transient  = c("A","B"),
                                     absorbing  = "X",
                                     probs      = list(A=c(A=even2,B=even2,X=death),
                                                       B=c(A=even2,B=even2,X=death)),
                                     gen_age = F,
                                     gen_duration = T,
                                     which_duration = c("A","B"),
                                     diff_duration = list(A=c(A=diff1,B=-diff1,X=0),
                                                          B=c(A=-diff1,B=diff1,X=0)),
                                     interpolation_duration = list(A="switch1",B="switch1"),
                                     sample_size=100,
                                     replications=replications,
                                     initial_distr=c(0.5,0.5))


### Additional sample sizes ####################################################

  # Additional sizes
  models_1000 <- models
  models_2500 <- models

  # Change sizes
  for(i in 1:length(models_1000)) models_1000[[i]]$sample_size <- 1000
  for(i in 1:length(models_2500)) models_2500[[i]]$sample_size <- 2500

  # Add
  models <- c(models,models_1000,models_2500)
