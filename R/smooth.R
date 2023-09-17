estimate_period <- function(noise_data, n_points = 1000) {
  
  if(nrow(noise_data) < n_points) {
    n_points <- nrow(timestaps)
  }
  
  timestamps <- 
    noise_data %>% 
    slice(1:n_points) %>% 
    pull(exp_time_after_pause)
  
  diffs <- numeric(length = length(timestamps)-1)
  
  for(i in 1:length(diffs)) {
    diffs[i] <- timestamps[i+1] - timestamps[i]
  }
  
  return(median(diffs, na.rm = T))
}

smooth_noise <- function(noise_data, nsec = 15, ...) {
  
  period <- estimate_period(noise_data)
    
  noise_data$smoothed_sound_db <- 
    noise_data %>% 
    pull(sound_pressure_level_d_b) %>% 
    runmed(k = ceiling(nsec/period))
  
  return(noise_data)
}
