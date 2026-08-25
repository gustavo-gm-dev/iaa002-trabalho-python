### Pacotes necessários:
install.packages("e1071") 
install.packages("caret")
install.packages("Metrics")
library("caret")

### Leitura dos dados
setwd("~/IAA008 Aprendizado de Maquina/dados/05 - Biomassa")
dados <- read.csv("5 - Biomassa - Dados.csv", header=T)
View(dados)

### Cria arquivos de treino e teste
set.seed(202650)
ind <- createDataPartition(dados$biomassa, p=0.80, list = FALSE)
treino <- dados[ind,]
teste <- dados[-ind,]
### Prepara um grid com os valores de k que 
### serão usados 
tuneGrid <- expand.grid(k = c(1,3,5,7,9))
### Executa o Knn com esse grid
set.seed(202650)
knn <- train(biomassa ~ ., data = treino, method = "knn",
             tuneGrid=tuneGrid)
knn

### Aplica o modelo no arquivo de teste
predict.knn <- predict(knn, teste)

########### CALCULO DE METRICAS #################

library(Metrics)

# Dados reais e preditos
obs <- teste$biomassa
pred <- predict.knn
n <- length(obs)
k <- 1 # Graus de liberdade 1 conforme aula do professor

# Métricas de Erro e Correlação
mae_val   <- mae(obs, pred)
rmse_val  <- rmse(obs, pred)
r_pearson <- cor(obs, pred)

# Erro Padrão da Estimativa (Syx) e Syx%
syx      <- sqrt(sum((obs - pred)^2) / (n - k))

# R2 ajustado/simples
r2 <- function(predito, observado) {
  return(1 - (sum((predito-observado)^2) / sum((observado-mean(observado))^2)))
}
r2_val   <- r2(predict.knn,teste$biomassa)

# Consolidação em um data frame
resultados <- data.frame(
  R2 = r2_val,
  Syx = syx,
  Pearson_r = r_pearson,
  RMSE = rmse_val,
  MAE = mae_val
)

print(resultados)