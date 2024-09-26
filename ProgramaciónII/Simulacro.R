ex_1 <- function(vec)
{
  num <- 0
  
  if(length(vec) < 3){vec <- c(0,0,0,vec)}
  
  len <- length(vec)
  
  for(i in len:1)
  {
    num <- num + vec[i] * 10^(len - i)
  }

  divisores <- c(1)
  
  for(i in 2:10)
  {
    if(num %% i == 0){divisores <- c(divisores, i)}
  }
  
  #cat("Divisibles: ", divisores, "\n")
  return(divisores)
}

ex_1_alt <- function(vec)
{
  num <- 0
  if(length(vec) < 3){vec <- c(0,0,0,vec)}
  len <- length(vec)
  
  for(i in len:1)
  {
    num <- num + vec[i] * 10^(len - i)
  }
  
  divisores <- c(1)
  
  if(num %% 2 == 0){divisores <- c(divisores, 2)}
  
  if(sum(vec) %% 3 == 0){divisores <- c(divisores, 3)}
  
  temp_num <- vec[len - 1]*10 + vec[len]

  if(temp_num %% 4 == 0){divisores <- c(divisores, 4)}
  
  if(vec[len] == 5 || vec[len] == 0){divisores <- c(divisores, 5)}
  
  if(num %% 2 == 0 && num %% 3 == 0){divisores <- c(divisores, 6)}
  
  temp_num <- num %/% 10 - 2*vec[len]
  
  if(temp_num %% 7 == 0){divisores <- c(divisores, 7)}
  
  if(num %% 8 == 0){divisores <- c(divisores, 8)}
  
  if(sum(vec) %% 9 == 0){divisores <- c(divisores, 9)}
  
  if(vec[len] == 0){divisores <- c(divisores, 10)}
  
  
  #cat("Divisibles: ", divisores, "\n")
  return(divisores)
}

ex_2 <- function(vec_1, vec_2)
{
  len_1 <- length(vec_1)
  len_2 <- length(vec_2)
  
  if(len_1 < len_2)
  {
    vec_1 <- c(rep(0, len_2 - len_1), vec_1)
    
  } else {
    
    vec_2 <- c(rep(0, len_1 - len_2), vec_2)
  }
  
  vec_sum <- vec_2 + vec_1
  
  for(i in length(vec_sum):2)
  {
    if(vec_sum[i] >= 10)
    {
      vec_sum[i] <- vec_sum[i] - 10
      vec_sum[i - 1] <- vec_sum[i - 1] + 1
    }
  }
  
  if(vec_sum[1] >= 10)
  {
    vec_sum[1] <- vec_sum[1] - 10
    vec_sum <- c(1, vec_sum)
  }
  return(vec_sum)
}











