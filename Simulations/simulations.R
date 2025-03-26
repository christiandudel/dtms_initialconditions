### Packages ###################################################################

  # Packages
  library(dtms)
  library(VGAM)

  # Models and functions
  source("Functions/functions_simulation.R")
  source("Setup/models.R")
  source("Setup/parameters.R")


### Object for results #########################################################

  results <- list()


### Loop over models ###########################################################

  # Number of simulation models
  n_sims <- length(models)

  # Loop
  for(sim in 1:n_sims) {

    # Output
    cat("\n","Model ",sim,"\n")

    # Complete sim
    gensim <- complete_sim(models[[sim]])

    # Generate expanded transition probabilities
    simmodel <- generate_sim(gensim)

    # For transition matrix: add duration to states
    if(gensim$gen_duration) {
      transient_states <- levels(interaction(gensim$which_duration,1:(max(gensim$time_steps)+1),sep=""))
      transient_states <- c(transient_states,gensim$transient[!gensim$transient%in%gensim$which_duration])
    } else transient_states <- gensim$transient

    # General model
    general <- dtms(transient=transient_states,
                    absorbing=gensim$absorbing,
                    timescale=gensim$time_steps)

    # Transition matrix
    Tm <- dtms_matrix(probs=simmodel,
                      dtms=general)

    # Settings
    replications <- gensim$replications
    sample_size <- gensim$sample_size
    nlength <- length(gensim$time_steps)

    # For results
    results_initial <- list()
    results_transition <- list()
    results_combined <- list()

    # Loop over replications
    for(rep_nr in 1:replications) {

      # Output
      cat(".")

      # Starting distribution
      values <- gensim$initial_distr
      if(gensim$gen_duration) {
        starting_distr <- numeric(length(transient_states))
        starting_distr[1:length(values)] <- values
      }  else starting_distr <- values


      # Simulate data
      tmpdata <- dtms_simulate(matrix=Tm,
                               dtms=general,
                               size=sample_size,
                               start_distr=starting_distr,
                               droplast=T)

      # Simplify
      tmpdata <- simplifydata(tmpdata)

      # Add IDs
      tmpdata$id <- 1:sample_size

      # Reshape
      tmpdata <- tmpdata %>% pivot_longer(cols=starts_with("T_"),
                                            names_prefix="T_",
                                            names_to="time",
                                            values_to="state")

      class(tmpdata$time) <- "numeric"

      # Simulation dtms
      simdtms <- dtms(transient = gensim$transient,
                      timescale = gensim$time_steps,
                      absorbing = gensim$absorbing)

      # Transition format
      simdata <- dtms_format(data=tmpdata,
                             dtms=simdtms,
                             verbose=F)

      # Cleaning
      simdata <- dtms_clean(data    = simdata,
                            dtms    = simdtms,
                            verbose = F)

      # Starting distribution
      starting_distr <- dtms_start(dtms = simdtms,
                                   data = simdata)

      # Estimate model
      fit <- dtms_fullfit(data = simdata,
                          controls =timecontrol)

      # Predict probabilities for transition matrix
      model1_p <- dtms_transitions(model    = fit,
                                   dtms     = simdtms,
                                   controls = list(time=simdtms$timescale),
                                   se=F)

      # Place in result lists
      results_initial[[rep_nr]] <- starting_distr
      results_transition[[rep_nr]] <- model1_p
      results_combined[[rep_nr]] <- c(starting_distr,model1_p$P)

    }

    results[[sim]] <- list(results_combined=results_combined)

  } # End of model loop


### Save results ###############################################################

  filename <- paste0("Results/dtms_initial.Rda")
  save(list=c("models","results"),
       file=filename)

  ### Clear memory
  rm(list=ls())
  gc()
