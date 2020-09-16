
# Project: Mutifunctionality workshop (Lund 2019)

# Title: Multispecies Lotka-Volterra model from Stachova and Leps (2010)

# load relevant libraries
library(dplyr)
library(gtools)
library(tidyr)
library(truncnorm)

# create customised plotting theme
theme_meta <- function(base_size = 12, base_family = "") {
  theme(panel.background =  element_rect(fill = "white"), 
        panel.border =      element_rect(fill="NA", color="black", size=0.75, linetype="solid"),
        axis.line.x = element_line(color="black", size = 0.2),
        axis.line.y = element_line(color="black", size = 0.2),
        panel.grid.major =  element_blank(),
        panel.grid.minor =  element_blank(),
        axis.ticks.length = unit(-0.16, "cm"),
        axis.title.x = element_text(colour ="black", size = 12, face = "plain", margin=margin(5,0,0,0,"pt")),
        axis.title.y = element_text(colour = "black", size = 12, face = "plain", margin=margin(0,5,0,0,"pt")),
        axis.text.x = element_text(colour = "black", size=12, face = "plain",  margin=margin(10,0,0,0,"pt")),
        axis.text.y = element_text(colour ="black", size=12, face = "plain", margin=margin(0,10,0,0,"pt")),
        axis.ticks.x = element_line(colour = "black", size = 0.4),
        axis.ticks.y = element_line(colour = "black", size = 0.4))
}


### code the Stachova and Leps (2010) simulation model (function = s_l_2010_mod)

# explanation of the default values for the model parameters

# number of species in the regional species pool
reg_pool = 100 

# number of time-steps
t_steps = 20

# starting population size of each species
n0 = 3

# parameters of the truncated normal distribution used for generating the competition coeffficients (alpha)
a_mean = 1
a_sd = 0.2
a_min = 0.2
a_max = 1.2

# set the alpha value for the effect of each species on itself
a_spp = 1

# parameters of the uniform distribution used for generating the carrying capacities (K)
k_min = 3
k_max = 150

# parameters of the uniform distribution used for generating the intrinsic growth rates (r)
r_min = 0.01
r_max = 0.5

# set up a vector of local species pools (or species richness treatments)
local_species_pools = c(10, 20, 30, 40, 50, 60)

# set the number of replicates of each local species pool
reps = 10


s_l_2010_mod <- function(reg_pool = 100,
                         t_steps = 20, 
                         n0 = 3,
                         a_mean = 1, a_sd = 0.2, a_min = 0.2, a_max = 1.2, a_spp = 1,
                         k_min = 3, k_max = 150,
                         r_min = 0.01, r_max = 0.5, 
                         lsp = c(10, 20, 30, 40, 50, 60),
                         reps = 10) {
  
  # set up the permutations between species for the competition coefficients
  al <- as.data.frame(gtools::permutations(n = reg_pool, r = 2, v = c(1:reg_pool), repeats.allowed = TRUE))
  names(al) <- c("j", "i")
  
  # add alpha values generated from a truncated normal distribution for each species pair
  al$alpha_vals <- truncnorm::rtruncnorm(n = nrow(al), a = a_min, b = a_max, mean = a_mean, sd = a_sd)
  
  # set the alpha value for the effect of each species on itself to one
  al <- dplyr::mutate(al, alpha_vals = dplyr::if_else(j == i, a_spp, alpha_vals))
  
  # generate the carrying capacities (K) for each species from the uniform distribution
  k <- runif(n = reg_pool, min = k_min, max = k_max)
  
  # generate growth rates values (r) for each species from the uniform distribution
  r <- runif(n = reg_pool, min = r_min, max = r_max)
  
  
  # for each replicate (u)
  run_out <- vector("list", length = reps)
  
  for (u in seq(from = 1, to = reps, by = 1)) {
    
    # for each local species pool (or species richness treatment), (s)
    lsp_out <- vector("list", length = length(lsp))
    
    for (s in seq(from = 1, to = length(lsp), by = 1) ) {
      
      # sample lsp[s] species from the regional species pool
      sp_sub <- sample(x = c(1:reg_pool), size = lsp[s], replace = FALSE)
      
      # get the competition coefficients for this set of species
      a_sub <- al[al$j %in% sp_sub, ]
      
      # get the carrying capacities for this set of species
      k_sub <- k[sp_sub]
      
      # get the growth rates for this set of species
      r_sub <- r[sp_sub]
      
      
      # code a nested for loop: for each time and for each species
      
      # create a vector of starting values for each species
      n_vals <- rep(n0, times = lsp[s])
      
      # create an output list of species abundances for each time point
      n_t <- vector("list", length = t_steps)
      n_t
      
      # fill the first time point with starting abundances
      n_t[[1]] <- n_vals
      
      # for each time point m
      for(m in seq(from = 2, to = t_steps, by = 1)){
        
        # for each species g
        for (g in seq(from = 1, to = length(sp_sub), by = 1)) {
          
          # first term in the equation
          t1 <- n_t[[m-1]][g] 
          
          # second term in the equation
          t2 <- (r_sub[g]*n_t[[m-1]][g])
          
          # subset out competition coefficients relevant to species k
          z <- a_sub[(!(a_sub$j %in% sp_sub[g]) & a_sub$i == sp_sub[g]) | a_sub$i == sp_sub[g], ]
          
          # multiply effect of species j on species k by population size of species j and sum
          y <- sum( (z$alpha_vals*n_t[[m-1]][match(x = z$j, table = sp_sub)]) )
          
          # third term in the equation
          t3 <- 1 - (y/k_sub[g])
          
          # use three terms in the full equation
          n_t[[m]][g] <- t1 + (t2*t3)
          
          # if a species abundance drops below 0.2 it is considered extinct
          if (n_t[[m]][g] < 0.2) { n_t[[m]][g] <- 0 }
          
        }
        
      }
      
      # collapse this into a dataframe
      df_n_t <- as.data.frame(do.call(rbind, n_t))
      names(df_n_t) <- paste("sp_", 1:lsp[s])
      
      # add a column for the time-point
      df_n_t$time <- seq(from = 1, to = t_steps, by = 1)
      
      # pull this into two columns
      df_n_t <- 
        df_n_t %>%
        tidyr::pivot_longer(cols = starts_with(match = "sp_"),
                            names_to = "species",
                            values_to = "abundance") %>%
        dplyr::arrange(time, species)
      
      # summarise these data
      n_t_sum <- 
        df_n_t %>%
        dplyr::group_by(time) %>%
        dplyr::summarise(realised_richness = sum(dplyr::if_else(abundance > 0, 1, 0)),
                         community_biomass = sum(abundance), .groups = "drop") %>%
        dplyr::mutate(species_pool = lsp[s])
      
      lsp_out[[s]] <- n_t_sum
      
    }
    
    run_out[[u]] <- bind_rows(lsp_out)
    
  }
  
  bind_rows(run_out, .id = "replicate")
  
}


# test this function

s_l_2010_mod(reg_pool = 100,
             t_steps = 10, 
             n0 = 3,
             a_mean = 1, a_sd = 0.2, a_min = 0.2, a_max = 1.2, a_spp = 1,
             k_min = 3, k_max = 150,
             r_min = 0.01, r_max = 0.5, 
             lsp = c(10, 20, 30, 40, 50, 60),
             reps = 10)



