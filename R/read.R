read_noise <- function(folder_path,
                       tz = 'CET') {
  
  exp_times <- 
    folder_path %>% 
    here('meta', 'time.csv') %>%
    read_csv() %>% 
    clean_names()
  
  restart_times <- 
    exp_times %>% 
    filter(event == "START") %>% 
    pull(system_time)
  
  start_time <- restart_times[1]
  
  noise_data <- 
    folder_path %>% 
    here('Amplitudes.csv') %>%
    read_csv(
      col_types = cols(
        'Sound pressure level (dB)' = col_number()
      )
    ) %>% 
    clean_names() %>% 
    transmute(
      exp_time = time_s,
      sound_pressure_level_d_b,
      exp_time_after_pause = time_s,
      pause_group = 1
    )
  
  if(length(restart_times) > 1) {
    pause_times <- 
      exp_times %>% 
      filter(event == 'PAUSE') %>% 
      slice( 1:{ n() - 1 } ) %>% 
      select(
        experiment_time,
        pause_sys_time = system_time
      )
    
    restart_times <- 
      exp_times %>% 
      filter(event == "START") %>% 
      slice(2:n()) %>% 
      select(
        experiment_time,
        restart_sys_time = system_time
      )
    
    pauses <- 
      full_join(
        pause_times,
        restart_times,
        by = join_by(experiment_time)
      ) %>% 
      mutate(pause_length = restart_sys_time - pause_sys_time)
    
    for(i in 1:nrow(pauses)) {
      pause_exp_time <- 
        pauses %>% 
        slice(i) %>% 
        pull(experiment_time)
      
      pause_length <- 
        pauses %>% 
        slice(i) %>% 
        pull(pause_length)
      
      noise_data <- 
        noise_data %>% 
        mutate(
          exp_time_after_pause = 
            exp_time_after_pause %>% 
            { 
              case_when(
                exp_time > pause_exp_time ~ . + pause_length,
                TRUE ~ .
              )
            },
          pause_group = 
            pause_group %>% 
            { 
              case_when(
                exp_time > pause_exp_time ~ . + i,
                TRUE ~ .
              )
            }
        )
    }
    
  }
  
  noise_data <- 
    noise_data %>% 
    mutate(
      timestamp = start_time + exp_time_after_pause,
      timestamp = timestamp %>%
        as_datetime() %>%
        with_tz(tz)
    )
  
  return(noise_data)
}
