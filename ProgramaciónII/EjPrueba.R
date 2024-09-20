ej_1 <- function(vec)
{
  if (length(vec) == 1){return(vec)} # Necesario porque iteramos entre 2:n luego
  
  return_vec = vector(mode = "numeric", length = length(vec))
  
  return_vec[1] = vec[1]
  
  for (i in 2:length(vec))
  {
    return_vec[i] = vec[i-1] + vec[i]
  }
  
  return(return_vec)
}

ej_2 <- function(mat)
{
  repeat
  {
    
    i = 21 #iniciamos fuera del intervalo para que se ejecute al menos una vez
    break_loop = FALSE # se usa para evitar iteraciones innecesarias
    
    while (i < 0 || i > 20)
    {
      i = sample(1:20, 1) #como no sé input, obtenemos uno al azar
    }
    
    for (rw in 1:nrow(mat))
    {
      for (cl in 1:ncol(mat))
      {
        #colocamos -1 en vez de un asterisco para no convertir el tipo de datos 
        # de la matriz
       if (mat[rw, cl] == i)
        {
         mat[rw, cl] = -1 
         break_loop = TRUE
        }
        if(break_loop){break}
      }
      if(break_loop){break}
    }
    
    if(sum(mat) == (-1 * ncol(mat) *nrow(mat))){break}
  }
  print("terminado")
  mat
}

ej_3 <- function(vec)
{
  
  if (length(vec) == 1){return("ES CAPICÚA")}
  
  for (i in 1:(length(vec) %/% 2))
  {
    if (vec[i] != vec[length(vec) - i + 1]){return("NO ES CAPICÚA")}
  }
  return("ES CAPICÚA")
}

ej_4 <- function(vec_1, vec_2)
{
  min_len = min(c(length(vec_1), length(vec_2)))
  max_len = max(c(length(vec_1), length(vec_2)))

  if(length(vec_1) == max_len && length(vec_1) != length(vec_2))
  {
    fill = vector(mode = "integer", length = max_len - min_len)
    vec_2 = c(fill, vec_2)
    
  } else if (length(vec_2) == max_len && length(vec_1) != length(vec_2)) {
    
    fill = vector(mode = "integer", length = max_len - min_len)
    vec_1 = c(fill, vec_1)
  }
  
  vec_1 = vec_1 + vec_2
  for (i in length(vec_1):1)
  {
    if (i != 1 && vec_1[i] > 9)
    {
      vec_1[i] = vec[i] - 10
      vec_1[i-1] = vec_1[i-1] + 1
    }
  }
  
  if (vec_1[1] > 9)
  {
    vec_1[1] = vec_1[1] - 10
    vec_1 = c(1, vec_1)
  }
  
  return(vec_1)
}