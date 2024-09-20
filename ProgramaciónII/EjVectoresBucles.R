ex_1 <- function()
{
  {nota <- scan(, what = double(), 1)}
  
  if (nota >= 5.0)
  {
    cat("Aprobado!\n")
  } else {
    cat("Suspenso\n")
  }
}

ex_2 <- function()
{
  nota = -1
  
  while (nota < 0 || nota > 10)
  {
    cat("Por favor, inroduzca una nota entre 0 y 10\n")
    {nota <- scan(, what = double(), 1)}
  }
  
  if (nota < 5)
  {
    cat("Suspenso\n")
    
  } else if (nota < 7){
    
    cat("Aprobado\n")
    
  } else if (nota < 9){
    
    cat("Notable!\n")
    
  } else {
    
    cat("Sobresaliente!\n")
    
  }
  
}

ex_3 <- function()
{
  {nota <- scan(, what = double(), 5)}
  
  for(i in seq_along(nota)){
    if (nota[[i]] >= 5.0)
    {
      nota[[i]] <- "Aprobado"
    } else {
      nota[[i]] <- "Suspenso"
    }
    }
  nota
}

ex_4 <- function(vec)
{
  cat("Aprobados: ", length(vec[vec >= 5]), "\n")
  cat("Suspensos: ", length(vec[vec < 5]), "\n")
}  
  
ex_5 <- function(vec)
{
  #Se asume que la nota viene primero y luego si es de erasmus
  for (j in 1:2)
  {
    
    
    cuenta_aprob <- 0
    cuenta_aprob_erasmus <- 0
    cuenta_erasmus <- 0
    
    nota_actual <- 0
    
    for(i in seq_along(vec))
    {
      if (i %% 2 != 0) # Si es impar el índice (nota)
      {
        nota_actual <- as.numeric(vec[[i]])
        
        if (nota_actual >=  5){cuenta_aprob <- cuenta_aprob + 1}
        
        if (nota_actual >= (5+1-j) && vec[[i+1]] == "Sí")
          {cuenta_aprob_erasmus <- cuenta_aprob_erasmus + 1}
        
      } else { #Si el índice es par (Si es erasmus)
        
        if(vec[[i]] == "Sí"){cuenta_erasmus <- cuenta_erasmus + 1}
      }
    }
    
    cat("Total de aprobados: ", cuenta_aprob, "\n")
    cat("Total de suspensos: ", length(vec)/2 - cuenta_aprob, "\n")
    cat("Total de aprobados de erasmus: ", cuenta_aprob_erasmus, "\n")
    cat("Total de suspensos de erasmus: ", cuenta_erasmus - cuenta_aprob_erasmus, "\n\n\n\n")
  }
  
}

ex_6 <- function(vec)
{
  vec <- vec + c(0,vec[1:length(vec)-1])
  vec
}

ex_7 <- function(vec)
{
  if (length(vec) > 1) {vec <- vec + c(vec[2:length(vec)],0)}
  vec
}

ex_8 <- function(vec)
{
  vec_odd <- vec[(vec %% 2) != 0]
  vec_even <- vec[(vec %% 2) == 0]
  
  cat("Vector de impares: ", vec_odd, "\n")
  cat("Vector de pares: ",  vec_even, "\n")
}

A = c(2,4,5,7)

cat("Ejercicio 6: \n")
ex_6(A)

cat("Ejercicio 7: \n")
ex_7(A)

cat("Ejercicio 8: \n")
ex_8(A)


{
  f <- scan(, what = double(), 1)
  g <- scan(, what = double(), 1)
  h <- scan(, what = double(), 1)
}



B <- vector(mode = "integer", length = length(A))
