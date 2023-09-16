read_noise <- function(folder_path) {
  
  start_time <- 
    folder_path %>% 
    here('meta', 'time.csv') %>%
    read_csv() %>% 
    clean_names() %>% 
    filter(event == "START") %>% 
    pull(system_time)
  
  stopifnot(length(start_time) == 1)
  
  noise_data <- 
    folder_path %>% 
    here('Amplitudes.csv') %>%
    read_csv() %>% 
    clean_names() %>% 
    mutate(
      timestamp = start_time + time_s,
      timestamp = timestamp %>% 
        as_datetime() %>% 
        with_tz('CET')
    )
  
  return(noise_data)
}
