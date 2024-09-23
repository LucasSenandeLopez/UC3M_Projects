ex_1 <- function(vec)
{
  cat("Usando un for:\n")
  for (i in vec)
  {
    cat(i, " ")
  }
  
  cat("\n\nUsando un while:\n")
  
  i = 1
  len = length(vec)
  
  while(i <= len)
  {
    cat(vec[[i]], " ")
    i <- i + 1
  }
  
  cat("\n\nUsando un repeat:\n")
  
  i = 1
  repeat
  {
      cat(vec[[i]], " ")
    
    if(i >= len){break}
    i <- i + 1
  }
}

ex_2 <- function(vec) #Asume que la longitud del vector NO es 0
{
  len <- length(vec)
  
  cat("Usando un for:\n")
  for (i in len:1)
  {
    cat(vec[[i]], " ")
  }
  
  cat("\n\nUsando un while:\n")
  
  i <- len
  
  
  while(i >= 1)
  {
    cat(vec[[i]], " ")
    i <- i - 1
  }
  
  cat("\n\nUsando un repeat:\n")
  
  i <- len
  repeat
  {
    cat(vec[[i]], " ")
    
    if(i <= 1){break}
    i <- i - 1
  }
}


ex_3 <- function(vec)
{
  cat("introduzca un número, por favor:\n")
  {
    num <- scan(,what=integer(),1)
  }
  
  cat("Hay ", length(vec[vec == num]), " ocurrencias de ", num, " en", vec, "\n")
  
  
  i <- 1
  len <- length(vec)
  count <- 0
  
  while (i <= len)
  {
    if(vec[[i]] == num){count <- count + 1}
    
    i <- i + 1
  }
  
  print(count)
  
  i <- 1
  count <- 0
  repeat
  {
    if(vec[[i]] == num){count <- count + 1}
    
    i <- i + 1
    
    if(i > len){break}
  }
  print(count)
}

  

ex_4 <- function(vec)
{
  cat("introduzca un número, por favor:\n")
  {
    num <- scan(,what=double(),1)
  }
  
  temp <- num
  len <- length(vec)
  
  for(i in vec)
  {
    num <- num*i
  }
  
  cat("Ahora el número es: ", num, "\n")
  
  num <- temp
  i <- 1
  
  while (i <= len)
  {
    num <- num * vec[[i]]
    i <- i + 1
  }
  
  cat("Ahora el número es: ", num, "\n")

  
  num <- temp
  i <- 1
  
  repeat
  {
    num <- num * vec[[i]]
    i <- i + 1
    
    
    if(i > len){break}
  }
  
  cat("Ahora el número es: ", num, "\n")

}