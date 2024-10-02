ex_1 <- function(vec)
{
  {num <- scan(,what=integer(), 1)}
  
  if(sum(vec[vec == num]) >= 1)
  {
    cat(num, "está en el vector\n")
    
  } else {
    
    cat(num, "no está en el vector\n")
  }
}

ex_1_bucles <- function(vec)
{
  {num <- scan(,what=integer(), 1)}
  
  i <- 1
  len <- length(vec)
  
  index_in_vec <- i <= len
  num_in_vec <- vec[i] == num
  
  repeat
  {
    if(!(num_in_vec && index_in_vec)){break} #Si el vector está vacío, no se comprueba nada
    
    num_in_vec <- vec[i] == num
    index_in_vec <- i <= len
    
    i <- i + 1
  }
  
  if(num_in_vec)
  {
    cat(num, " está en el vector\n")
    
  } else {
    
    cat(num, " no está en el vector\n")
  }
  
}


ex_2 <- function(vec_1, vec_2)
{
  vec_3 <- intersect(vec_1, vec_2)
  
  cat("Hay ", length(vec_3), " elementos coincidentes; ", vec_3)

}

ex_2_bucle <- function(vec_1, vec_2)
{
  len_1 <- length(vec_1)
  len_2 <- length(vec_2)
  
  coincidentes <- c()
  
  i_1 <- 1
  i_2 <- 1
  coincide <- FALSE
  
  repeat #Índices del vector 1
  {
    if(i_1 > len_1){break}
    
    repeat
    {
      #Si se llega al límite de vec_2 o se tiene coincidencia, se sale
      if (coincide || (i_2 > len_2)) {break} 
      
      coincide <- vec_1[i_1] == vec_2[i_2] 
      
      i_2 <- i_2 + 1
      
    }
    
    if(coincide) #Tras salir del bucle de vec_2, si hay coindicenca, se añade
    {
      coincidentes <- c(coincidentes, vec_2[i_1])
    }
    
    coincide <- FALSE
    i_2 <- 1
    i_1 <- i_1 + 1
  }
  
  cat("Hay ", length(coincidentes), "coindicencias entre los vectores; ", coincidentes, "\n")
  
}

ex_3 <- function(vec_1, vec_2)
{
  len <- length(vec_1)
  
  if(len == length(vec_2))
  {
  
    iguales <- TRUE
    i <- 1
    
    repeat
    {
      if(!iguales || i > len) {break}
      
      
      iguales <- vec_1[i] == vec_2[len - i + 1]
      i <- i + 1
    }
    
    if(iguales)
    {
      cat("Los dos vectores son iguales leídos del revés\n")

      
    } else {
      
      cat("Los vectores no son iguales leídos del revés\n")

    }
  } else {
    
    cat("Los vectores no son iguales al no ser de la misma longitud\n")
  }
}

ex_4 <- function(vec)
{
  len <- length(vec)
  len_2 <- len %/% 2 #Si el vector es simétrico, solo necesitamos iterar sobre una mitad
  
  capicua <- TRUE #Si el vector tiene longitud 1 entonces es capicúa inmediatamente
  i <- 1
  
  repeat
  {
    if(!capicua || i > len_2){break}
    
    capicua <- vec[i] == vec[len-i+1]
    i <- i + 1
  }
  
  if(capicua)
  {
    cat("El vector es capicúa\n")
    
  } else {
    
    cat("El vector no es capicúa\n")
  }
}
