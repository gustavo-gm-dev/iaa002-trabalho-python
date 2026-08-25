# Definir a seed 

set.seed(202650) 



# Ler a base de dados 

veiculos <- read.csv("6 - Veiculos - Dados.csv", header = TRUE, sep = ",") 



# Remover identificador e variável categórica 

dados_cluster <- veiculos[, !(names(veiculos) %in% c("a", "tipo"))] 



# Padronizar os dados 

dados_padronizados <- scale(dados_cluster) 



# Aplicar K-Means com 10 clusters 

kmeans_veiculos <- kmeans( 
  
  dados_padronizados, 
  
  centers = 10, 
  
  nstart = 25 
  
) 



# Adicionar o cluster à base original 

veiculos$cluster <- kmeans_veiculos$cluster 



# Visualizar as 10 primeiras linhas 

head(veiculos, 10) 



# Verificar quantidade de registros na base 

nrow(veiculos) 



# Verificar quantidade de veículos em cada cluster 

table(veiculos$cluster) 



# Visualizar as 10 primeiras linhas com seus clusters 

veiculos[1:10, c("a", "tipo", "cluster")] 



# Listar os veículos pertencentes a cada cluster 

split(veiculos$a, veiculos$cluster) 