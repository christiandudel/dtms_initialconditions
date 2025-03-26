load("Results/dtms_initial.Rda")
source("Setup/parameters.R")

# Correlations of initial proportions and transition probabilities
correlationmatrices <- lapply(results, function(x) {
      tmp <- unlist(x)
      tmp <- matrix(data=tmp,ncol=replications)
      tmp <- t(tmp)
      tmp <- cor(tmp)
      return(tmp)
    }
  )

# Average correlation of first initial proportion with transition probabilities
summaryresults <- lapply(correlationmatrices, function(x) {
    tmp <- x[1,c(-1,-2)]
    tmp <- mean(tmp)
    return(tmp)
  }
)
